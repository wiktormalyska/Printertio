public class ProductSyncRetryBatchJob implements Database.Batchable<Product_Synchronization_Log__c>, Database.AllowsCallouts {

    private static final Integer MAX_RETRY_ATTEMPTS = ConstUtil.PRODUCT_SYNC.LOGS.MAX_RETRY_ATTEMPTS;

    public Iterable<Product_Synchronization_Log__c> start(Database.BatchableContext bc) {
        return [
                SELECT Id, Request_Body__c, Response_Body__c, Retry_Count__c, Status__c,
                        Product__c, Product__r.Name, Product__r.ProductCode, Product__r.Description,
                        Product__r.IsActive, Product__r.ExternalId, Product__r.IsExternal__c
                FROM Product_Synchronization_Log__c
                WHERE Status__c = :ConstUtil.PRODUCT_SYNC.LOGS.STATUS.ERROR
        ];
    }

    public void execute(Database.BatchableContext bc, List<Product_Synchronization_Log__c> scope) {
        List<Product_Synchronization_Log__c> logsToUpdate = new List<Product_Synchronization_Log__c>();
        List<Product_Synchronization_Log__c> logsThatFailedPermanently = new List<Product_Synchronization_Log__c>();
        List<Product2> productsToRetry = new List<Product2>();

        for (Product_Synchronization_Log__c log : scope) {
            if (log.Product__c == null) {
                log.Status__c = ConstUtil.PRODUCT_SYNC.LOGS.STATUS.FAILED;
                logsThatFailedPermanently.add(log);
                logsToUpdate.add(log);
                continue;
            }

            Integer retryCount = (log.Retry_Count__c == null) ? 0 : Integer.valueOf(log.Retry_Count__c);

            if (retryCount >= MAX_RETRY_ATTEMPTS) {
                log.Status__c = ConstUtil.PRODUCT_SYNC.LOGS.STATUS.FAILED;
                logsThatFailedPermanently.add(log);
            } else {
                log.Retry_Count__c = retryCount + 1;
                log.Status__c = ConstUtil.PRODUCT_SYNC.LOGS.STATUS.ERROR;
                productsToRetry.add(log.Product__r);
            }
            logsToUpdate.add(log);
        }

        if (!logsToUpdate.isEmpty()) {
            update logsToUpdate;
        }

        if (!productsToRetry.isEmpty()) {
            try {
                SynchronizeService.synchronizeProducts(productsToRetry);
            } catch (Exception e) {
            }
        }

        if (!logsThatFailedPermanently.isEmpty()) {
            sendFailureNotifications(logsThatFailedPermanently);
        }
    }

    public void finish(Database.BatchableContext bc) {

    }

    private void sendFailureNotifications(List<Product_Synchronization_Log__c> failedLogs) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Product_Synchronization_Log__c log : failedLogs) {
            emails.add(createFailureEmail(log));
        }

        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (Exception e) {
            }
        }
    }

    private Messaging.SingleEmailMessage createFailureEmail(Product_Synchronization_Log__c log) {
        List<String> toAddresses = new List<String>{ ConstUtil.PRODUCT_SYNC.LOGS.EMAIL.RECEIVER_EMAIL };

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setSubject('Product Synchronization Permanently Failed for ' + log.Product__r.Name);

        String emailBody = 'Product synchronization has failed after the maximum of ' + MAX_RETRY_ATTEMPTS + ' attempts.\n\n';
        emailBody += 'Failed Product Details:\n';
        emailBody += '- Name: ' + log.Product__r.Name + '\n';
        emailBody += '- Product Code: ' + log.Product__r.ProductCode + '\n';
        emailBody += '- Product ID: ' + log.Product__c + '\n\n';

        emailBody += 'Log Details:\n';
        emailBody += '- Log ID: ' + log.Id + '\n';
        emailBody += '- Final Retry Count: ' + log.Retry_Count__c + '\n\n';

        emailBody += 'Original Request:\n' + (log.Request_Body__c != null ? log.Request_Body__c : 'N/A') + '\n\n';
        emailBody += 'Last Error Response:\n' + (log.Response_Body__c != null ? log.Response_Body__c : 'N/A');

        email.setPlainTextBody(emailBody);
        return email;
    }
}