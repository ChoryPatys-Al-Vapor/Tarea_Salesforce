//Since there are about 23 available currencies to be retrieved from the BankOfCanada, that means we have about 2^23 or more than 8 Million possible combinations.
//That number of records would place us way past the limit of 10000 records modified in the same DML statement.
//So by using an Iterable, we can set an scope of 10000 records, and modify them at the same time, allowing us to process a combination of all the currencies with no problem.

public with sharing class bankOfCanadaRatesUpserterBatch implements Database.Batchable<rates__c>{
    public List<rates__c> rates;
    public bankOfCanadaRatesUpserterBatch(List<rates__c> toBeInserted){
        rates = toBeInserted;
    }

    public Iterable<rates__c> start(Database.BatchableContext info){
        return rates;
    }

    public void execute(Database.BatchableContext info, List<rates__c> scope){
        upsert scope;
    }
    
    public void finish(Database.BatchableContext info){

    }
}   