public with sharing class FlightInfoTriggerHandler {

    public static void handle(List<Flight_Info__c> newRecords, Map<Id, Flight_Info__c> oldMap, TriggerOperation operation) {
        switch on operation {
            when BEFORE_INSERT {
                checkSuccessAircraftFlightInfoTrigger(newRecords,oldMap);
                aircraftFlightInfoTrigger(newRecords, oldMap);
//                destinationAndDepartureFlightInfoTrigger(newRecords, oldMap);
            }
//            when BEFORE_UPDATE {
//                checkSuccessAircraftFlightInfoTrigger(newRecords,oldMap);
//                destinationAndDepartureFlightInfoTrigger(newRecords, oldMap);
//            }
        }
    }


    public static void aircraftFlightInfoTrigger(List<Flight_Info__c> newRecords, Map<Id, Flight_Info__c> oldMap) {
        Map<Id, Aircraft__c> aircraftMap = new Map<Id, Aircraft__c>();

        for (Flight_Info__c newFlightInfo : newRecords) {
            aircraftMap.put(newFlightInfo.AircraftId__c, null);
        }

        aircraftMap = new Map<Id, Aircraft__c>([
                SELECT Id,
                        Business_seats__c,
                        Economy_seats__c
                FROM Aircraft__c
                WHERE Id IN :aircraftMap.keySet()
        ]);
        for (Flight_Info__c seats : newRecords) {
            seats.Business_available_seats__c = aircraftMap.get(seats.AircraftId__c).Business_seats__c;
            seats.Economy_available_seats__c = aircraftMap.get(seats.AircraftId__c).Economy_seats__c;
        }
    }

    public static void checkSuccessAircraftFlightInfoTrigger(List<Flight_Info__c> newRecords, Map<Id, Flight_Info__c> oldMap) {
        List<Flight_Info__c> flightInfos = new List<Flight_Info__c>();
        flightInfos = new List<Flight_Info__c>([
                SELECT Id,
                        AircraftId__c,
                        Date_time_of_Flight__c,
                        Finish_flight_time__c
                FROM Flight_Info__c
        ]);

        for (Flight_Info__c newRec : newRecords) {
            for (Flight_Info__c anotherFI : flightInfos) {
                if (newRec.AircraftId__c == anotherFI.AircraftId__c &&
                        newRec.Date_time_of_Flight__c >= anotherFI.Date_time_of_Flight__c &&
                        newRec.Date_time_of_Flight__c <= anotherFI.Finish_flight_time__c  ||
                        newRec.AircraftId__c == anotherFI.AircraftId__c &&
                        newRec.Finish_flight_time__c >= anotherFI.Date_time_of_Flight__c &&
                        newRec.Finish_flight_time__c <= anotherFI.Finish_flight_time__c) {
                    newRec.AircraftId__c.addError('Aircraft for this time already used');
                }
            }
        }
    }

//
//    public static void destinationAndDepartureFlightInfoTrigger(List<Flight_Info__c> newRecords, Map<Id, Flight_Info__c> oldMap) {
//        for (Flight_Info__c place : newRecords) {
//            if (place.Departure__c == 'Kiev' && place.Destination__c == 'Brasilia' || place.Departure__c == 'Brasilia' && place.Destination__c == 'Kiev') {
//                place.Flight_Distance__c = 6405;
//            } else if (place.Departure__c == 'Kiev' && place.Destination__c == 'Copenhagen' || place.Departure__c == 'Copenhagen' && place.Destination__c == 'Kiev') {
//                place.Flight_Distance__c = 1080;
//            } else if (place.Departure__c == 'Kiev' && place.Destination__c == 'Cairo' || place.Departure__c == 'Cairo' && place.Destination__c == 'Kiev') {
//                place.Flight_Distance__c = 1411;
//            } else if (place.Departure__c == 'Kiev' && place.Destination__c == 'London' || place.Departure__c == 'London' && place.Destination__c == 'Kiev') {
//                place.Flight_Distance__c = 1480;
//            } else if (place.Departure__c == 'Kiev' && place.Destination__c == 'Paris' || place.Departure__c == 'Paris' && place.Destination__c == 'Kiev') {
//                place.Flight_Distance__c = 1544;
//            } else if (place.Departure__c == 'Kiev' && place.Destination__c == 'Berlin' || place.Departure__c == 'Berlin' && place.Destination__c == 'Kiev') {
//                place.Flight_Distance__c = 860;
//            } else if (place.Departure__c == 'Kiev' && place.Destination__c == 'Madrid' || place.Departure__c == 'Madrid' && place.Destination__c == 'Kiev') {
//                place.Flight_Distance__c = 2327;
//            } else if (place.Departure__c == 'Brasilia' && place.Destination__c == 'Copenhagen' || place.Departure__c == 'Copenhagen' && place.Destination__c == 'Brasilia') {
//                place.Flight_Distance__c = 6098;
//            } else if (place.Departure__c == 'Brasilia' && place.Destination__c == 'Cairo' || place.Departure__c == 'Cairo' && place.Destination__c == 'Brasilia') {
//                place.Flight_Distance__c = 6306;
//            } else if (place.Departure__c == 'Brasilia' && place.Destination__c == 'London' || place.Departure__c == 'London' && place.Destination__c == 'Brasilia') {
//                place.Flight_Distance__c = 5460;
//            } else if (place.Departure__c == 'Brasilia' && place.Destination__c == 'Paris' || place.Departure__c == 'Paris' && place.Destination__c == 'Brasilia') {
//                place.Flight_Distance__c = 5345;
//            } else if (place.Departure__c == 'Brasilia' && place.Destination__c == 'Berlin' || place.Departure__c == 'Berlin' && place.Destination__c == 'Brasilia') {
//                place.Flight_Distance__c = 6012;
//            } else if (place.Departure__c == 'Brasilia' && place.Destination__c == 'Madrid' || place.Departure__c == 'Madrid' && place.Destination__c == 'Brasilia') {
//                place.Flight_Distance__c = 4875;
//            } else if (place.Departure__c == 'Copenhagen' && place.Destination__c == 'Cairo' || place.Departure__c == 'Cairo' && place.Destination__c == 'Copenhagen') {
//                place.Flight_Distance__c = 1995;
//            } else if (place.Departure__c == 'Copenhagen' && place.Destination__c == 'London' || place.Departure__c == 'London' && place.Destination__c == 'Copenhagen') {
//                place.Flight_Distance__c = 713;
//            } else if (place.Departure__c == 'Copenhagen' && place.Destination__c == 'Paris' || place.Departure__c == 'Paris' && place.Destination__c == 'Copenhagen') {
//                place.Flight_Distance__c = 795;
//            } else if (place.Departure__c == 'Copenhagen' && place.Destination__c == 'Berlin' || place.Departure__c == 'Berlin' && place.Destination__c == 'Copenhagen') {
//                place.Flight_Distance__c = 287;
//            } else if (place.Departure__c == 'Copenhagen' && place.Destination__c == 'Madrid' || place.Departure__c == 'Madrid' && place.Destination__c == 'Copenhagen') {
//                place.Flight_Distance__c = 1466;
//            } else if (place.Departure__c == 'Cairo' && place.Destination__c == 'London' || place.Departure__c == 'London' && place.Destination__c == 'Cairo') {
//                place.Flight_Distance__c = 2186;
//            } else if (place.Departure__c == 'Cairo' && place.Destination__c == 'Paris' || place.Departure__c == 'Paris' && place.Destination__c == 'Cairo') {
//                place.Flight_Distance__c = 1997;
//            } else if (place.Departure__c == 'Cairo' && place.Destination__c == 'Berlin' || place.Departure__c == 'Berlin' && place.Destination__c == 'Cairo') {
//                place.Flight_Distance__c = 1800;
//            } else if (place.Departure__c == 'Cairo' && place.Destination__c == 'Madrid' || place.Departure__c == 'Madrid' && place.Destination__c == 'Cairo') {
//                place.Flight_Distance__c = 2082;
//            } else if (place.Departure__c == 'London' && place.Destination__c == 'Paris' || place.Departure__c == 'Paris' && place.Destination__c == 'London') {
//                place.Flight_Distance__c = 289;
//            } else if (place.Departure__c == 'London' && place.Destination__c == 'Berlin' || place.Departure__c == 'Berlin' && place.Destination__c == 'London') {
//                place.Flight_Distance__c = 619;
//            } else if (place.Departure__c == 'London' && place.Destination__c == 'Madrid' || place.Departure__c == 'Madrid' && place.Destination__c == 'London') {
//                place.Flight_Distance__c = 1072;
//            } else if (place.Departure__c == 'Paris' && place.Destination__c == 'Berlin' || place.Departure__c == 'Berlin' && place.Destination__c == 'Paris') {
//                place.Flight_Distance__c = 684;
//            } else if (place.Departure__c == 'Paris' && place.Destination__c == 'Madrid' || place.Departure__c == 'Madrid' && place.Destination__c == 'Paris') {
//                place.Flight_Distance__c = 783;
//            } else if (place.Departure__c == 'Berlin' && place.Destination__c == 'Madrid' || place.Departure__c == 'Madrid' && place.Destination__c == 'Berlin') {
//                place.Flight_Distance__c = 1466;
//            }
//        }
//    }
}