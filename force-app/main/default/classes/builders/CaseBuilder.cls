public with sharing class CaseBuilder {
    private Case caseRecord;

    private CaseBuilder() {
        caseRecord = new Case();
    }

    public static CaseBuilder create() {
        return new CaseBuilder();
    }

    public CaseBuilder withSubject(String subject) {
        caseRecord.Subject = subject;
        return this;
    }

    public CaseBuilder withStatus(String status) {
        caseRecord.Status = status;
        return this;
    }

    public CaseBuilder withOrigin(String origin) {
        caseRecord.Origin = origin;
        return this;
    }

    public CaseBuilder withPriority(String priority) {
        caseRecord.Priority = priority;
        return this;
    }

    public CaseBuilder withDescription(String description) {
        caseRecord.Description = description;
        return this;
    }

    public Case build() {
        return caseRecord;
    }
}