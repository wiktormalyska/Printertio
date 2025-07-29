public class OrderInvoicePDFController {
    
    private final Order orderRecord;
    
    public OrderInvoicePDFController(ApexPages.StandardController controller) {
        this.orderRecord = (Order) controller.getRecord();
    }
    
    public String getSignatureUrl() {
        String signatureVersionId = ApexPages.currentPage().getParameters().get('signatureVersionId');

        if (String.isBlank(signatureVersionId)) {
            return null;
        }
        String finalUrl = 'https://orgfarm-6963239606-dev-ed--c.develop.vf.force.com/sfc/servlet.shepherd/version/download/' + signatureVersionId;
        return finalUrl;
    }
    
    public String getCompanySignatureName() {
        return 'CompanySignature';
    }
}