@IsTest
public with sharing class TestOrderInvoicePDFController {

    @TestSetup
    static void makeData(){

        Account acc = new Account(Name='Test Account');
        insert acc;



        Order testOrder = new Order(
                AccountId = acc.Id,
                EffectiveDate = Date.today(),
                Status = 'Draft',
                Pricebook2Id = Test.getStandardPricebookId()
        );
        insert testOrder;
    }

    @IsTest
    static void testGetSignatureUrlWithId() {

        Order ord = [SELECT Id FROM Order LIMIT 1];


        PageReference pageRef = Page.OrderInvoicePDF;
        pageRef.getParameters().put('signatureVersionId', '068_some_test_id_123');
        Test.setCurrentPage(pageRef);


        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        OrderInvoicePDFController controller = new OrderInvoicePDFController(sc);

        String signatureUrl;
        Test.startTest();

        signatureUrl = controller.getSignatureUrl();
        Test.stopTest();


        String expectedUrl = 'https://orgfarm-6963239606-dev-ed--c.develop.vf.force.com/sfc/servlet.shepherd/version/download/068_some_test_id_123';
        System.assertEquals(expectedUrl, signatureUrl, 'URL podpisu powinien być poprawnie zbudowany z podanym ID.');
    }

    @IsTest
    static void testGetSignatureUrlWithoutId() {

        Order ord = [SELECT Id FROM Order LIMIT 1];


        PageReference pageRef = Page.OrderInvoicePDF;
        Test.setCurrentPage(pageRef);


        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        OrderInvoicePDFController controller = new OrderInvoicePDFController(sc);

        String signatureUrl;
        Test.startTest();
        signatureUrl = controller.getSignatureUrl();
        Test.stopTest();

        System.assertEquals(null, signatureUrl, 'URL podpisu powinien być poprawnie zbudowany bez ID.');
    }

    @IsTest
    static void testGetCompanySignatureName() {
        Order ord = [SELECT Id FROM Order LIMIT 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        OrderInvoicePDFController controller = new OrderInvoicePDFController(sc);

        String signatureName;
        Test.startTest();

        signatureName = controller.getCompanySignatureName();
        Test.stopTest();


        System.assertEquals('CompanySignature', signatureName, 'Nazwa podpisu firmy powinna być "CompanySignature".');
    }
}