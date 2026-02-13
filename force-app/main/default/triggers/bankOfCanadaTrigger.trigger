trigger bankOfCanadaTrigger on Rates__c (before update) {
    switch on Trigger.operationType{
        when BEFORE_UPDATE { 
            System.debug('working');
            bankOfCanadaTriggerHandler.toQueue(Trigger.old, Trigger.new);
        }
    }
}