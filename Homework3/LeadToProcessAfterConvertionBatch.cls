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
        List<Lead> leadsToChangeFlag = new List<Lead>();
        List<String> processedId = new List<String>();
        for(Lead lead: leads){
            //update email in account and add it to accountList
			Account account = new Account();
            account.id = lead.ConvertedAccountId;
            account.email__c = lead.Email; 
            accountsToUpdate.add(account);
            
            Lead leadWithFlag = new Lead();
            leadWithFlag.id = lead.id;
            leadWithFlag.NeedToProcess__c = false;
            leadsToChangeFlag.add(leadWithFlag);
            processedId.add(lead.Id);
            
        }
        
        //try to update once all account
        try{
            //Database.SaveResult result =
            Database.update(accountsToUpdate, true);
            //if all good make NeedToProcess flag false
          	update(leadsToChangeFlag);
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


}