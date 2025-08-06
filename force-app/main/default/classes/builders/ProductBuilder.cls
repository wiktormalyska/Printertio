public class ProductBuilder {
    private Product2 product;

    private ProductBuilder() {
        this.product = new Product2();
    }

    public static ProductBuilder create() {
        return new ProductBuilder();
    }

    public ProductBuilder withName(String name) {
        this.product.Name = name;
        return this;
    }

    public ProductBuilder withIsActive(Boolean isActive) {
        this.product.IsActive = isActive;
        return this;
    }

    public ProductBuilder withProductCode(String productCode) {
        this.product.ProductCode = productCode;
        return this;
    }

    public ProductBuilder withDescription(String description) {
        this.product.Description = description;
        return this;
    }

    public Product2 build() {
        return this.product;
    }
}