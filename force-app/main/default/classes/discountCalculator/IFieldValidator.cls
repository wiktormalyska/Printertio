public interface IFieldValidator {
    Decimal getFieldValue(Order order);
    String getApiName();
}