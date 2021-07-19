public class LeadsWrapper {
    
    public String leadId;
    public String convertedAccountId;
    
    public List<FieldWrapper> fields;
    
    public LeadsWrapper(String leadId, String convertedAccountId, List<FieldWrapper> fields){
        this.leadId = leadId;
        this.convertedAccountId = convertedAccountId;
        this.fields = fields;
    }

}