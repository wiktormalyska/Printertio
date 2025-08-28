public with sharing class CARTestDataFactory implements TestDataFactory {
    public SObject prepare() {
        return Complaint_Approval_Request_cBuilder.create()
                .withStatus('Pending Approval')
                .withAmountToRefund(100.00)
                .build();
    }

    public virtual SObject create() {
        return prepare();
    }

    public void save() {
        SObject caseRecord = create();
        insert caseRecord;
    }

}