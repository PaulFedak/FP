import {LightningElement, api, wire, track} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {updateRecord} from 'lightning/uiRecordApi';
import getTicketsByFilter from '@salesforce/apex/AllTicketsController.getTicketsByFilter';
import accRecordTypeList from '@salesforce/apex/AllTicketsController.accRecordTypeList';
import {refreshApex} from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getPicklistValues} from "lightning/uiObjectInfoApi";
import DISCOUNT_FIELD from '@salesforce/schema/Contact.Discount__c';
import CONTACTID_FIELD from '@salesforce/schema/Ticket__c.Contact__c';
import STATUS_FIELD from '@salesforce/schema/Ticket__c.Status__c';
import ID_FIELD from '@salesforce/schema/Ticket__c.Id';

export default class AllTicketList extends LightningElement {
    value;

    @track data;
    searchable = [];
    wiredCases
    result;
    options;

    doneTypingInterval = 0;

    searchAllValue;

    departure = "";
    destination = "";
    recordType = "";

    disabled = false;
    @api recordId;

    @wire(getRecord, {recordId: '$recordId', fields: [DISCOUNT_FIELD]})
    contact;


    @wire(getTicketsByFilter, {
        departure: "$departure",
        destination: "$destination",
        recordType: "$recordType"
    })
    wiredSObjects(result) {
        console.log("wire getting called");
        this.wiredCases = result;
        if (result.data) {
            this.result = result;
            this.searchable = this.data = result.data.map((caseObj, index) => ({
                caseData: {...caseObj},
                index: index + 1,
                rowIndex: index
            }));
        } else if (result.error) {
            console.error("Error", result.error);
        }
    }

    @wire(accRecordTypeList)
    wiredRecordSObjects(result) {
        console.log(JSON.stringify(result));
        if (result.data) {
            console.log(JSON.stringify(result));
            console.log(JSON.stringify(result.data));
            this.options = result.data.map((caseObj, index) => ({
                label: caseObj.Name,
                value: caseObj.DeveloperName
            }));
            console.log(JSON.stringify(this.options));
        } else if (result.error) {
            console.error("Error", error);
        }
    }


    priceWithDiscount(event) {
        let discount = this[event.target] * (1.0 - DISCOUNT_FIELD);
        return discount;
    }


    handleChange(event) {
        this[event.target.name] = event.target.value;
        console.log("change", this[event.target.name]);
    }

    handleKeyUp(event) {
        clearTimeout(this.typingTimer);
        let value = event.target.value;
        let name = event.target.name;

        this.typingTimer = setTimeout(() => {
            this[name] = value;
        }, this.doneTypingInterval);
    }

    clearSearch() {
        this.departure = "";
        this.destination = "";
        this.recordType = "";
        this.searchable = this.data;
        this.searchAllValue = "";
        this.searchAll();
    }

    handleSearchAll(event) {
        this.searchAllValue = event.target.value;
        this.searchAll();
    }

    searchAll() {
        let searchStr = this.searchAllValue.toLowerCase();
        const regex = new RegExp(
            "(^" + searchStr + ")|(." + searchStr + ")|(" + searchStr + "$)"
        );
        if (searchStr.length > 2) {
            this.searchable = this.data.filter((item) => {
                if (
                    regex.test(
                        item.caseData.Flight_Info_Id__r.Destination__c.toLowerCase() +
                        " " +
                        item.caseData.Flight_Info_Id__r.Destination__c.toLowerCase()
                    ) ||
                    regex.test(
                        item.caseData.Flight_Info_Id__r.Departure__c?.toLowerCase() +
                        " " +
                        item.caseData.Flight_Info_Id__r.Departure__c?.toLowerCase()
                    )
                ) {
                    return item;
                }
            });
        } else if (this.departure.length <= 2) {
            this.searchable = this.data;
        }
        console.log(this.searchable);
    }

    handleNavigate(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                actionName: "view",
                recordId: event.target.dataset.id
            }
        });
    }


// ----------------------------------------------------
    buyTicket(event) {
        const fields = {};
        console.log(event.currentTarget.dataset.id);
        console.log(this.recordId);
        fields[ID_FIELD.fieldApiName] = event.currentTarget.dataset.id;
        fields[CONTACTID_FIELD.fieldApiName] = this.recordId;

        const recordInput = {fields};

        console.log(recordInput);
        updateRecord(recordInput)
            .then(() => {
                console.log('uiRecordApi')
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact updated',
                        variant: 'success'
                    })
                );
                console.log('Update');
                // Display fresh data in the form
                return refreshApex(this.result);
            })
            .catch(error => {
                console.log('error')
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                console.log('Error');
            });
        console.log('finish');
    }
}