@IsTest
public with sharing class TestOrganizationInfoController {

    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        String uniqueUserName = 'testuser' + System.currentTimeMillis() + '@testorg.com';
        User u = new User(
                Alias = 'testu',
                Email = 'testuser@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = uniqueUserName
        );
        return u;
    }

    @IsTest
    static void testConstructorAndInit() {
        Test.startTest();
        OrganizationInfoController controller = new OrganizationInfoController();
        Test.stopTest();

        System.assertNotEquals(null, controller.usersList, 'User list should not be null.');
        System.assert(controller.usersList.size() > 0, 'User list should contain at least one user.');
        System.assertNotEquals(null, controller.licenseInfo, 'License info should be loaded.');
        System.assert(controller.apexClassCount >= 1, 'Apex class count should be greater than or equal to 1.');
        System.assert(controller.visualforcePageCount >= 0, 'Visualforce page count should be greater than or equal to 0.');
    }

    @IsTest
    static void testDeleteUserSuccess() {
        User testUser = createTestUser();
        insert testUser;

        OrganizationInfoController controller = new OrganizationInfoController();
        controller.selectedUserId = testUser.Id;

        Test.startTest();
        controller.deleteUser();
        Test.stopTest();

        User deactivatedUser = [SELECT Id, IsActive FROM User WHERE Id = :testUser.Id];
        System.assertEquals(false, deactivatedUser.IsActive, 'The user should be deactivated.');
        System.assert(ApexPages.hasMessages(ApexPages.Severity.CONFIRM), 'A success message should be displayed.');
    }

    @IsTest
    static void testDeleteUserNoSelection() {
        OrganizationInfoController controller = new OrganizationInfoController();
        controller.selectedUserId = null;

        Test.startTest();
        controller.deleteUser();
        Test.stopTest();

        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'An error message should be displayed.');
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size(), 'There should be exactly one message.');
        System.assertEquals('No user was selected.', messages[0].getDetail(), 'The error message detail is incorrect.');
    }

    @IsTest
    static void testGetMetadataItems() {
        OrganizationInfoController controller = new OrganizationInfoController();

        List<OrganizationInfoController.MetadataWrapper> metadataItems;
        Test.startTest();
        metadataItems = controller.getMetadataItems();
        Test.stopTest();

        System.assertEquals(2, metadataItems.size(), 'The list should contain 2 items.');
        System.assertEquals('Apex Classes', metadataItems[0].name, 'The first item should be for Apex Classes.');
        System.assertEquals(controller.apexClassCount, metadataItems[0].count, 'The Apex class count is incorrect.');
        System.assertEquals('Visualforce Pages', metadataItems[1].name, 'The second item should be for Visualforce Pages.');
    }

    @IsTest
    static void testGetSessionId() {
        OrganizationInfoController controller = new OrganizationInfoController();

        String sessionId;
        Test.startTest();
        sessionId = controller.sessionId;
        Test.stopTest();

        System.assertNotEquals(null, sessionId, 'Session ID should not be null.');
    }
}