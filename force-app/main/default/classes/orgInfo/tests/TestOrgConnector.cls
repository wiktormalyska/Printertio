@IsTest
public with sharing class TestOrgConnector {
    @IsTest
    static void testGetOrg2Accounts_Success() {
        Test.setMock(HttpCalloutMock.class, new OrgConnectorMock(true));

        Test.startTest();
        List<Account> resultAccounts = OrgConnector.getOrg2Accounts();
        Test.stopTest();

        System.assertNotEquals(null, resultAccounts, 'Result list should not be null.');
        System.assertEquals(2, resultAccounts.size(), 'The list should contain two accounts.');
        System.assertEquals('001xx000003DHPqAAO', resultAccounts[0].Id, 'The first account Id is incorrect.');
        System.assertEquals('Test Account 1', resultAccounts[0].Name, 'The first account name is incorrect.');
    }

    @IsTest
    static void testGetOrg2Accounts_Failure() {
        Test.setMock(HttpCalloutMock.class, new OrgConnectorMock(false));

        Test.startTest();
        List<Account> resultAccounts = OrgConnector.getOrg2Accounts();
        Test.stopTest();

        System.assertNotEquals(null, resultAccounts, 'Result list should not be null on failure.');
        System.assertEquals(0, resultAccounts.size(), 'The list should be empty on failure.');
    }
}