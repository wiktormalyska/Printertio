@IsTest
global with sharing class ProductSearchControllerTests {

    @TestSetup
    static void setupTestData() {
        Product2 product1 = new Product2(Name = 'Test Product 1', Family = 'Custom 2D Print', ProductCode = 'TP1');
        Product2 product2 = new Product2(Name = 'Test Product 2', Family = 'Custom 3D Print', ProductCode = 'TP2');
        Product2 product3 = new Product2(Name = 'Another Product', Family = 'Custom 2D Print', ProductCode = 'AP1');
        insert new List<Product2>{product1, product2, product3};
    }

    @IsTest
    global static void getProductsTest() {
        Test.startTest();
        List<Product2> results = ProductSearchController.getProducts('TP1', null);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Expected to find 1 product matching the search term.');
        System.assertEquals('Test Product 1', results[0].Name, 'First product name should match.');
    }

    @IsTest
    global static void getProductsNoSearchTermTest() {
        Test.startTest();
        List<Product2> results = ProductSearchController.getProducts('', null);
        Test.stopTest();

        System.assertEquals(3, results.size(), 'Expected to find all products when no search term is provided.');
    }

    @IsTest
    global static void getProductsByFamilyTest() {
        Test.startTest();
        List<Product2> results = ProductSearchController.getProducts('', 'Custom 2D Print');
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Expected to find 2 products in Custom 2D Print family.');
        for (Product2 product : results) {
            System.assertEquals('Custom 2D Print', product.Family, 'All products should be from Custom 2D Print family.');
        }
    }

    @IsTest
    global static void getProductsBySearchTermAndFamilyTest() {
        Test.startTest();
        List<Product2> results = ProductSearchController.getProducts('Test', 'Custom 3D Print');
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Expected to find 1 product matching both search term and family.');
        System.assertEquals('Test Product 2', results[0].Name, 'Should find Test Product 2.');
        System.assertEquals('Custom 3D Print', results[0].Family, 'Should be from Custom 3D Print family.');
    }

    @IsTest
    global static void getProductFamiliesTest() {
        Test.startTest();
        List<String> families = ProductSearchController.getProductFamilies();
        Test.stopTest();

        System.assertEquals(2, families.size(), 'Expected to find 2 distinct families.');
        System.assert(families.contains('Custom 2D Print'), 'Should contain Custom 2D Print family.');
        System.assert(families.contains('Custom 3D Print'), 'Should contain Custom 3D Print family.');
    }
}