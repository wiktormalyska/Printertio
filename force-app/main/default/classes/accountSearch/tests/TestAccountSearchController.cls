@IsTest
private class TestAccountSearchController {

    @IsTest
    static void testGetDamianOrgAccounts() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGetDamianOrgAccounts());

        Test.startTest();
        List<Account> accounts = AccountSearchController.getDamianOrgAccounts('Test');
        Test.stopTest();

        System.assertEquals(2, accounts.size(), 'Should return two accounts');
        System.assertEquals('Global Media Test', accounts[0].Name, 'First account name should match');
        System.assertEquals('United Oil & Gas Corp. Test', accounts[1].Name, 'Second account name should match');
    }

    @IsTest
    static void testFindAccounts() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Test.startTest();
        List<Account> foundAccounts = AccountSearchController.findAccounts('Test Account');
        Test.stopTest();
        System.assertEquals(1, foundAccounts.size(), 'Should find one account');
        System.assertEquals(testAccount.Id, foundAccounts[0].Id, 'Found account should match the test account');
    }

    @IsTest
    static void testCreateAccountInDamianOrg() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCreateAccountInDamianOrg());

        String accountName = 'New Account';
        String phone = '(555) 555-5555';
        String industry = 'Apparel';
        String ownerEmail = 'email@test.com';

        Test.startTest();
        String response = AccountSearchController.createAccountInDamianOrg(accountName, phone, industry, ownerEmail);
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals('0015Y00002pGk4jQAC', response, 'Response should return the account ID');
    }

    @IsTest
    static void testCreateAccountInDamianOrgErrorMessage() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCreateAccountDamianErrMess());

        String accountName = 'New Account';
        String phone = '(555) 555-5555';
        String industry = 'Apparel';
        String ownerEmail = 'email@test.com';
        Test.startTest();
        try {
            AccountSearchController.createAccountInDamianOrg(accountName, phone, industry, ownerEmail);
            System.assert(false, 'Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {

        }
        Test.stopTest();
    }
    @IsTest
    static void testCreateAccountInDamianOrgWithException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCreateAccount500Error());

        String accountName = 'New Account';
        String phone = '(555) 555-5555';
        String industry = 'Apparel';
        String ownerEmail = 'email@test.com';

        Test.startTest();
        try {
            AccountSearchController.createAccountInDamianOrg(accountName, phone, industry, ownerEmail);
            System.assert(false, 'Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {

        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateAccountInDamianOrg() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseUpdateAccountDamianOrg());

        String accountId = '001123';
        String accountName = 'Test';
        String phone = '123456789';
        String industry = 'Apparel';
        String ownerEmail = 'test@test.com';


        Test.startTest();
        try {
            AccountSearchController.updateAccountInDamianOrg(
                    accountId,
                    accountName,
                    phone,
                    industry,
                    ownerEmail
            );
            System.assert(true, 'Method should not throw exception');
        } catch (Exception e) {
            System.assert(false, 'Error, thrown exception');
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateAccountInDamianOrgErr() {
        Test.setMock(HttpCalloutMock.class, new MockHttpUpdateAccountDamianOrgErr());

        String accountId = '001123';
        String accountName = 'Test';
        String phone = '123456789';
        String industry = 'Apparel';
        String ownerEmail = 'test@test.com';


        Test.startTest();
        try {
            AccountSearchController.updateAccountInDamianOrg(
                    accountId,
                    accountName,
                    phone,
                    industry,
                    ownerEmail
            );
            System.assert(false, 'Method should not throw exception');
        } catch (Exception e) {
            System.assert(true, 'Error, thrown exception');
        }
        Test.stopTest();
    }
}