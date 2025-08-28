public class ComplaintSubmissionResult {
    @AuraEnabled
    public Id caseId { get; set; }

    @AuraEnabled
    public String uuid { get; set; }

    public ComplaintSubmissionResult(Id caseId, String uuid) {
        this.caseId = caseId;
        this.uuid = uuid;
    }
}