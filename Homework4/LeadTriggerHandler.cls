public class LeadTriggerHandler extends TriggerHandler {
    

    protected override void beforeInsert() {
        
    }
    
    protected override void beforeUpdate() {
        //TASK3
        //check if isConverted before false and after update become true
        for(Id leadsId: Trigger.oldMap.keySet()){
            Lead oldLead = (Lead) Trigger.oldMap.get(leadsId);
            Lead newLead = (Lead) Trigger.newMap.get(leadsId);
            if(newLead.isConverted && !oldLead.IsConverted){
                //set NeedToProcess to TRUE
                newLead.NeedToProcess__c = true;
            }
        }
    }
    
    protected override void beforeDelete() {
        
    }
    
    protected override void afterInsert() {
        
    }
    
    protected override void afterUpdate() {

    }
    
    protected override void afterDelete() {
        
    }
    
    protected override void afterUndelete() {
        
    }
   
}