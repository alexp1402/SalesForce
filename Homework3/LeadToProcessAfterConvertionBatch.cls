public class LeadToProcessAfterConvertionBatch implements Database.Batchable<sObject>, Schedulable{
    private String query = 'SELECT id, email, convertedaccountid FROM lead WHERE NeedToProcess__c = TRUE';
    
    public void execute(System.SchedulableContext SC){
        //run every hour and execute batch
        ID batchprocessid = Database.executeBatch(new LeadToProcessAfterConvertionBatch(),1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext BC, List<lead> leads){
        //receive leads where NeedToProcess is TRUE
        List<Account> accountsToUpdate = new List<Account>();

       	List<String> processedId = new List<String>();
        //catch all exception and store error in ErrorLogger
        try{

        	for(Lead lead: leads){
            	//update email in account and add it to accountList
				Account account = new Account();
            	account.id = lead.ConvertedAccountId;
            	account.email__c = lead.Email; 
            	accountsToUpdate.add(account);
            	processedId.add(lead.Id);
 	        }
        
        	Database.SaveResult[] result = Database.update(accountsToUpdate, true);
            saveResultHandler(result, leads);

            
        	}catch(Exception error){
            	//if an error occured store all info in ErrorLogger
            	ErrorLogger__c logger = new ErrorLogger__c();
            	logger.ErrorType__c = 'Update.DataBase error';
            	logger.ErrorMessage__c = error.getMessage();
            	logger.StackTrace__c = error.getStackTraceString();
            	logger.NotProcessingData__c = String.join(processedId, ';');	
            	insert(logger);
        }
       
    }
    
    public void finish(Database.BatchableContext BC){
        
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

}