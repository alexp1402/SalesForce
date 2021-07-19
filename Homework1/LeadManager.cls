public class LeadManager {
    
    public static List<Lead> getLeadsByIds(Set<String> fieldApiNames, Set<Id> leadIds){

        List<String> fld = new List<String>(fieldApiNames);
      	String query = 'select '+ String.join(fld,',')+' from lead where id in:leadIds';  
//        System.debug('query:'+query);
        List<sObject> searchLeads = Database.query(query);
        return searchLeads;
    }

}