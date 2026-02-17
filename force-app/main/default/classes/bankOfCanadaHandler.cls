public with sharing class bankOfCanadaHandler {

    public static List<String> currencySeparator(List<currencies__c> COINS){
        String[] chosen = new List<String>();

         for(currencies__c money : COINS){
            if(money.name != 'CAD'){
                chosen.add('FXCAD' + money.name);
                chosen.add('FX' + money.name + 'CAD');
            }
        }
        System.debug(chosen);
        return chosen;
    }

    public static String endpointHandler(){
        List<currencies__c> COINS = [SELECT name FROM currencies__c];
        //Queries currently selected currencies

        List<String> chosen = currencySeparator(COINS);

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
            insert rates;
        }
    }

    /*public with sharing class Observations{
        public Map<String,Object> values;
        public observations(){}
    }*/
}