public interface TestDataFactory {
    SObject prepare();
    SObject create();
    void save();
}