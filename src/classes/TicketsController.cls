public with sharing class TicketsController {
    @AuraEnabled(Cacheable=true)
    public static List<Ticket__c> getTicketByContactId(Id contactId){
        return [SELECT
                Name,
                RecordTypeId,
                Contact__c,
                Flight_Info_Id__r.Destination__c,
                Flight_Info_Id__r.Departure__c,
                Flight_Info_Id__r.Date_time_of_Flight__c,
                Flight_Info_Id__r.Finish_flight_time__c,
                Status__c,
                Price__c
        FROM Ticket__c WHERE Contact__c = :contactId AND Status__c=:'Booked'];
    }
}