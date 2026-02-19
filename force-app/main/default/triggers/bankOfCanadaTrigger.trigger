trigger bankOfCanadaTrigger on currencies__c (after insert) {
    switch on Trigger.operationType{
        when AFTER_INSERT { 
            bankOfCanadaTriggerHandler.toQueue();
        }
    }
}