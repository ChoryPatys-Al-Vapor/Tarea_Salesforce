public with sharing class bankOfCanadaHandler {
    public static Rates__c COINS = [SELECT currencies__c FROM Rates__c];
    //Queries currently selected currencies

    public static List<String> currencySeparator(){
        List<String> currencies = COINS.currencies__c.split(';');
        //Since it is a Multichoice Picklist, the options are all in a single String, separated by ';'
        //So I need to separate each individual selected option

        String[] chosen = new List<String>();

        for(integer i = 0; i < currencies.size(); i++){
            for(integer p = 0; p < currencies.size(); p++){
                if(p != i){
                    chosen.add('FX' + currencies[i] + currencies[p]); 
                }
            }
        }
        //These two loops are used to construct the ENDPOINT, as I need to ask for every combination of the chosen currencies.

        //i represents the current currency on the list, and p represents all the posible combinations, excluding two of the same.

        //This lets me change the currencies to used by just adding a field on the Rates__c object and choosing it in the multiselect Picklist without adding code.
        return chosen;


    }

    public static String endpointHandler(){
        List<String> chosen = currencySeparator();

        System.debug(chosen);
        String toBeCalled = String.join(chosen, '%2C');
        //Setting currencies to call

        System.debug(toBeCalled);

        String Endpoint = ('https://www.bankofcanada.ca/valet/observations/' + toBeCalled + '/json?recent=1');
        return Endpoint;
    }

    public static void responseParser(HttpResponse response){
        String body = response.getBody();
        if (response.getStatusCode() == 200) {
            /*Type resultType = Type.forName('Observations');
            observations deserialized = (observations)Json.deserialize(body, resultType);
            System.debug(deserialized);*/

            Map<String,Object> deserializedResults = (Map<String,Object>)JSON.deserializeUntyped(body);
            List<Object> observations = (List<Object>)deserializedResults.get('observations');

            System.debug(observations);
            
            Map<String,Object> values = new Map<String,Object>();

            
            for(Object currencies : observations){
                values = (map<String,Object>)currencies;
            }

            System.debug(values);

            rates__c rates = new rates__c();

            for(String field : values.keySet()){
                if(field != 'd'){
                    Object middle = values.get(field);
                    System.debug(middle);
                    Map<String,Object> finalesad = (Map<String,Object>)middle;
                    System.debug(finalesad.get('v'));

                    Double rate = Double.valueOf(finalesad.get('v'));
                    
                    rates.put(field + '__c', rate);
                }
                /*else{
                    Map<Strin
                    tester.put('LastUpdated__c', )
                }*/
            }
            System.debug(rates);
            rates.currencies__c = COINS.currencies__c;
            delete COINS;
            insert rates;
        }
    }

    /*public with sharing class Observations{
        public Map<String,Object> values;
        public observations(){}
    }*/
}