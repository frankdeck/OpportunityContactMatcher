@isTest
private class testOpportunityContactMatcher {

    private static testMethod void accountIdMatches(){
        
        Account a1 = new Account(Name = 'a1');
        insert a1;
        Account a2 = new Account(Name = 'a2');
        insert a2;
        
        Opportunity o1 = new Opportunity(Name = 'o1', CloseDate = Date.today(), StageName = 'test', AccountId = a1.Id);
        Contact c1 = new Contact(LastName = 'c1', AccountId = a1.Id);
        Contact c2 = new Contact(LastName = 'c2', AccountId = a2.Id);
        
        OpportunityContactMatcher ocm = new OpportunityContactMatcher(new List<contact>());
        
        System.assert(ocm.accountIdMatches(c1,o1), 'accountIdMatches returns true when the opportunity and contact have the same accountId');
        System.assert(!ocm.accountIdMatches(c2,o1), 'accountIdMatches returns false when the opportunity and contact have the different accountId');
    }
    
    private static testMethod void getDefaultRoleName(){
        OpportunityContactMatcher ocm = new OpportunityContactMatcher(new List<contact>());
        
        String defaultRoleName = ocm.getDefaultRoleName();
        System.assertNotEquals(null, defaultRoleName, 'defaultRoleName returns a non-null value');
    }
    
    private static testMethod void getExistingRoles(){
        
        Contact c1 = new Contact(LastName = 'c1');
        insert c1;
        List<Contact> contacts = new List<Contact>();
        contacts.add(c1);
        
        Opportunity o1 = new Opportunity(Name = 'o1', CloseDate = Date.today(), StageName = 'test');
        insert o1;
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(o1);
        
        OpportunityContactRole ocr1 = new OpportunityContactRole(ContactId = c1.Id, OpportunityId = o1.Id);
        insert ocr1;
        
        OpportunityContactMatcher ocm = new OpportunityContactMatcher(new List<contact>());
        
        List<OpportunityContactRole> ocrs = ocm.getExistingRoles(contacts, opps);
        
        System.assertEquals( 1, ocrs.size(), 'A single OpportunityContactRole is returned');
        OpportunityContactRole role = ocrs[0];
        System.assertEquals(c1.Id, role.ContactId, 'The ContactId of the role returned matches the Contact.Id providede');
        System.assertEquals(o1.Id, role.OpportunityId, 'The OpportunityId of the role returned matches the Opportunity.Id provided');
    }
            
    private static testMethod void existingMatch(){
        
        Contact c1 = new Contact(LastName = 'c1');
        insert c1;
        Contact c2 = new Contact(LastName = 'c2');
        insert c2;
        
        Opportunity o1 = new Opportunity(Name = 'o1', CloseDate = Date.today(), StageName = 'test');
        insert o1;
        Opportunity o2 = new Opportunity(Name = 'o2', CloseDate = Date.today(), StageName = 'test');
        insert o2;
        
        List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
        OpportunityContactRole ocr1 = new OpportunityContactRole(ContactId = c1.Id, OpportunityId = o1.Id);
        ocrs.add(ocr1);
        
        OpportunityContactMatcher ocm = new OpportunityContactMatcher(new List<contact>());
        
        System.assert(ocm.existingMatch(c1, o1, ocrs), 'existingMatch returns true when an OpportunityContactRole exists with both the ContactId and the OpportunityId');
        System.assert(!ocm.existingMatch(c1, o2, ocrs), 'existingMatch returns false when an OpportunityContactRole only exists matching the ContactId and not the OpportunityId');
        System.assert(!ocm.existingMatch(c2, o1, ocrs), 'existingMatch returns false when an OpportunityContactRole only exists matching the OpportunityId and not the ContactId');
        System.assert(!ocm.existingMatch(c2, o2, ocrs), 'existingMatch returns false when an OpportunityContactRole does not exist matching either the ContactId or the OpportunityId');
    }
    
