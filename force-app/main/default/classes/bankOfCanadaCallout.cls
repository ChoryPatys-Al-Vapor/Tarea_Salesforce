public with sharing class bankOfCanadaCallout {
    public void BankCallout(){
        String Endpoint = bankOfCanadaHandler.endpointHandler();

        Http message = new Http();
        HttpRequest request= new HttpRequest();

        request.setEndpoint(Endpoint);
        request.setMethod('GET');

        HttpResponse response = message.send(request);

        System.debug(response);

        bankOfCanadaHandler.responseParser(response);
    }
}
