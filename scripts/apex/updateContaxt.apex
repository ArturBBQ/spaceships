
List<Contact> updContacts = new List<Contact>();

Integer count = 1;

for(Contact c: [Select Id, AvatarURL__c, Mercenary_Rate__c From Contact Where RecordType.DeveloperName = 'Mercenary']){

    c.AvatarURL__c = '/resource/avatars/' + count + '.png'; // field type URL
    c.Mercenary_Rate__c = count + 1000;  // field type currency
    c.Mercenary_Status__c = 'Available'; // field type picklist, values: Available, Busy

    count = (count < 8)? ++count : 1;
    
    updContacts.add(c);
}

update updContacts;