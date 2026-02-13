public with sharing class bankOfCanadaTriggerHandler {
    public static void toQueue(List<Rates__c> older, List<Rates__c> newer){
        if(older.size() == 1 && newer.size() == 1){
            System.debug('also');
            bankOfCanadaCallout callout = new bankOfCanadaCallout();
            System.enqueueJob(callout);
        }
        return;
    }
}