@isTest
public class AccountPageExtension_Test {

    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'Skynet', BillingCity = 'Roboland', Starships_Number_Max__c = 5);
        insert acc;  
  
        List<Contact> contacts = new List<Contact>();
        for(Integer i=1; i<6; i++){
            contacts.add(new Contact(FirstName = 'robot', LastName = String.valueOf(i), AccountId = acc.Id));
        }
        insert contacts;
    }  
  
  @isTest 
  static void test1_initExtension() {  
    Account acc = [SELECT Id FROM Account WHERE Name = 'Skynet'][0];  
  
    Test.startTest();  
  
      ApexPages.currentPage().getParameters().put('id', acc.id);
      ApexPages.StandardController std = new ApexPages.StandardController(acc);
      AccountPageExtension ext = new AccountPageExtension(std);
      ext.chosenContactId = ext.contactsArray[0].Id;
      ext.saveContact();  
    
      Id contactToDelId = ext.contactsArray[1].Id;
      ext.deleteContactId = contactToDelId;
      ext.deleteContact(); 
      
      ext.setChosenContactId(contactToDelId);
      Id chosenContactId = ext.getChosenContactId();
      ext.setdeleteContactId(contactToDelId);
      Id deleteContactId = ext.getdeleteContactId();
    
      List<Contact> deletedContacts = [SELECT Id FROM Contact WHERE Id = :contactToDelId];
      System.assert(deletedContacts.isEmpty());

    Test.stopTest();
  }

  @isTest
    static void test_getContacts() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Skynet'][0];
        Test.startTest(); 
          List<Contact> contacts = AccountPageExtension.getContacts(acc.Id);
          System.assert(!contacts.isEmpty());
        Test.stopTest();
    }

    @isTest
    static void test_updateRelatedContact() {
        
        Contact con = [SELECT Id FROM Contact WHERE LastName = '1'][0];
        con.LastName = 'Smith';

        Test.startTest(); 
          Contact updatedContact = AccountPageExtension.updateRelatedContact(con);
        Test.stopTest();

        Contact databaseContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :con.Id];
        System.assertEquals('robot', databaseContact.FirstName);
        System.assertEquals('Smith', databaseContact.LastName);
    }

}  