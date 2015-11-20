# OpportunityContactMatcher
Asynchronously fills in OpportunityContactRoles whenever they are missing on Contact or Opportunity insert

The main component of this project is the OpportunityContactMatcher class, which is initialized as asynchronous batch apex when a contact or opportunity 
is inserted.  The class will determine whether an OpportunityContactRole already exists for the related Opportunities or Contacts that were inserted (such as 
when they are created from the GUI), and will only insert a new role where one does not already exist. The code currently pulls the default Role name and
does not set the newly created role as primary, but this can be modified to suit your needs in the createContactRole() method.
