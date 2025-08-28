public with sharing class CaseTestDataFactory implements TestDataFactory {

    public SObject prepare() {
        return CaseBuilder.create()
                .withSubject('Test Case')
                .withStatus('New')
                .withOrigin('Phone')
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