global class OpportunityContactMatcher implements Database.Batchable<sObject> {

    global final List<Id>          accountIds;
    global final String            query;
    global final Boolean           processingContacts;
    global       List<Contact>     contacts;
    global       List<Opportunity> opps;

    public OpportunityContactMatcher(List<Contact> contactsToProcess) {
        List<Id> ids = new List<Id>();
        for (Contact c : contactsToPRocess) {
            ids.add(c.AccountId);
        }
        contacts = contactsToProcess;
        accountIds = ids;
        processingContacts = true;
        query = 'SELECT Id, AccountId FROM Opportunity WHERE AccountId IN : accountIds';
    }
        
    public OpportunityContactMatcher(List<Opportunity> oppsToProcess) {
        List<Id> ids = new List<Id>();
        for (Opportunity o : oppsToProcess) {
            ids.add(o.AccountId);
        }
        opps = oppsToProcess;
        accountIds = ids;
        processingContacts = false;
        query = 'SELECT Id, AccountId FROM Contact WHERE AccountId IN : accountIds';
    }
    
    @TestVisible
    private List<OpportunityContactRole> getExistingRoles(List<Contact> contacts, List<Opportunity> opps) {
        List<OpportunityContactRole> existingRoles = [SELECT ContactId, OpportunityId 
                                                      FROM OpportunityContactRole 
                                                      WHERE ContactId IN : contacts 
                                                      OR OpportunityId IN : opps];
        return existingRoles;
    }
    
    @TestVisible
    private List<OpportunityContactRole> getRolesToInsert(List<Contact> contacts, List<Opportunity> opps, List<OpportunityContactRole> existingRoles) {
        List<OpportunityContactRole> rolesToReturn = new List<OpportunityContactRole>();
        for (Contact c : contacts) {
            for (Opportunity o : opps) {
                if (accountIdMatches(c, o) && !existingMatch(c, o, existingRoles)) {
                    rolesToReturn.add(createContactRole(c, o));
                }
            }
        }
        return rolesToReturn;
    }
    
    @TestVisible
    private Boolean accountIdMatches(Contact c, Opportunity o) {
        if (c.AccountId == o.AccountId) {
            return true;
        }
        return false;
    }
    
    @TestVisible
    private Boolean existingMatch(Contact c, Opportunity o, List<OpportunityContactRole> existingRoles) {
        for (OpportunityContactRole ocr : existingRoles) {
            if (ocr.ContactId == c.Id && ocr.OpportunityId == o.Id) {
                return true;
            }
        }
        return false;
    }
    
	@TestVisible
    private OpportunityContactRole createContactRole(Contact c, Opportunity o) {
        String defaultRoleName = getDefaultRoleName();
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = c.Id, OpportunityId = o.Id, Role = defaultRoleName,IsPrimary = true);
        return ocr;
    }
    
    @TestVisible
    private String getDefaultRoleName() {
        String roleName = '';
        Schema.DescribeFieldResult fieldResult = OpportunityContactRole.Role.getDescribe();
        List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry ple : ples) {
            if(ple.isActive()) {
                roleName = ple.getValue();
                if(ple.isDefaultValue()) {
                    break;
                }
            }
        }
        return roleName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (processingContacts) {
            opps = scope;
        }
        else {
            contacts = scope;
        }
        List<OpportunityContactRole> existingRoles = getExistingRoles(contacts, opps);
        List<OpportunityContactRole> rolesToInsert = getRolesToInsert(contacts, opps, existingRoles);
        if (!rolesToInsert.isEmpty()){
            insert rolesToInsert;
        }
    }

    global void finish(Database.BatchableContext BC) {}
}