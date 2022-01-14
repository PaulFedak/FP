@IsTest
private class TicketTriggerHandlerTest {
    @IsTest
    static void testBehavior() {
        Aircraft__c aircraft = new Aircraft__c(
                Name = 'PavloAircraft',
                Type__c = 'Small',
                Business_seats__c = 25,
                Economy_seats__c = 25
        );
        insert aircraft;

        Flight_Info__c flightInfo = new Flight_Info__c(
                Name = 'Pavlo',
                Departure__c = 'Kiev',
                Destination__c = 'Paris',
                Flight_Distance__c = 5000,
                Date_time_of_Flight__c = Datetime.newInstance(2022, 1, 17),
                Finish_flight_time__c = Datetime.newInstance(2022, 1, 18),
                AircraftId__c = aircraft.Id
        );
        insert flightInfo;

        Flight_Info__c flightInfoTwo = new Flight_Info__c(
                Name = 'Paul',
                Departure__c = 'Kiev',
                Destination__c = 'Paris',
                Flight_Distance__c = 6050,
                Date_time_of_Flight__c = Datetime.newInstance(2022, 1, 20),
                Finish_flight_time__c = Datetime.newInstance(2022, 1, 21),
                AircraftId__c = aircraft.Id
        );
        insert flightInfoTwo;

        Flight_Info__c flightInfoThree = new Flight_Info__c(
                Name = 'Paul',
                Departure__c = 'Kiev',
                Destination__c = 'Paris',
                Flight_Distance__c = 8522,
                Date_time_of_Flight__c = Datetime.newInstance(2022, 1, 08),
                Finish_flight_time__c = Datetime.newInstance(2022, 1, 09),
                AircraftId__c = aircraft.Id
        );
        insert flightInfoThree;

        Contact cont = new Contact(
                LastName = 'Pavlo Fedak',
                Traveled_miles__c = 0
        );
        insert cont;
        Contact cont2 = new Contact(
                LastName = 'Pavlo qqqq',
                Traveled_miles__c = 1000
        );
        insert cont2;

        Ticket__c ticketBusiness = new Ticket__c(
                RecordTypeId = '0127Q0000017g2aQAA',
                Name = 'TicketForPavlo',
                Flight_Info_Id__c = flightInfo.Id,
                Status__c = 'Booked',
                Contact__c = cont.Id
        );
        insert ticketBusiness;
        Ticket__c ticketEconomy = new Ticket__c(
                RecordTypeId = '0127Q0000017g6KQAQ',
                Name = 'TicketForPavloEconomy',
                Flight_Info_Id__c = flightInfoTwo.Id,
                Status__c = 'Booked',
                Contact__c = cont.Id
        );
        insert ticketEconomy;

        Ticket__c ticketEconomy2 = new Ticket__c(
                RecordTypeId = '0127Q0000017g6KQAQ',
                Name = 'TicketForPavloEconomy',
                Flight_Info_Id__c = flightInfoThree.Id,
                Status__c = 'Booked',
                Contact__c = cont.Id
        );
        insert ticketEconomy2;
        Ticket__c ticketBusiness31 = new Ticket__c(
                RecordTypeId = '0127Q0000017g2aQAA',
                Name = 'TicketForPavlo',
                Flight_Info_Id__c = flightInfoThree.Id,
                Status__c = 'Booked',
                Contact__c = cont2.Id
        );
        insert ticketBusiness31;
        Ticket__c ticketEconomy3 = new Ticket__c(
                RecordTypeId = '0127Q0000017g6KQAQ',
                Name = 'TicketForPavloEconomy',
                Flight_Info_Id__c = flightInfoTwo.Id,
                Status__c = 'Booked',
                Contact__c = cont2.Id
        );
        insert ticketEconomy3;

        Ticket__c ticketEconomy4 = new Ticket__c(
                RecordTypeId = '0127Q0000017g6KQAQ',
                Name = 'TicketForPavloEconomy',
                Flight_Info_Id__c = flightInfoThree.Id,
                Status__c = 'Booked',
                Contact__c = cont2.Id
        );
        insert ticketEconomy4;

        ticketEconomy = [SELECT Id,Flight_Info_Id__c FROM Ticket__c WHERE Flight_Info_Id__c = :flightInfoTwo.Id LIMIT 1];
        ticketEconomy.Flight_Info_Id__c = flightInfoThree.Id;
        update ticketEconomy;

        ticketEconomy2 = [SELECT Id,Flight_Info_Id__c FROM Ticket__c WHERE Flight_Info_Id__c = :flightInfoThree.Id LIMIT 1];
        ticketEconomy2.Status__c = 'Returned';
        update ticketEconomy2;


        ticketEconomy4 = [SELECT Id,Flight_Info_Id__c FROM Ticket__c WHERE Contact__c = :cont2.Id LIMIT 1];
        ticketEconomy4.Status__c = 'Returned';
        update ticketEconomy4;


        ticketEconomy4 = [SELECT Id,Flight_Info_Id__c FROM Ticket__c WHERE Contact__c = :cont2.Id LIMIT 1];
        ticketEconomy4.Contact__c = cont.Id;
        update ticketEconomy4;

        ticketEconomy4 = [SELECT Id,Flight_Info_Id__c FROM Ticket__c WHERE Contact__c = :cont2.Id LIMIT 1];
        ticketEconomy4.Contact__c = cont.Id;
        update ticketEconomy4;


        ticketEconomy4 = [SELECT Id,Flight_Info_Id__c FROM Ticket__c WHERE Contact__c = :cont.Id LIMIT 1];
        ticketEconomy4.Status__c = 'Completed';
        update ticketEconomy4;


        Test.startTest();
        Database.SaveResult result1 = Database.update(aircraft, false);
        Database.SaveResult result2 = Database.update(flightInfo, false);
        Database.SaveResult result3 = Database.update(flightInfoTwo, false);
        Database.SaveResult result31 = Database.update(flightInfoThree, false);
        Database.SaveResult result4 = Database.update(cont, false);
        Database.SaveResult result5 = Database.update(ticketBusiness, false);
        Database.SaveResult result6 = Database.update(ticketEconomy, false);
        Database.SaveResult result62 = Database.update(ticketEconomy2, false);
        Database.SaveResult result311 = Database.update(ticketBusiness31, false);
        Test.stopTest();


        System.assert(result1.isSuccess());
        System.assert(result2.isSuccess());
        System.assert(result3.isSuccess());
        System.assert(result31.isSuccess());
        System.assert(result4.isSuccess());
        System.assert(result5.isSuccess());
        System.assert(result6.isSuccess());
        System.assert(result62.isSuccess());

        System.debug(result1.getErrors() + 'No errors');
        System.debug(result2.getErrors() + 'No errors');
        System.debug(result3.getErrors() + 'No errors');
        System.debug(result31.getErrors() + 'No errors');
        System.debug(result4.getErrors() + 'No errors');
        System.debug(result5.getErrors() + 'No errors');
        System.debug(result6.getErrors() + 'No errors');
        System.debug(result62.getErrors() + 'No errors');

//        System.assertEquals('This flight started or finished',result311.getErrors()[0].getMessage());
//        System.assertNotEquals('This flight started or finished',result311.getErrors()[0].getMessage());
//        try {
//            insert records;
//            System.assert(false, 'Should fail, because.....');
//        } catch (Exception e) {
//
//        }

    }
}