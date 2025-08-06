public interface ICondition {
    Boolean isApplicable(SObject record);
    String getName();
}