public with sharing class bankOfCanadaTriggerHandler implements Queueable, Database.AllowsCallouts {
    public static void execute(List<currencies__c> insertedCurrencies, QueueableContext ctx){
        try{
            List<String> fieldNames = bankOfCanadaHandler.currencySeparator(insertedCurrencies);

            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');

            req.setEndpoint('https://empathetic-goat-jgesbg-dev-ed.trailblaze.my.salesforce.com/services/data/v66.0/composite');

            Map<String,SObject> body = new Map<String,SObject>();
            body.put('compositeRequest', body);


            req.setBody(body);

            List<HttpRequest> subRequests = new List<HttpRequest>();
            for(currencies__c coins : insertedCurrencies){
                HttpRequest sub = new HttpRequest();
                sub.setMethod('GET');
                sub.setEndpoint('https://empathetic-goat-jgesbg-dev-ed.trailblaze.my.salesforce.com/services/data/v66.0/tooling/sobjects/rates__c.FXCAD' + coins.name);
            }
        }
    }
    
    public static void toQueue(){
        bankOfCanadaCallout callout = new bankOfCanadaCallout();
        System.enqueueJob(callout);
        return;
    }
}