trigger ContactTrigger on Contact (before insert, after insert) {
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            Database.executeBatch(new OpportunityContactMatcher(Trigger.new));
        }
    }
}