    private static testMethod void createContactRole(){
        
        Contact c1 = new Contact(LastName = 'c1');
        insert c1;
        Opportunity o1 = new Opportunity(Name = 'o1', CloseDate = Date.today(), StageName = 'test');
        insert o1;
        
        OpportunityContactMatcher ocm = new OpportunityContactMatcher(new List<contact>());
        OpportunityContactRole ocr = ocm.createContactRole(c1, o1);
        
        System.assertEquals(c1.Id, ocr.ContactId, 'The OpportunityContactRole created has a matching ContactId');
        System.assertEquals(o1.Id, ocr.OpportunityId, 'The OpportunityContactRole  created has a matching OpportunityId');
        System.assertNotEquals(null, ocr.Role, 'The OpportunityContactRole created has a "Role" value that is not null');
    }
        
    //End-to-end test for Contact insert
    private static testMethod void testContactInsert(){
        
        Account a1 = new Account(Name = 'a1');
        insert a1;
        Account a2 = new Account(Name = 'a2');
        insert a2;
        
        Opportunity o1 = new Opportunity(Name = 'o1', CloseDate = Date.today(), StageName = 'test', AccountId = a1.Id);
        insert o1;
        Opportunity o2 = new Opportunity(Name = 'o2', CloseDate = Date.today(), StageName = 'test', AccountId = a1.Id);
        insert o2;
        
        Contact c1 = new Contact(LastName = 'c1', AccountId = a1.Id);
        Contact c2 = new Contact(LastName = 'c2', AccountId = a1.Id);
        Contact c3 = new Contact(LastName = 'c3', AccountId = a2.Id);
        
        Test.startTest();
        
        insert c1;
        insert c2;
        insert c3;
        
        Test.stopTest();
        
        List<OpportunityContactRole> c1Roles = [SELECT ContactId, OpportunityId FROM OpportunityContactRole WHERE ContactId = : c1.Id];
        List<OpportunityContactRole> c2Roles = [SELECT ContactId, OpportunityId FROM OpportunityContactRole WHERE ContactId = : c2.Id];
        List<OpportunityContactRole> c3Roles = [SELECT ContactId, OpportunityId FROM OpportunityContactRole WHERE ContactId = : c3.Id];

        System.assertEquals(2, c1Roles.size(), 'Two OpportunityContactRoles created for c1 Contact');
        System.assertEquals(2, c2Roles.size(), 'Two OpportunityContactRoles created for c2 Contact');
        System.assertEquals(0, c3Roles.size(), 'No OpportunityContactRoles created for c3 Contact');
    }
    
    //End-to-end test for Opportunity insert
    private static testMethod void testOpportunityInsert(){
        
        Account a1 = new Account(Name = 'a1');
        insert a1;
        Account a2 = new Account(Name = 'a2');
        insert a2;
        
        Contact c1 = new Contact(LastName = 'c1', AccountId = a1.Id);
        insert c1;
        Contact c2 = new Contact(LastName = 'c2', AccountId = a1.Id);
        insert c2;
        Opportunity o1 = new Opportunity(Name = 'o1', CloseDate = Date.today(), StageName = 'test', AccountId = a1.Id);
        Opportunity o2 = new Opportunity(Name = 'o2', CloseDate = Date.today(), StageName = 'test', AccountId = a1.Id);
        Opportunity o3 = new Opportunity(Name = 'o3', CloseDate = Date.today(), StageName = 'test', AccountId = a2.Id);
                
        Test.startTest();
        
        insert o1;
        insert o2;
        insert o3;
        
        Test.stopTest();
        
        List<OpportunityContactRole> o1Roles = [SELECT ContactId, OpportunityId FROM OpportunityContactRole WHERE OpportunityId = : o1.Id];
        List<OpportunityContactRole> o2Roles = [SELECT ContactId, OpportunityId FROM OpportunityContactRole WHERE OpportunityId = : o2.Id];
        List<OpportunityContactRole> o3Roles = [SELECT ContactId, OpportunityId FROM OpportunityContactRole WHERE OpportunityId = : o3.Id];
        
        System.assertEquals(2, o1Roles.size(), 'Two OpportunityContactRoles created for o1 Opportunity');
        System.assertEquals(2, o2Roles.size(), 'Two OpportunityContactRoles created for o2 Opportunity');
        System.assertEquals(0, o3Roles.size(), 'No OpportunityContactRoles created for o3 Opportunity');
    }
}