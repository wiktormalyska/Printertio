@isTest
private class TestAccountSearchController {

    @isTest
    static void testGetDamianOrgAccounts() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGetDamianOrgAccounts());
        
        Test.startTest();
        List<Account> accounts = AccountSearchController.getDamianOrgAccounts('Test');
        Test.stopTest();
        
        System.assertEquals(2, accounts.size(), 'Should return two accounts');
        System.assertEquals('Global Media Test', accounts[0].Name, 'First account name should match');
        System.assertEquals('United Oil & Gas Corp. Test', accounts[1].Name, 'Second account name should match');
    }

    @isTest
    static void testFindAccounts() {
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        Test.startTest();
        List<Account> foundAccounts = AccountSearchController.findAccounts('Test Account');
        Test.stopTest();
        System.assertEquals(1, foundAccounts.size(), 'Should find one account');
        System.assertEquals(testAccount.Id, foundAccounts[0].Id, 'Found account should match the test account');
    }

//    @isTest
//    static void testCreateAccountInDamianOrg() {
//        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCreateAccountInDamianOrg());
//
//        String accountName = 'New Account';
//        String website = 'http://example.com';
//        String phone = '(555) 555-5555';
//
//        Test.startTest();
//        String response = AccountSearchController.createAccountInDamianOrg(accountName, website, phone);
//        Test.stopTest();
//
//        System.assertNotEquals(null, response, 'Response should not be null');
//        System.assertEquals('0015Y00002pGk4jQAC', response, 'Response should return the account ID');
//    }
//    @isTest
//    static void testCreateAccountInDamianOrgWithException() {
//        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCreateAccount500Error());
//
//        String accountName = 'New Account';
//        String website = 'http://example.com';
//        String phone = '(555) 555-5555';
//
//        Test.startTest();
//        try {
//            String response = AccountSearchController.createAccountInDamianOrg(accountName, website, phone);
//            System.assert(false, 'Expected AuraHandledException to be thrown');
//        } catch (AuraHandledException e) {
//
//        }
//        Test.stopTest();
//    }
}