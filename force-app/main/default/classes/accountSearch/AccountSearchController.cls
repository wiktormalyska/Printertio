public with sharing class AccountSearchController {
    @AuraEnabled(Cacheable=true)
    public static List<Account> getDamianOrgAccounts(String searchKeys) {
        String searchKey = '%' + searchKeys + '%';
        List<Account> accounts = new List<Account>();

        HttpRequest request = new HttpRequest();
        String soqlRequest = 'SELECT Id, Name, Industry, Owner.Email, Phone ' +
            'FROM Account ' +
            'WHERE Name LIKE \'' + searchKey + '\' ' +
            'ORDER BY Name ' +
            'LIMIT 200';
        request.setEndpoint('callout:DamianOrg/services/data/v62.0/query?q='+EncodingUtil.urlEncode(soqlRequest, 'UTF-8'));
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> records = (List<Object>) responseMap.get('records');
            for (Object record : records) {
                Map<String, Object> accountData = (Map<String, Object>) record;
                Account acc = new Account();
                acc.Id = (String) accountData.get('Id');
                acc.Name = (String) accountData.get('Name');
                acc.Industry = (String) accountData.get('Industry');
                acc.Phone = (String) accountData.get('Phone');
                
                // Obsługa Owner.Email z nested object
                Map<String, Object> ownerData = (Map<String, Object>) accountData.get('Owner');
                if (ownerData != null) {
                    acc.Owner = new User();
                    acc.Owner.Email = (String) ownerData.get('Email');
                }
                
                accounts.add(acc);
            }
        } else {
            System.debug('Error ' + response.getStatus());
        }
        System.debug(accounts);
        return accounts;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Account> findAccounts(String searchKeys) {
        String searchKey = '%' + searchKeys + '%';
        List<Account> accounts = [
            SELECT Id, Name, Industry, Owner.Email, Phone
            FROM Account 
            WHERE Name LIKE :searchKey
                OR Phone LIKE :searchKey
                OR Owner.Email LIKE :searchKey
            ORDER BY Name
            LIMIT 200
        ];

        return accounts;
    }

    @AuraEnabled
    public static String createAccountInDamianOrg(
            String accountName, 
            String phone,
            String industry,
            String ownerEmail
        ){
        Map<String, Object> accountData = new Map<String, Object>();
        accountData.put('Name', accountName);
        accountData.put('Phone', phone);
        accountData.put('Industry', industry);

        if (String.isNotBlank(ownerEmail)) {
            accountData.put('Description', 'Owner Email: ' + ownerEmail);
        }
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:DamianOrg/services/data/v62.0/sobjects/Account/');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(accountData));

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 201) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accountId = (String) responseMap.get('id');
            System.debug('Account created with ID: ' + accountId);
            return accountId;
        } else {
            Map<String, Object> errorResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String errorMessage = 'Error creating account: ' + response.getStatus();
            
            if (errorResponse.containsKey('message')) {
                errorMessage = (String) errorResponse.get('message');
            }
            
            throw new AuraHandledException(errorMessage);
        }
    }

    @AuraEnabled
    public static String updateAccountInDamianOrg(
            String accountId,
            String accountName, 
            String phone,
            String industry,
            String ownerEmail
        ){
        Map<String, Object> accountData = new Map<String, Object>();
        accountData.put('Name', accountName);
        accountData.put('Phone', phone);
        accountData.put('Industry', industry);

        if (String.isNotBlank(ownerEmail)) {
            accountData.put('Description', 'Owner Email: ' + ownerEmail);
        }
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:DamianOrg/services/data/v62.0/sobjects/Account/' + accountId);
        request.setMethod('PATCH');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(accountData));

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 204) {
            System.debug('Account updated successfully: ' + accountId);
            return accountId;
        } else {
            Map<String, Object> errorResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String errorMessage = 'Error updating account: ' + response.getStatus();
            
            if (errorResponse.containsKey('message')) {
                errorMessage = (String) errorResponse.get('message');
            } else if (errorResponse.containsKey('errors')) {
                List<Object> errors = (List<Object>) errorResponse.get('errors');
                if (!errors.isEmpty()) {
                    Map<String, Object> firstError = (Map<String, Object>) errors[0];
                    errorMessage = (String) firstError.get('message');
                }
            }
            
            throw new AuraHandledException(errorMessage);
        }
    }


}