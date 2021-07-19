public class LeadTriggerHandler extends TriggerHandler {
    

    protected override void beforeInsert() {
        
    }
    
    protected override void beforeUpdate() {
        
    }
    
    protected override void beforeDelete() {
        
    }
    
    protected override void afterInsert() {
        
    }
    
    protected override void afterUpdate() {
        //check if Phone or Description fields changed
        List<Lead> toUpdate = leadsToUpdate(Trigger.oldMap, Trigger.newMap);
        
        if(toUpdate.size()!=0 && toUpdate!=null){

        	//convert Leads to JSON String
        	
       	 	String msg = makeJSONString(toUpdate);
       	 	//call PlatformEvent
       	 	System.debug('JSON - '+msg);
        	callPlatformEvent(msg);
        }
        
    }
    
    protected override void afterDelete() {
        
    }
    
    protected override void afterUndelete() {
        
    }
    
    private List<Lead> leadsToUpdate(Map<Id, Sobject> oldMap, Map<Id, Sobject> newMap){
        List<Lead> leadToUpdate = new List<Lead>();
        for(Id leadId: oldMap.keySet()){
            Sobject oldLead = oldMap.get(leadId);
            Sobject newLead = newMap.get(leadId);
            if((oldLead.get('Phone') != newLead.get('Phone')) || (oldLead.get('Description') != newLead.get('Description'))){
                leadToUpdate.add((Lead) newLead);
            }
        }
      
        return leadToUpdate;
    }
    
    private void callPlatformEvent(String message){
        List<LeadChanged__e> pe = new List<LeadChanged__e>();
        pe.add(new LeadChanged__e(RawData__c=message));
        
        // Call method to publish events
		List<Database.SaveResult> results = EventBus.publish(pe);
 
		// Inspect publishing result for each event
		for (Database.SaveResult sr : results) {
    		if (sr.isSuccess()) {
        		System.debug('Successfully published event.');
   		 	} else {
        		for(Database.Error err : sr.getErrors()) {
            		System.debug('Error returned: ' +
            	            err.getStatusCode() +
            	            ' - ' +
           	             	err.getMessage());
        		}
    		}       
		}
     }
    
    private String makeJSONString(List<Lead> leads){
        List<LeadsWrapper> leadsWrapper = new List<LeadsWrapper>();
        for(Lead currentLead:leads){
            
            List<FieldWrapper> fields = new List<FieldWrapper>();
            fields.add(new FieldWrapper(currentLead.phone,'Phone'));
            fields.add(new FieldWrapper(currentLead.description,'Description'));
            
            leadsWrapper.add(new LeadsWrapper(currentLead.id, currentLead.ConvertedAccountId, fields));
        }
        
        return JSON.serialize(leadsWrapper);
    }
    
}