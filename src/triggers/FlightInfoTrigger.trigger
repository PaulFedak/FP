/**
 * Created by User on 07.01.2022.
 */

trigger FlightInfoTrigger on Flight_Info__c (
        before insert,
        before update,
        before delete,
        after insert,
        after update,
        after delete,
        after undelete) {
    FlightInfoTriggerHandler.handle(Trigger.new,Trigger.oldMap, Trigger.operationType);
}