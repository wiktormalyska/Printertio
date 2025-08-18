public class ProductSyncRetryScheduledJob implements Schedulable {
    private static final Integer MAX_RETRY_ATTEMPTS = 3;

    public void execute(SchedulableContext sc) {
        processFailedSynchronizations();
    }

    private void processFailedSynchronizations() {
        List<Product_Synchronization_Log__c> failedLogs = [
                SELECT Id, Request_Body__c, Response_Body__c, Retry_Count__c, (SELECT Product__c FROM Product_Synchronization_Log_Items__r)
                FROM Product_Synchronization_Log__c
                WHERE Status__c = 'ERROR'
                LIMIT 100
        ];

        if (failedLogs.isEmpty()) {
            return;
        }

        List<Product_Synchronization_Log__c> logsToUpdate = new List<Product_Synchronization_Log__c>();
        List<Product_Synchronization_Log__c> maxRetriesLogs = new List<Product_Synchronization_Log__c>();

        for (Product_Synchronization_Log__c log : failedLogs) {
            // Check if already at max retries - just send notification
            if (log.Retry_Count__c != null && log.Retry_Count__c >= MAX_RETRY_ATTEMPTS) {
                log.Status__c = 'FAILED';
                maxRetriesLogs.add(log);
                logsToUpdate.add(log);
                continue;
            }

            // Otherwise, attempt retry
            log.Retry_Count__c = (log.Retry_Count__c == null) ? 1 : log.Retry_Count__c + 1;

            try {
                List<Id> productIds = new List<Id>();
                for (Product_Synchronization_Log_Item__c item : log.Product_Synchronization_Log_Items__r) {
                    productIds.add(item.Product__c);
                }

                if (!productIds.isEmpty()) {
                    System.enqueueJob(new ProductSyncQueueable(productIds));
                    log.Status__c = 'SUCCESS';
                    log.Response_Body__c = 'Retry successful on attempt ' + log.Retry_Count__c;
                }
            } catch (Exception e) {
                log.Response_Body__c = 'Retry failed: ' + e.getMessage();

                if (log.Retry_Count__c >= MAX_RETRY_ATTEMPTS) {
                    log.Status__c = 'FAILED';
                    maxRetriesLogs.add(log);
                }
            }

            logsToUpdate.add(log);
        }

        // Update all logs first
        if (!logsToUpdate.isEmpty()) {
            update logsToUpdate;
        }

        // Send failure notifications for all logs that reached max retries
        if (!maxRetriesLogs.isEmpty()) {
            sendFailureNotifications(maxRetriesLogs);
        }
    }

    private void sendFailureNotifications(List<Product_Synchronization_Log__c> failedLogs) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Product_Synchronization_Log__c log : failedLogs) {
            List<Id> productIds = new List<Id>();
            for (Product_Synchronization_Log_Item__c item : log.Product_Synchronization_Log_Items__r) {
                productIds.add(item.Product__c);
            }

            if (!productIds.isEmpty()) {
                List<Product2> products = [
                        SELECT Id, Name, ProductCode
                        FROM Product2
                        WHERE Id IN :productIds
                ];

                Messaging.SingleEmailMessage email = createFailureEmail(log, products);
                emails.add(email);
            }
        }

        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (Exception e) {
            }
        }
    }

    private Messaging.SingleEmailMessage createFailureEmail(Product_Synchronization_Log__c log, List<Product2> products) {
        List<String> toAddresses = new List<String>{
                ConstUtil.PRODUCT_SYNC.EMAIL,
                'admin@company.com'
        };

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setSubject('Product Synchronization Failed - Max Retries Exceeded');

        String emailBody = 'Product synchronization has failed after ' + MAX_RETRY_ATTEMPTS + ' attempts.\n\n';
        emailBody += 'Log Details:\n';
        emailBody += '- Log ID: ' + log.Id + '\n';
        emailBody += '- Retry Count: ' + log.Retry_Count__c + '\n';
        emailBody += '- Products affected: ' + products.size() + '\n\n';

        emailBody += 'Failed Products:\n';
        for (Product2 p : products) {
            emailBody += '- ' + p.Name + ' (' + p.ProductCode + ') - ID: ' + p.Id + '\n';
        }

        emailBody += '\nOriginal Request:\n' + (log.Request_Body__c != null ? log.Request_Body__c : 'N/A');
        emailBody += '\n\nLast Error Response:\n' + (log.Response_Body__c != null ? log.Response_Body__c : 'N/A');

        email.setPlainTextBody(emailBody);
        return email;
    }
}