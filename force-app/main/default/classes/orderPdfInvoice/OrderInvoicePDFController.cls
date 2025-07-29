public class OrderInvoicePDFController {
    
    private final Order orderRecord;
    private String signatureUrl;

    
    public OrderInvoicePDFController(ApexPages.StandardController controller) {
        this.orderRecord = (Order) controller.getRecord();
        String signatureVersionId = ApexPages.currentPage().getParameters().get('signatureVersionId');

        if (String.isBlank(signatureVersionId)) {
            this.signatureUrl = null;
        }
        this.signatureUrl = 'https://orgfarm-6963239606-dev-ed--c.develop.vf.force.com/sfc/servlet.shepherd/version/download/' + signatureVersionId;
    }
    
    public String getSignatureUrl() {
        return this.signatureUrl;
    }
    
    public String getCompanySignatureName() {
        return 'CompanySignature';
    }
}