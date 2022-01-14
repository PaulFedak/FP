public with sharing class TicketTriggerHandler {

    public static void handle(List<Ticket__c> newRecords, Map<Id, Ticket__c> oldMap, TriggerOperation operation) {
        switch on operation {
            when BEFORE_INSERT {
                BookedBeforeTriggerTicket(newRecords, oldMap);
                flightInfoTriggerTicket(newRecords, oldMap);
            }
            when BEFORE_UPDATE {
                flightInfoTriggerTicket(newRecords, oldMap);
            }
        }
    }

    public static void BookedBeforeTriggerTicket(List<Ticket__c> newRecords, Map<Id, Ticket__c> oldMap) {
        List<Ticket__c> flightInfos = new List<Ticket__c>();
        flightInfos = new List<Ticket__c>([
                SELECT Id,
                        Flight_Info_Id__c,
                        Flight_Info_Id__r.Date_time_of_Flight__c
                FROM Ticket__c
        ]);
        for (Ticket__c newTicket : newRecords) {
            if (oldMap == null) {
                newTicket.Status__c = 'Booked';
            }
            if(newTicket.Flight_Info_Id__r.Date_time_of_Flight__c <= System.now()){
                newTicket.Flight_Info_Id__c.addError('This flight started or finished');
            }
        }


    }

    public static void flightInfoTriggerTicket(List<Ticket__c> newRecords, Map<Id, Ticket__c> oldMap) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();

        for (Ticket__c newTicket : newRecords) {
                contactMap.put(newTicket.Contact__c, null);
        }

        contactMap = new Map<Id, Contact>([
                SELECT Id,Traveled_miles__c
                FROM Contact
                WHERE Id IN :contactMap.keySet()
        ]);

        Map<Id, Flight_Info__c> infoMap = new Map<Id, Flight_Info__c>();

        for (Ticket__c newFlightInfo : newRecords) {
            System.debug(newFlightInfo.Flight_Info_Id__c);
            infoMap.put(newFlightInfo.Flight_Info_Id__c, null);
        }

        infoMap = new Map<Id, Flight_Info__c>([
                SELECT Id,
                        Flight_Distance__c,
                        Business_available_seats__c,
                        Economy_available_seats__c
                FROM Flight_Info__c
                WHERE Id IN :infoMap.keySet()
        ]);

        Map<Id, Schema.RecordTypeInfo> rtMap = Ticket__c.sObjectType.getDescribe().getRecordTypeInfosById();

        for (Ticket__c ticketBooked : newRecords) {
                  if (rtMap.get(ticketBooked.RecordTypeId).getDeveloperName().contains(Constants.BUSINESS_TYPE)) {
                if (infoMap.get(ticketBooked.Flight_Info_Id__c).Business_available_seats__c <= 0) {
                    ticketBooked.addError('This flight has not available seats in Business class');
                }
                if (ticketBooked.Status__c == 'Booked' && oldMap == null) {
                    infoMap.get(ticketBooked.Flight_Info_Id__c).Business_available_seats__c -= 1;
                } else if (ticketBooked.Status__c == 'Returned' && contactMap !=null) {
                    infoMap.get(ticketBooked.Flight_Info_Id__c).Business_available_seats__c += 1;
                    if (contactMap.get(ticketBooked.Contact__c).Traveled_miles__c > infoMap.get(ticketBooked.Flight_Info_Id__c).Flight_Distance__c * 0.3) {
                        contactMap.get(ticketBooked.Contact__c).Traveled_miles__c = contactMap.get(ticketBooked.Contact__c).Traveled_miles__c - infoMap.get(ticketBooked.Flight_Info_Id__c).Flight_Distance__c * 0.3;
                    } else if (contactMap.get(ticketBooked.Contact__c).Traveled_miles__c < infoMap.get(ticketBooked.Flight_Info_Id__c).Flight_Distance__c * 0.3) {
                        contactMap.get(ticketBooked.Contact__c).Traveled_miles__c = 0;
                    }
                } else if (ticketBooked.Status__c == 'Completed'&& contactMap !=null) {
                    contactMap.get(ticketBooked.Contact__c).Traveled_miles__c =
                            infoMap.get(ticketBooked.Flight_Info_Id__c).Flight_Distance__c * 0.3 +
                                    contactMap.get(ticketBooked.Contact__c).Traveled_miles__c;
                }


            } else if (rtMap.get(ticketBooked.RecordTypeId).getDeveloperName().contains(Constants.ECONOMY_TYPE)) {
                if (infoMap.get(ticketBooked.Flight_Info_Id__c).Economy_available_seats__c <= 0) {
                    ticketBooked.addError('This flight has not available seats in Economy class');
                }
                if (ticketBooked.Status__c == 'Booked' && oldMap == null) {
                    infoMap.get(ticketBooked.Flight_Info_Id__c).Economy_available_seats__c -= 1;
                } else if (ticketBooked.Status__c == 'Returned'&& contactMap !=null) {
                    infoMap.get(ticketBooked.Flight_Info_Id__c).Economy_available_seats__c += 1;
                    if (contactMap.get(ticketBooked.Contact__c).Traveled_miles__c > infoMap.get(ticketBooked.Flight_Info_Id__c).Flight_Distance__c * 0.1) {
                        contactMap.get(ticketBooked.Contact__c).Traveled_miles__c = contactMap.get(ticketBooked.Contact__c).Traveled_miles__c - infoMap.get(ticketBooked.Flight_Info_Id__c).Flight_Distance__c * 0.1;
                    } else if (contactMap.get(ticketBooked.Contact__c).Traveled_miles__c < infoMap.get(ticketBooked.Flight_Info_Id__c).Flight_Distance__c * 0.1) {
                        contactMap.get(ticketBooked.Contact__c).Traveled_miles__c = 0;
                    }
                } else if (ticketBooked.Status__c == 'Completed'&& contactMap !=null) {
                    contactMap.get(ticketBooked.Contact__c).Traveled_miles__c = infoMap.get(ticketBooked.Flight_Info_Id__c).Flight_Distance__c * 0.1 + contactMap.get(ticketBooked.Contact__c).Traveled_miles__c;
                }
            }
        }
        update infoMap.values();
        update contactMap.values();
    }
}