public class ContactCustomCreateController {
    
    public Contact contact {set;get;}
    
    private Id accountId;
    private ApexPages.StandardController controller;
    
    
    public ContactCustomCreateController(ApexPages.StandardController accStandardController){
 contact = new Contact();        this.controller = accStandardController;
        this.accountId = (Id) accStandardController.getId();
    }
    
    public PageReference customContactSave(){
        PageReference pageRef;
       
        try{
        	Contact newContact = new Contact(FirstName = contact.FirstName,
                                             LastName = contact.LastName,
                                             Phone = contact.Phone,
                                             Email = contact.Email,
                                             BirthDate = contact.Birthdate
                                            );
            newContact.AccountId = accountId;
        	insert newContact;

            pageRef = (new ApexPages.StandardController(newContact)).view();
            pageRef.setRedirect(true);
            return pageRef;
        } catch(Exception e){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ContactError));
            return null;          
        }
        
    }

}
