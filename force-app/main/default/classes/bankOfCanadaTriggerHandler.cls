public with sharing class bankOfCanadaTriggerHandler implements Queueable, Database.AllowsCallouts { 
    public static void toQueue(){
        bankOfCanadaCallout callout = new bankOfCanadaCallout();
        System.enqueueJob(callout);
        return;
    }
}