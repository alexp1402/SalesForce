public class ContactCustomCreateController {
    
    public Contact contact {set;get;}
    
    private Id accountId;
    private ApexPages.StandardController controller;
    
    //construct
    public ContactCustomCreateController(ApexPages.StandardController accStandardController){
        this.controller = accStandardController;
        this.accountId = (Id) accStandardController.getId();
    }
    
    public PageReference customContactSave(){
        PageReference pageRef;
        System.debug('Account Id - '+accountId);
        System.debug('Contact is - ' + contact);
        System.debug('Contact firstName - ' + this.contact.FirstName);
        System.debug('From controller - ' + controller.getRecord());
        try{
            
        	Contact newContact = new Contact(FirstName = contact.FirstName,
                                             LastName = contact.LastName,
                                             Phone = contact.Phone,
                                             Email = contact.Email,
                                             BirthDate = contact.Birthdate
                                            );
            newContact.AccountId = accountId;
        	insert newContact;
            
           
            //pageRef = (new ApexPages.StandardController(new Contact(Id = newContact.Id))).view();
            pageRef = (new ApexPages.StandardController(newContact)).view();
            pageRef.setRedirect(true);
            return pageRef;
        } catch(Exception e){
            //Dtabase.SaveResult ???
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ContactError));
            return null;          
        }
        
    }

}