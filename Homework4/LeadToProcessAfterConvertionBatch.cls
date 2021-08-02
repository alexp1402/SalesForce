public class LeadToProcessAfterConvertionBatch implements Database.Batchable<sObject>, Schedulable{
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
            	ErrorLogger__c logger = new ErrorLogger__c();
            	logger.ErrorType__c = 'Update.DataBase error';
            	logger.ErrorMessage__c = error.getMessage();
            	logger.StackTrace__c = error.getStackTraceString();
            	logger.NotProcessingData__c = String.join(leads, ';');	
            	insert(logger);
        }
       
    }
    
    public void finish(Database.BatchableContext BC){

		Messaging.reserveSingleEmailCapacity(2);

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		// Strings to hold the email addresses to which you are sending the email.
		String[] toAddresses = new String[] {'leshii85@gmail.com'}; 

		// Assign the addresses for the To and CC lists to the mail object.
		mail.setToAddresses(toAddresses);
		//mail.setCcAddresses(ccAddresses);

		// Specify the address used when the recipients reply to the email. 
		//mail.setReplyTo('support@acme.com');

		// Specify the name used as the display name.
		mail.setSenderDisplayName('BaTCHER Leads processing');
        // Specify the subject line for your email address.
		mail.setSubject('Leads has been processed : ');

		// Set to True if you want to BCC yourself on the email.
		mail.setBccSender(false);

		// Optionally append the salesforce.com email signature to the email.
		// The email address of the user executing the Apex Code will be used.
		mail.setUseSignature(false);

		// Specify the text content of the email.
		mail.setPlainTextBody('Lead id: ididididididid - processed Lead id: ididididididdi - error');

		//mail.setHtmlBody('Your case:<b> ' + case.Id +' </b>has been created.<p>'+
     	//'To view your case <a href=https://yourInstance.salesforce.com/'+case.Id+'>click here.</a>');

		// Send the email you have created.
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        
    }
	
    public void saveResultHandler(Database.SaveResult[] results, List<lead> leads){
        integer i = 0;
        List<Lead> leadsToChangeFlag = new List<Lead>();
        List<Lead> failedLead = new List<Lead>();
        for(Database.SaveResult result: results){
            if (result.isSuccess()) {
                Lead leadWithFlag = new Lead();
            	leadWithFlag.id = leads[i].id;
            	leadWithFlag.NeedToProcess__c = false;
            	leadsToChangeFlag.add(leadWithFlag);
    		}else {
        	// Operation failed, so get all errors  
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
}