public with sharing class bankOfCanadaHandler {

    public static List<currencies__c> COINS = [SELECT name FROM currencies__c];
    //Queries currently selected currencies

    public static List<String> currencySeparator(List<currencies__c> currencies){
        String[] chosen = new List<String>();

         for(currencies__c money : currencies){
            if(money.name != 'CAD'){
                chosen.add('FXCAD' + money.name);
                chosen.add('FX' + money.name + 'CAD');
            }
        }
        System.debug(chosen);
        return chosen;
    }

    public static String endpointHandler(){
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
            Map<String,Object> deserializedResults = (Map<String,Object>)JSON.deserializeUntyped(body);
            List<Object> observations = (List<Object>)deserializedResults.get('observations');

            System.debug(observations);
            
            Map<String,Object> values = new Map<String,Object>();

            rates__c[] ratesToInsert = new List<rates__C>();


            //Because of the way the API works, if a currency is no longer supported, you will still be able to retrieve it's rates, they'll just be from another date.
            //Due to this fact and the way the JSON is designed, these dates will be separated into different 'observation' objects.
            //So I can garantee that both, the code won't throw an exception if a coin is no longer supported and that if it ever comes back, it will just work like normal again.


            //Iterating over every 'observation object'
                //This object contains a 'd' key (which contains the date of the conversion) and plenty FX(coin1)(coin2)
            for(Object currencies : observations){
                values = (map<String,Object>)currencies;
                System.debug(values); 
                
                String dateOfConversion;
                //Allows me to keep track of the currencies in this object.
                String[] coinsPerObject = new List<String>();
                rates__c[] ratesPerObject = new List<rates__c>();

                for(String field : values.keySet()){
                    Switch on field{
                        when 'd'{
                            dateOfConversion = (String)values.get(field);
                        }
                        when else{
                            Object middle = values.get(field);
                            System.debug(middle);
                            Map<String,Object> finalesad = (Map<String,Object>)middle;
                            System.debug(finalesad.get('v'));

                            String originalCurrency = field.substring(2,5);
                            String objectiveCurrency = field.substring(5,8);
                            Double rate = Double.valueOf(finalesad.get('v'));
                            rates__c rates = new rates__c(
                                name = (dateOfConversion + ' ' + originalCurrency + ' to ' + objectiveCurrency),
                                from__c = originalCurrency,
                                to__c = objectiveCurrency,
                                LastUpdated__c = date.valueOf(dateOfConversion),
                                conversion_Rate__c = rate
                            );

                            ratesPerObject.add(rates);
                            System.debug(rates);

                            coinsPerObject.add(originalCurrency);
                        }
                    }
                }
                
                //Here I save a 'Base' rate, which is the rate between one coin and 'CAD'.
                    //With this I aim to keep a base rate upon which to go from when changing into other currencies.
                        //EX: if 'USD' to 'CAD' has a rate of 1.5 and 'CAD' to 'MXN' has a rate of 2, then the formula needed to find the rate between 'USD' and 'MXN' is 1.5 * 2.
                for(String coin : coinsPerObject){
                    Double fromRate, toRate;

                    for(rates__c newRates : ratesPerObject){
                        if(newRates.from__c == coin){
                            fromRate = newRates.conversion_Rate__c;
                        }else if(newRates.to__c == coin){
                            toRate = newRates.conversion_Rate__c;
                        }
                    }
                    

                    rates__c[] combinationRates = new List<rates__c>();

                    //Here I decided to calculate the rate between different coins that do not involve the 'CAD'.
                        //For more info, see the previous comment.
                    for(rates__c newRates : ratesPerObject){
                        if(newRates.from__c == coin || newRates.to__c == coin){
                            continue;
                        }else if(newRates.from__c == 'CAD'){
                            rates__c extraRates = new rates__c(
                                name = (dateOfConversion + ' ' + coin + ' to ' + newRates.to__c),
                                from__c = coin,
                                to__c = newRates.to__c,
                                LastUpdated__c = newRates.LastUpdated__c,
                                conversion_Rate__c = (fromRate * newRates.conversion_Rate__c)
                            );  
                            System.debug(newRates.to__c);
                            System.debug(extraRates);
                            combinationRates.add(extraRates);
                        }
                    }
                    ratesPerObject.addAll(combinationRates);
                }
                ratesToInsert.addAll(ratesPerObject);
            }
            for(rates__c debugger : ratesToInsert){
                System.debug(debugger);
            }
            upsert ratesToInsert name;
        }
    }
}