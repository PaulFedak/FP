public with sharing class AllTicketsController {

    @AuraEnabled(Cacheable=true)
    public static List<Ticket__c> getTicketsByFilter(
            String departure,
            String destination,
            String recordType
    ) {
        String query;
        String condition = (String.isNotBlank(departure)
                ? 'Flight_Info_Id__r.Destination__c LIKE \'' + '%' + departure + '%\' AND'
                : '');

        condition += (String.isNotBlank(destination)
                ? (String.isNotBlank(condition) ? +'' : '') +
                        ' Flight_Info_Id__r.Departure__c LIKE \'' +
                        '%' +
                        destination +
                        '%\' AND'
                : '');

        condition += (String.isNotBlank(recordType)
                ? (String.isNotBlank(condition) ? +'' : '') +
                        ' RecordType.DeveloperName LIKE \'' +
                        '%' +
                        recordType +
                        '%\' AND'
                : '');
        condition += ' Contact__c = null AND Status__c = \'Booked\'';
        System.debug('condition ' + condition);
        if (String.isNotBlank(condition)) {
            query =
                    'SELECT  Flight_Info_Id__r.Destination__c,Flight_Info_Id__r.Departure__c,Flight_Info_Id__r.Date_time_of_Flight__c,Price__c FROM Ticket__c WHERE ' +
                            condition;
        } else {
            query = 'SELECT Flight_Info_Id__r.Destination__c,Flight_Info_Id__r.Departure__c,Flight_Info_Id__r.Date_time_of_Flight__c,Price__c FROM Ticket__c LIMIT 5';
        }

        List<Ticket__c> records = Database.query(query);
        return records;
    }


    @AuraEnabled(Cacheable = true)
    public static  List<RecordType> accRecordTypeList(){
        List<RecordType> recordTypeList = [SELECT Id, Name,DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Ticket__c'];
        System.debug('recordTypeList ' + recordTypeList);
        return recordTypeList;
    }

    @AuraEnabled(Cacheable = true)
    public static  List<Ticket__c> getTicketPrice(){
        List<Ticket__c> ticketPriceList = [SELECT Id,Name, Price__c FROM Ticket__c WHERE Contact__c =: null ];
        return ticketPriceList;
    }
}