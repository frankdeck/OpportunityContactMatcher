trigger OpportunityTrigger on Opportunity (after insert) {
    Database.executeBatch(new OpportunityContactMatcher(Trigger.new));
}