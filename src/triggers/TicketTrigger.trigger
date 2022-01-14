trigger TicketTrigger on Ticket__c (
        before insert,
        before update,
        before delete,
        after insert,
        after update,
        after delete,
        after undelete) {
    TicketTriggerHandler.handle(Trigger.new,Trigger.oldMap, Trigger.operationType);
}