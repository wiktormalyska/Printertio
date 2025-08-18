import LightningModal from 'lightning/modal';
import { CloseActionScreenEvent } from 'lightning/actions';
import { api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Toast from 'lightning/toast';

// Import Custom Labels
import Selected_Products_Summary_Text from '@salesforce/label/c.Selected_Products_Summary_Text';
import Loading_Products_Text from '@salesforce/label/c.Loading_Products_Text';
import Total_Price_Text from '@salesforce/label/c.Total_Price_Text';
import Price_After_Discount_Text from '@salesforce/label/c.Price_After_Discount_Text';
import Cancel_Text from '@salesforce/label/c.Cancel_Text';
import Previous_Text from '@salesforce/label/c.Previous_Text';
import Create_Order_Text from '@salesforce/label/c.Create_Order_Text';
import Discount_Search_Products_Text from '@salesforce/label/c.Discount_Search_Products_Text';
import Category_Text from '@salesforce/label/c.Category_Text';
import Select_Category_Placeholder_Text from '@salesforce/label/c.Select_Category_Placeholder_Text';
import Search_Text from '@salesforce/label/c.Search_Text';
import Next_Text from '@salesforce/label/c.Next_Text';

import getProducts from '@salesforce/apex/ProductSearchController.getProducts';
import getProductFamilies from '@salesforce/apex/ProductSearchController.getProductFamilies';
import getProductsTotalAmount from '@salesforce/apex/ProductSearchController.getProductsTotalAmount';
import getProductsTotalAmountAfterDiscount from '@salesforce/apex/ProductSearchController.getProductsTotalAmountAfterDiscount';
import createOrderForOpportunity from '@salesforce/apex/ProductSearchController.createOrderForOpportunity';
import FIRST_PAGE from './productPickForm.html';
import SECOND_PAGE from './summaryOfForm.html';

export default class ProductSearch extends NavigationMixin(LightningModal) {
    @api recordId;

    label = {
        Selected_Products_Summary_Text,
        Loading_Products_Text,
        Total_Price_Text,
        Price_After_Discount_Text,
        Cancel_Text,
        Previous_Text,
        Create_Order_Text,
        Discount_Search_Products_Text,
        Category_Text,
        Select_Category_Placeholder_Text,
        Search_Text,
        Next_Text
    };

    stage = 0;

    searchFieldValue = ''
    selectedFamily = ''

    allProducts = []
    products = []
    familyOptions = []

    selectedProducts = [];
    selectedProductIds = [];
    totalPrice = 0;
    totalPriceAfterDiscount = 0;

    columns = [
        { label: 'Product Name', fieldName: 'Name', type: 'text' },
        { label: 'Product Code', fieldName: 'ProductCode', type: 'text' },
        { label: 'Product Family', fieldName: 'Family', type: 'text' },
        { label: 'Price', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'Is External', fieldName: 'IsExternal__c', type: 'boolean' }
    ]

    summaryColumns = [
        { label: 'Product Name', fieldName: 'Name', type: 'text' },
        { label: 'Product Code', fieldName: 'ProductCode', type: 'text' },
        { label: 'Product Family', fieldName: 'Family', type: 'text' },
        { label: 'Price', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number', editable: true },
        { label: 'Is External', fieldName: 'IsExternal__c', type: 'boolean' }
    ]

    showSpinner = false;

    currentPage = 1;
    pageSize = 10;
    totalRecords = 0;
    totalPages = 0;

    render() {
        switch (this.stage) {
            case 0:
                return FIRST_PAGE;
            case 1:
                return SECOND_PAGE;
            default:
                return FIRST_PAGE;
        }
    }

    async connectedCallback() {
        this.showSpinner = true;
        await this.loadFamilies();
        this.searchProducts();
        this.showSpinner = false;
    }

    async loadFamilies() {
        try {
            const families = await getProductFamilies();
            this.familyOptions = [
                { label: 'None', value: null },
                ...families.map(family => ({ label: family, value: family }))
            ]
        } catch (error) {
            Toast.show({
                label: 'Error',
                message: error.body.message,
                variant: 'error'
            });
        }
    }

    handleSearchFieldChange(event) {
        this.searchFieldValue = event.detail.value
    }

    handleFamilyChange(event) {
        this.selectedFamily = event.detail.value;
        this.currentPage = 1;
        this.searchProducts();
    }

    handleKeyUp(event) {
        if (event.key === 'Enter') {
            this.currentPage = 1;
            this.searchProducts();
        }
    }

    async searchProducts() {
        this.showSpinner = true;
        try {
            const rawProducts = await getProducts({
                searchTerm: this.searchFieldValue,
                family: this.selectedFamily
            });

            this.allProducts = rawProducts.map(product => ({
                ...product,
                UnitPrice: product.PricebookEntries && product.PricebookEntries.length > 0
                    ? product.PricebookEntries[0].UnitPrice
                    : 0,
                IsExternal__c: product.IsExternal__c === true
            }));

            this.totalRecords = this.allProducts.length;
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
            this.updateDisplayedProducts();
            this.error = undefined;
        } catch (error) {
            Toast.show({
                label: 'Error',
                message: error.body.message,
                variant: 'error'
            });
        } finally {
            this.showSpinner = false;
        }

    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        const currentPageProductIds = this.products.map(product => product.Id);
        this.selectedProductIds = this.selectedProductIds.filter(id =>
            !currentPageProductIds.includes(id)
        );
        const newSelectedIds = selectedRows.map(row => row.Id);
        this.selectedProductIds = [...this.selectedProductIds, ...newSelectedIds];
        this.selectedProducts = this.allProducts.filter(product =>
            this.selectedProductIds.includes(product.Id)
        );
    }

    updateTableSelection() {
        const currentPageSelectedIds = this.products
            .filter(product => this.selectedProductIds.includes(product.Id))
            .map(product => product.Id);

        setTimeout(() => {
            const datatable = this.template.querySelector('lightning-datatable');
            if (datatable) {
                datatable.selectedRows = currentPageSelectedIds;
            }
        }, 0);
    }

    get selectedProductsCount() {
        return this.selectedProductIds.length;
    }

    get isNextButtonDisabled() {
        return this.selectedProductIds.length === 0 || this.stage !== 0;
    }

    updateDisplayedProducts() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        this.products = this.allProducts.slice(startIndex, endIndex);
        this.updateTableSelection();
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updateDisplayedProducts();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updateDisplayedProducts();
        }
    }

    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    get paginationInfo() {
        const startRecord = this.totalRecords > 0 ? (this.currentPage - 1) * this.pageSize + 1 : 0;
        const endRecord = Math.min(this.currentPage * this.pageSize, this.totalRecords);
        return `${startRecord}-${endRecord} of ${this.totalRecords}`;
    }

    handleGoToProductForm() {
        this.stage = 0;
        this.updateTableSelection();
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    draftValues = [];
    handleQuantitySave(event) {
        const updatedDraftValues = event.detail.draftValues;
        updatedDraftValues.forEach(draft => {
            const product = this.selectedProducts.find(p => p.Id === draft.Id);
            if (product) {
                product.Quantity = draft.Quantity;
            }
        });
        this.draftValues = [];
        this.calculateTotalPrice();
        this.calculateAfterDiscountPrice();
    }

    async calculateTotalPrice() {
        if (this.selectedProducts.length > 0) {
            try {
                const productsWithQuantities = this.selectedProducts.map(product => ({
                    id: product.Id,
                    quantity: product.Quantity || 1
                }));
                const totalAmount = await getProductsTotalAmount({ products: productsWithQuantities });
                this.totalPrice = Math.round(totalAmount * 100) / 100;
            } catch (error) {
                Toast.show({
                    label: 'Error',
                    message: error.body?.message || error.message,
                    variant: 'error'
                });
                this.totalPrice = 0;
            }
        } else {
            this.totalPrice = 0;
        }
    }

    handleGoToSummary() {
        if (this.selectedProductIds.length > 0) {
            this.selectedProducts = this.allProducts
                .filter(product => this.selectedProductIds.includes(product.Id))
                .map(product => ({
                    Id: product.Id,
                    Name: product.Name,
                    ProductCode: product.ProductCode,
                    Family: product.Family,
                    UnitPrice: product.UnitPrice,
                    Quantity: 1
                }));
            this.stage = 1;
            this.calculateTotalPrice();
            this.calculateAfterDiscountPrice();
        } else {
            Toast.show({
                label: 'Warning',
                message: 'Please select at least one product',
                variant: 'warning'
            });
        }
    }

    async calculateAfterDiscountPrice() {
        if (this.selectedProducts.length === 0) {
            this.totalPriceAfterDiscount = 0;
            return;
        }
        try {
            const productsWithQuantities = this.selectedProducts.map(product => ({
                id: product.Id,
                quantity: product.Quantity || 1
            }));
            const totalAmountAfterDiscount = await getProductsTotalAmountAfterDiscount({ products: productsWithQuantities });
            this.totalPriceAfterDiscount = Math.round(totalAmountAfterDiscount * 100) / 100;
        } catch (error) {
            Toast.show({
                label: 'Error',
                message: error.body?.message || error.message,
                variant: 'error'
            });
            this.totalPriceAfterDiscount = 0;
        }
    }


    handleCreateOrder() {
        const productsWithQuantities = this.selectedProducts.map(product => ({
            id: product.Id,
            quantity: product.Quantity
        }));

        createOrderForOpportunity({
            opportunityId: this.recordId,
            products: productsWithQuantities
        })
            .then(orderId => {
                Toast.show({
                    label: 'Success',
                    message: 'Order created successfully',
                    variant: 'success'
                });
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: orderId,
                        objectApiName: 'Order',
                        actionName: 'view'
                    }
                });

                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                Toast.show({
                    label: 'Error',
                    message: error.body?.message,
                    variant: 'error'
                });
            })
    }
}