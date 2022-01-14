import {LightningElement, api, wire} from 'lwc';
import getTicketByContactId from '@salesforce/apex/TicketsController.getTicketByContactId';
import {refreshApex} from '@salesforce/apex';
import STATUS_FIELD from '@salesforce/schema/Ticket__c.Status__c';
import ID_FIELD from '@salesforce/schema/Ticket__c.Id';
import {updateRecord} from "lightning/uiRecordApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class TicketList extends LightningElement {
    @api recordId;
    @wire(getTicketByContactId, {contactId: '$recordId'})
    tickets;


    ticketReturn(event) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = event.currentTarget.dataset.id;
        fields[STATUS_FIELD.fieldApiName] = 'Returned';

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
                return refreshApex(this.tickets);
            })
            .catch(error => {
                console.log('error')
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                console.log('Error');
            });
        // } else {
        //     // The form is not valid
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Something is wrong',
        //             message: 'Check your input and try again.',
        //             variant: 'error'
        //         })
        //     );
        // }

        console.log('finish');
    }

}