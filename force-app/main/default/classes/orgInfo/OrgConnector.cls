public with sharing class OrgConnector {
    public static List<Account> getOrg2Accounts(){
        List<Account> accounts = new List<Account>();

        HttpRequest request = new HttpRequest();
        String endpoint = 'callout:Dane_z_Orgu_B/services/data/v60.0/query/?q=SELECT Id, Name FROM Account LIMIT 5'; //TODO: Podmienić URL
        
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> records = (List<Object>) results.get('records');

            System.debug('Downloaded ' + records.size() + ' records.');

            for (Object obj : records) {
                Map<String, Object> acct = (Map<String, Object>) obj;
                String accountId = (String) acct.get('Id');
                String accountName = (String) acct.get('Name');

                Account account = new Account();
                account.Id = accountId;
                account.Name = accountName;
                accounts.add(account);

                System.debug('ID: ' + accountId + ', Name: ' + accountName);
            }
        } else {
            System.debug('Request error. Status: ' + response.getStatus());
            System.debug('Error message: ' + response.getBody());
        }
        
        return accounts;
    }
}