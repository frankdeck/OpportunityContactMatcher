trigger ContactTrigger on Contact (after insert) {
    Database.executeBatch(new OpportunityContactMatcher(Trigger.new));
}