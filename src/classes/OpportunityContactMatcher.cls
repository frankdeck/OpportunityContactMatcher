global class OpportunityContactMatcher implements Database.Batchable<sObject> {

    global final List<Id> accountIds;
    global final String query;
    private	final Context processType;
    global List<Contact>     contacts;
    global List<Opportunity> opps;
    private Enum Context {CONTACT, OPPORTUNITY}

    public OpportunityContactMatcher(List<Contact> contactsToProcess) {
        List<Id> ids = new List<Id>();
        for (Contact c : contactsToPRocess) {
            ids.add(c.AccountId);
        }
        contacts = contactsToProcess;
        accountIds = ids;
        processType = Context.CONTACT;
        query = 'SELECT Id, AccountId FROM Opportunity WHERE AccountId IN : accountIds';
    }

    public OpportunityContactMatcher(List<Opportunity> oppsToProcess) {
        List<Id> ids = new List<Id>();
        for (Opportunity o : oppsToProcess) {
            ids.add(o.AccountId);
        }
        opps = oppsToProcess;
        accountIds = ids;
        processType = Context.OPPORTUNITY;
        query = 'SELECT Id, AccountId FROM Contact WHERE AccountId IN : accountIds';
    }

    @TestVisible
    private List<OpportunityContactRole> getExistingRoles(List<Contact> contacts, List<Opportunity> opps) {
        return [SELECT ContactId, OpportunityId
                FROM OpportunityContactRole
                WHERE ContactId IN :contacts OR OpportunityId IN :opps];
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
        return c.AccountId == o.AccountId;
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
        return new OpportunityContactRole(ContactId = c.Id, OpportunityId = o.Id, Role = getDefaultRoleName(), IsPrimary = true);
    }

    @TestVisible
    private String getDefaultRoleName() {
        String roleName = '';
        List<Schema.PicklistEntry> ples = OpportunityContactRole.Role.getDescribe().getPicklistValues();
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
        if (processType == Context.CONTACT) {
            opps = scope;
        }
        else {
            contacts = scope;
        }
        List<OpportunityContactRole> rolesToInsert = getRolesToInsert(contacts, opps, getExistingRoles(contacts, opps));
        if (!rolesToInsert.isEmpty()){
            insert rolesToInsert;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Required for the Database.Batchable interface
    }
}
