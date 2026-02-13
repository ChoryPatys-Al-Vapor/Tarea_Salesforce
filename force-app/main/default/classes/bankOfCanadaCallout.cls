public with sharing class bankOfCanadaCallout implements Queueable, Database.AllowsCallouts {
    public static void execute(QueueableContext context){
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
