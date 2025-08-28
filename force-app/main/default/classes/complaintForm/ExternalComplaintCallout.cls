public class ExternalComplaintCallout implements Queueable, Database.AllowsCallouts {
    private Map<String, String> externalComplaintEvents;
    private UUID randomUUID;

    public ExternalComplaintCallout(Map<String, String> externalComplaintEvents, UUID randomUUID) {
        this.externalComplaintEvents = externalComplaintEvents;
        this.randomUUID = randomUUID;
    }

    public static void sendComplaintsAsync(Map<String, String> externalComplaintEvents, UUID randomUUID) {
        if (externalComplaintEvents != null && !externalComplaintEvents.isEmpty()) {
            System.enqueueJob(new ExternalComplaintCallout(externalComplaintEvents, randomUUID));
        }
    }

    public void execute(QueueableContext context) {
        SendProductComplaintsBatchJob batchJob = new SendProductComplaintsBatchJob(this.externalComplaintEvents, this.randomUUID);
        System.debug(this.externalComplaintEvents);
        Database.executeBatch(batchJob, 1);
    }
}