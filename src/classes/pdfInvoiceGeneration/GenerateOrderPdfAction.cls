public class GenerateOrderPdfAction {
    
    public class FlowOutputs {
        @InvocableVariable(label='Success' description='Whether the PDF generation was successful')
        public Boolean isSuccess;
        
        @InvocableVariable(label='Error Message' description='Error message if generation failed')
        public String errorMessage;
        
        @InvocableVariable(label='Generated File Count' description='Number of PDF files successfully generated')
        public Integer generatedCount;
    }
    
    @InvocableMethod(label='Generate and Attach Order PDF' description='Renders a Visualforce page as a PDF and attaches it to the Order record.')
    public static List<FlowOutputs> generatePdf(List<Id> orderIds) {
        FlowOutputs result = new FlowOutputs();
        result.isSuccess = false;
        result.errorMessage = '';
        result.generatedCount = 0;
        
        try {
            // Debug logging
            System.debug('GenerateOrderPdfAction.generatePdf called with orderIds: ' + orderIds);
            
            Map<Id, Order> ordersMap = new Map<Id, Order>([SELECT OrderNumber FROM Order WHERE Id IN :orderIds]);
            System.debug('Found orders: ' + ordersMap.keySet());
            List<ContentVersion> filesToInsert = new List<ContentVersion>();
            
            Map<Id, Integer> orderRevisionMap = new Map<Id, Integer>();
            
            for (Id orderId : orderIds) {
                String baseFileName = 'Confirmation - ' + ordersMap.get(orderId).OrderNumber;
                
                List<ContentVersion> existingFiles = [
                    SELECT Id, Title 
                    FROM ContentVersion 
                    WHERE FirstPublishLocationId = :orderId 
                    AND Title LIKE :baseFileName + '%'
                    AND IsLatest = true
                ];
                
                Integer maxRevision = 0;
                for (ContentVersion cv : existingFiles) {
                    String title = cv.Title;
                    if (title.contains(' - Rev ')) {
                        String revPart = title.substring(title.lastIndexOf(' - Rev ') + 7);
                        try {
                            Integer revNum = Integer.valueOf(revPart);
                            if (revNum > maxRevision) {
                                maxRevision = revNum;
                            }
                        } catch (Exception e) {
                            // Ignoruj błędy parsowania
                        }
                    } else if (title.equals(baseFileName)) {
                        maxRevision = Math.max(maxRevision, 1);
                    }
                }
                
                orderRevisionMap.put(orderId, maxRevision + 1);
            }
            
            for (Id orderId : orderIds) {
                try {
                    System.debug('Processing Order ID: ' + orderId);
                    PageReference pageRef = Page.OrderInvoicePDF;
                    pageRef.getParameters().put('id', String.valueOf(orderId));
                    pageRef.setRedirect(false);
                    
                    System.debug('PageReference URL: ' + pageRef.getUrl());
                    System.debug('PageReference Parameters: ' + pageRef.getParameters());
                    
                    Blob pdfBlob;
                    
                    pdfBlob = pageRef.getContentAsPDF();
                    System.debug('PDF generated successfully, size: ' + pdfBlob.size() + ' bytes');
                    
                    ContentVersion cv = new ContentVersion();
                    
                    String baseTitle = 'Confirmation - ' + ordersMap.get(orderId).OrderNumber;
                    Integer revisionNumber = orderRevisionMap.get(orderId);
                    
                    if (revisionNumber > 1) {
                        cv.Title = baseTitle + ' - Rev ' + revisionNumber;
                        cv.PathOnClient = baseTitle + ' - Rev ' + revisionNumber + '.pdf';
                    } else {
                        cv.Title = baseTitle;
                        cv.PathOnClient = baseTitle + '.pdf';
                    }
                    
                    cv.VersionData = pdfBlob;
                    cv.FirstPublishLocationId = orderId;

                    filesToInsert.add(cv);
                } catch (Exception e) {
                    result.errorMessage += 'Error for Order ' + orderId + ': ' + e.getMessage() + '; ';
                }
            }

            if (!filesToInsert.isEmpty()) {
                insert filesToInsert;
                result.generatedCount = filesToInsert.size();
                result.isSuccess = true;
                
                // Create Task entries for generated invoices as activity log
                List<Task> activityEntries = new List<Task>();
                for (ContentVersion cv : filesToInsert) {
                    Task activity = new Task();
                    activity.WhatId = cv.FirstPublishLocationId; // Link to Order
                    activity.Subject = 'Invoice Generated: ' + cv.Title;
                    activity.Description = 'PDF invoice was automatically generated and attached to this order. File: ' + cv.PathOnClient;
                    activity.Status = 'Completed';
                    activity.Priority = 'Normal';
                    activity.ActivityDate = Date.today();
                    activity.Type = 'Other';
                    activityEntries.add(activity);
                }
                
                if (!activityEntries.isEmpty()) {
                    try {
                        insert activityEntries;
                    } catch (Exception activityException) {
                        // Log error but don't fail the main operation
                        System.debug('Failed to create Activity log: ' + activityException.getMessage());
                    }
                }
            } else {
                result.errorMessage = 'No PDF files were generated';
            }
            
        } catch (Exception e) {
            result.errorMessage = 'General error: ' + e.getMessage();
        }
        
        return new List<FlowOutputs>{ result };
    }

    // Helper method to get the latest PDF version ID for a given order
    private static String getLatestPdfVersionIdForOrder(Id orderId) {
        try {
            // Query for the latest PDF ContentVersion linked to this order using FirstPublishLocationId
            List<ContentVersion> latestPdfVersions = [
                SELECT Id, Title, CreatedDate
                FROM ContentVersion 
                WHERE FirstPublishLocationId = :orderId
                AND FileType = 'PDF'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            if (!latestPdfVersions.isEmpty()) {
                System.debug('Found latest PDF version ID: ' + latestPdfVersions[0].Id + ' for order: ' + orderId);
                return latestPdfVersions[0].Id;
            } else {
                System.debug('No PDF versions found for order: ' + orderId);
                return null;
            }
            
        } catch (Exception e) {
            System.debug('Error getting latest PDF version ID: ' + e.getMessage());
            return null;
        }
    }
    
    // Public method for testing purposes - to get latest PDF version ID for an order
    @AuraEnabled
    public static String getLatestPdfVersionId(Id orderId) {
        return getLatestPdfVersionIdForOrder(orderId);
    }
    
    // Alternative method that returns structured response with versionId
    @AuraEnabled
    public static Id createSignatureDocument(Id orderId, String signatureBase64){
        try {
            ContentVersion signatureFile = new ContentVersion();
            signatureFile.Title = 'Customer_Signature_' + orderId;
            signatureFile.PathOnClient = 'Customer_Signature_' + orderId + '.png';
            signatureFile.VersionData = EncodingUtil.base64Decode(signatureBase64);
            signatureFile.FirstPublishLocationId = orderId;
            insert signatureFile;

            return signatureFile.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static PdfGenerationResult generatePdfWithSignatureAndReturnVersionId(Id orderId, Id signatureVersionId) {
        PdfGenerationResult result = new PdfGenerationResult();
        
        try {
            // Generate PDF with signature ContentVersion ID
            List<Id> orderIds = new List<Id>{orderId};
            List<FlowOutputs> results = generatePdfWithCustomerSignature(orderIds, signatureVersionId);
            
            if (results[0].isSuccess) {
                result.isSuccess = true;
                result.message = 'PDF generated successfully with electronic signature';
                
                // Get the latest PDF version ID for this order
                result.latestPdfVersionId = getLatestPdfVersionIdForOrder(orderId);
                
                if (String.isNotBlank(result.latestPdfVersionId)) {
                    result.message += '. Latest PDF Version ID: ' + result.latestPdfVersionId;
                }
            } else {
                result.isSuccess = false;
                result.message = results[0].errorMessage;
            }
            
        } catch (Exception e) {
            result.isSuccess = false;
            result.message = 'Error generating PDF with signature: ' + e.getMessage();
        }
        
        return result;
    }
    
    // Wrapper class for structured response
    public class PdfGenerationResult {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public String latestPdfVersionId { get; set; }
        
        public PdfGenerationResult() {
            this.isSuccess = false;
            this.message = '';
            this.latestPdfVersionId = null;
        }
    }
    
    private static List<FlowOutputs> generatePdfWithCustomerSignature(List<Id> orderIds, Id signatureVersionId) {
        FlowOutputs result = new FlowOutputs();
        result.isSuccess = false;
        result.errorMessage = '';
        result.generatedCount = 0;
        
        try {
            Map<Id, Order> ordersMap = new Map<Id, Order>([SELECT OrderNumber FROM Order WHERE Id IN :orderIds]);
            List<ContentVersion> filesToInsert = new List<ContentVersion>();
            
            for (Id orderId : orderIds) {
                try {
                    PageReference pageRef = Page.OrderInvoicePDF;
                    pageRef.getParameters().put('id', String.valueOf(orderId));
                    pageRef.getParameters().put('signatureVersionId', String.valueOf(signatureVersionId));
                    pageRef.setRedirect(false);
                    Blob pdfBlob = pageRef.getContentAsPDF();
                    
                    ContentVersion cv = new ContentVersion();
                    String baseTitle = 'Signed_Invoice - ' + ordersMap.get(orderId).OrderNumber;
                    cv.Title = baseTitle + ' - ' + DateTime.now().format('yyyy-MM-dd_HH-mm');
                    cv.PathOnClient = cv.Title + '.pdf';
                    cv.VersionData = pdfBlob;
                    cv.FirstPublishLocationId = orderId;
                    filesToInsert.add(cv);
                    
                } catch (Exception e) {
                    result.errorMessage += 'Error for Order ' + orderId + ': ' + e.getMessage() + '; ';
                }
            }

            if (!filesToInsert.isEmpty()) {
                insert filesToInsert;
                result.generatedCount = filesToInsert.size();
                result.isSuccess = true;
            } else {
                result.errorMessage = 'No PDF files were generated';
            }
            
        } catch (Exception e) {
            result.errorMessage = 'General error: ' + e.getMessage();
        }
        
        return new List<FlowOutputs>{ result };
    }
}