public class PlatformEventLeadChangedHandler extends EventTriggerHandler {
    
    public override void afterInsert() {
        System.debug('PlatformEvent');
        //get all PlatformEvent
        List<LeadChanged__e> listEventLeadChanged = Trigger.new;
        //get each RawData from PE
        List<String> rawData = getRawData(listEventLeadChanged);
        
        System.debug('Rawdata-'+rawData);
        //deserialize RawData in Wrapper
        List<LeadsWrapper> leadsWrapper = getLeads(rawData);
        //make needed changes for account
        makeChanges(leadsWrapper);
        
    }

    public List<String> getRawData(List<LeadChanged__e> listEvent){
        List<String> raw = new List<String>();
        for(LeadChanged__e event: listEvent){
            raw.add(event.RawData__c);
        }  
        return raw;
    }
    
    public List<LeadsWrapper> getLeads(List<String> rawData){
        List<LeadsWrapper> leads = new List<LeadsWrapper>();
        for(String msg:rawData){
            LeadsWrapper wrapper = (LeadsWrapper) JSON.deserialize(msg, LeadsWrapper.class);
            leads.add(wrapper);
        }
        return leads;
    }
    
    public void makeChanges(List<LeadsWrapper> leads){
        List<Account> listAccount = new List<Account>();
        for(LeadsWrapper wrapper : leads){
            Account account = new Account();
            account.id = wrapper.convertedAccountId;
            
            for(FieldWrapper field : wrapper.fields){
                if (field.fieldApiName == 'Phone'){
                    account.Phone = field.fieldValue;
                }
                if (field.fieldApiName == 'Description'){
                    account.Description = field.fieldValue;
                }    
            }
            listAccount.add(account);
        }
        update listAccount;
    }
}