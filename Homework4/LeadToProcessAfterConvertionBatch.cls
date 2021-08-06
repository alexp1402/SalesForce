public class LeadToProcessAfterConvertionBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    private static List<ID> updatedLeads = new List<Id>();
    private static List<ID> errorLeads = new List<Id>();
    
    private String query = 'SELECT id, email, phone, convertedaccountid FROM lead WHERE NeedToProcess__c = TRUE';
    
    public void execute(System.SchedulableContext SC){
        //run every hour and execute batch
        ID batchprocessid = Database.executeBatch(new LeadToProcessAfterConvertionBatch(),1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext BC, List<lead> leads){
        //receive leads where NeedToProcess is TRUE
        List<Lead> leadsToUpdate = new List<Lead>();

       	//List<String> processedId = new List<String>();
        
        //catch all exception and store error in ErrorLogger
        try{

        	for(Lead lead: leads){
                //get phone prefix
                String phonePrefix = getPhonePrefix(lead.Phone);
                //get country by prefix
                String country = getCountryByPrefix(phonePrefix);
            	//update Country_from_Phone__c in Lead and add it to leadList
				lead.Country_from_Phone__c = country; 
            	leadsToUpdate.add(lead);
            	//processedId.add(lead.Id);
 	        }
        
        	Database.SaveResult[] result = Database.update(leadsToUpdate, false);
            saveResultHandler(result, leads);

            
        	}catch(Exception error){
            	//if an error occured store all info in ErrorLogger
                for (Lead lead:leads){
            		errorLeads.add(lead.id);
                }
            	ErrorLogger__c logger = new ErrorLogger__c();
            	logger.ErrorType__c = 'Update.DataBase error';
            	logger.ErrorMessage__c = error.getMessage();
            	logger.StackTrace__c = error.getStackTraceString();
            	logger.NotProcessingData__c = String.join(leads, ';');	
            	insert(logger);
        }
       
    }
    
    public void finish(Database.BatchableContext BC){
		 if (updatedLeads.isEmpty() && errorLeads.isEmpty()) {
            return;
        }
        String[] emailResponde = new String[] { 'leshii85@gmail.com' };
        sendEmail(emailResponde);
        
    }
	
    public void saveResultHandler(Database.SaveResult[] results, List<lead> leads){
        integer i = 0;
        List<Lead> leadsToChangeFlag = new List<Lead>();
        List<Lead> failedLead = new List<Lead>();
        for(Database.SaveResult result: results){
            if (result.isSuccess()) {
                Lead leadWithFlag = new Lead();
               
                updatedLeads.add(leads[i].id);
            	leadWithFlag.NeedToProcess__c = false;
            	leadsToChangeFlag.add(leadWithFlag);
                
    		}else {
        	// Operation failed, so get all errors  
        		errorLeads.add(leads[i].id);
        		ErrorLogger__c logger = new ErrorLogger__c();
            	logger.ErrorType__c = 'SaveResult Errors';
        		for(Database.Error err : result.getErrors()) {
            		logger.ErrorMessage__c = logger.ErrorMessage__c +' '+ err.getStatusCode()+ ' ' + err.getMessage();                 
            		logger.StackTrace__c = logger.StackTrace__c + ' ' + err.getFields();
        		}
                logger.NotProcessingData__c = leads[i].id;
                insert(logger); 
    		}
            i++;
        }
        
        update(leadsToChangeFlag);
    }

    public String getPhonePrefix(String phone){
       return phone.substringBefore('-');
    }
    
    public String getCountryByPrefix(String prefix){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://restcountries.eu/rest/v2/callingcode/'+prefix+'?fields=name');
        HttpResponse response = http.send(request);
 
        List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
		//like [{"name":"Belarus"}]
        return (String) ((Map<String,Object>) results[0]).get('name');
    }
    
    private void sendEmail(String[] emails) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emails;
        message.subject = 'Lead after proccess from batch';
        message.plaintextbody = 'Successfull updated Leads (ID) count (' + updatedLeads.size() + '):' + String.join(updatedLeads, ', ') + '\n' + 
            'Lead with error count (' + errorLeads.size() + '):\n ID: ' + String.join(errorLeads, ', ');
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.sendEmail(messages);
    }
}