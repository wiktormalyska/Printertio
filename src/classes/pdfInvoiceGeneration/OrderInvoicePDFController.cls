public class OrderInvoicePDFController {
    
    private Order orderRecord;
    
    public OrderInvoicePDFController(ApexPages.StandardController controller) {
        this.orderRecord = (Order) controller.getRecord();
    }
    
    public String getSignatureUrl() {
        String signatureVersionId = ApexPages.currentPage().getParameters().get('signatureVersionId');

        if (String.isBlank(signatureVersionId)) {
            signatureVersionId = '';
        }
        try {
            String finalUrl = 'https://orgfarm-6963239606-dev-ed--c.develop.vf.force.com/sfc/servlet.shepherd/version/download/' + signatureVersionId;
            return finalUrl;
        } catch (Exception e) {
            System.debug('Error retrieving signature: ' + e.getMessage());
        }
        
        System.debug('Returning null - no signature available');
        return null;
    }
    
    public String getCompanySignatureName() {
        return 'CompanySignature';
    }
}