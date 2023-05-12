public with sharing class AccountPageExtension {  

    private ApexPages.StandardController std;
    private Account account;  
    public Id chosenContactId;  
    public Id deleteContactId;

    public List<Contact> contactsArray {get; set;}
  
    public AccountPageExtension(ApexPages.StandardController stdCtrl) {
        this.std = stdCtrl;
        // можемо отримати Акаунт зі стандартного контролера
        this.account = (Account) this.std.getRecord();
        // щоб витягнути Контакти потрібно використати query, overrides setter method
        this.contactsArray = [SELECT Id, FirstName, LastName FROM Contact WHERE AccountId = :this.account.Id];
    }

    public Id getChosenContactId(){
        return this.chosenContactId;
    }  

    public void setChosenContactId(Id pageContactId){ 
        this.chosenContactId = pageContactId;
    }  

    public Id getdeleteContactId(){
        return this.deleteContactId;
    }  
    
    public void setdeleteContactId(Id pageContactId){  
        this.deleteContactId = pageContactId;
    }  

    public void saveContact(){
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact c : contactsArray){
            if(c.Id == chosenContactId){
                contactsToUpdate.add(c);
            }
        }
        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }
    }

    public void deleteContact(){
        List<Contact> contactsToDelete = new List<Contact>();
        for(Contact c : contactsArray){
            if(c.Id == deleteContactId){
                contactsToDelete.add(c);
            }
        }
        if(!contactsToDelete.isEmpty()){
            delete contactsToDelete;
        }
    }

    @AuraEnabled
    public static List<Contact> getContacts(String accountId) {
        return [SELECT Id, FirstName, LastName FROM Contact WHERE AccountId = :accountId];
    }  

    @AuraEnabled
    public static Contact updateRelatedContact(Contact contact) {
        Contact existingContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contact.Id];
        existingContact.LastName = contact.LastName;
        update existingContact;
        return existingContact;
    }  

  }  