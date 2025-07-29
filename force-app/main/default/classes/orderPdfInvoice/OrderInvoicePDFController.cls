public class OrderInvoicePDFController {
    
    private Order orderRecord;
    
    public OrderInvoicePDFController(ApexPages.StandardController controller) {
        this.orderRecord = (Order) controller.getRecord();
    }
    
    public String getSignatureUrl() {
        String signatureVersionId = ApexPages.currentPage().getParameters().get('signatureVersionId');
        
        System.debug('Parameter signatureVersionId: ' + signatureVersionId);
        
        // If no specific signature provided, try to use the default customer signature
        if (String.isBlank(signatureVersionId)) {
            signatureVersionId = getDefaultCustomerSignatureId();
            System.debug('Using default signature ID: ' + signatureVersionId);
        } else {
            System.debug('Using parameter signature ID: ' + signatureVersionId);
        }
        
        System.debug('Final signatureVersionId to use: ' + signatureVersionId);
        
        if (String.isNotBlank(signatureVersionId)) {
            try {

                System.debug('No ContentVersion found with ID: ' + signatureVersionId);
                System.debug('Falling back to search by title pattern');
                // Try to find signature file by title pattern instead
                
                System.debug('Found signature file by title: ' + signatureVersionId);
                // Return ContentVersion URL that works in PDF
                // String finalUrl = System.URL.getOrgDomainUrl() + '/sfc/servlet.shepherd/version/download/' + signatureVersionId;
                String finalUrl = 'https://orgfarm-6963239606-dev-ed--c.develop.vf.force.com/sfc/servlet.shepherd/version/download/' + signatureVersionId;
                System.debug('Returning fallback URL: ' + finalUrl);
                return finalUrl;

                
            } catch (Exception e) {
                System.debug('Error retrieving signature: ' + e.getMessage());
            }
        }
        
        System.debug('Returning null - no signature available');
        return null;
    }
    
    public String getSignatureBase64() {
        String signatureVersionId = ApexPages.currentPage().getParameters().get('signatureVersionId');
        
        // If no specific signature provided, try to use the default customer signature
        if (String.isBlank(signatureVersionId)) {
            signatureVersionId = getDefaultCustomerSignatureId();
        }
        
        System.debug('Looking for ContentVersion with ID: ' + signatureVersionId);
        
        if (String.isNotBlank(signatureVersionId)) {
            try {
                // First check if this ID exists
                List<ContentVersion> cvList = [SELECT VersionData, FileType FROM ContentVersion WHERE Id = :signatureVersionId LIMIT 1];
                
                if (cvList.isEmpty()) {
                    System.debug('No ContentVersion found with ID: ' + signatureVersionId);
                    // Try to find signature file by title pattern instead
                    List<ContentVersion> signatureFiles = [
                        SELECT Id, VersionData, FileType 
                        FROM ContentVersion 
                        WHERE Title LIKE 'Customer_Signature%' 
                        AND IsLatest = true 
                        LIMIT 1
                    ];
                    
                    if (!signatureFiles.isEmpty()) {
                        ContentVersion cv = signatureFiles[0];
                        System.debug('Found signature file by title: ' + cv.Id);
                        String base64String = EncodingUtil.base64Encode(cv.VersionData);
                        String mimeType = getMimeType(cv.FileType);
                        return 'data:' + mimeType + ';base64,' + base64String;
                    }
                    return null;
                }
                
                ContentVersion cv = cvList[0];
                if (cv.VersionData != null) {
                    // Convert blob to base64 string
                    String base64String = EncodingUtil.base64Encode(cv.VersionData);
                    
                    // Return data URL format for inline display in HTML
                    String mimeType = getMimeType(cv.FileType);
                    return 'data:' + mimeType + ';base64,' + base64String;
                }
            } catch (Exception e) {
                System.debug('Error retrieving signature: ' + e.getMessage());
            }
        }
        
        return null;
    }
    
    private String getMimeType(String fileType) {
        if (String.isBlank(fileType)) {
            return 'image/png';
        }
        
        fileType = fileType.toLowerCase();
        switch on fileType {
            when 'png' {
                return 'image/png';
            }
            when 'jpg', 'jpeg' {
                return 'image/jpeg';
            }
            when 'gif' {
                return 'image/gif';
            }
            when 'svg' {
                return 'image/svg+xml';
            }
            when else {
                return 'image/png'; // default fallback
            }
        }
    }
    
    private String getDefaultCustomerSignatureId() {
        return '';
    }
    
    public String getCompanySignatureName() {
        return 'CompanySignature';
    }
    
    public Boolean getHasSignature() {
        String signatureVersionId = ApexPages.currentPage().getParameters().get('signatureVersionId');
        
        // Check if we have either a parameter or default signature
        return String.isNotBlank(signatureVersionId) || String.isNotBlank(getDefaultCustomerSignatureId());
    }
}