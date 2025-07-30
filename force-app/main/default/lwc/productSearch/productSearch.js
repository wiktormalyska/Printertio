import LightningModal from 'lightning/modal';
import { CloseActionScreenEvent } from 'lightning/actions';
import { api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Toast from 'lightning/toast';
import getProducts from '@salesforce/apex/ProductSearchController.getProducts';
import getProductFamilies from '@salesforce/apex/ProductSearchController.getProductFamilies';
import createOrderForOpportunity from '@salesforce/apex/ProductSearchController.createOrderForOpportunity';
import FIRST_PAGE from './productPickForm.html';
import SECOND_PAGE from './summaryOfForm.html';

export default class ProductSearch extends NavigationMixin(LightningModal) {
    @api recordId;
    stage = 0;

    searchFieldValue = ''
    selectedFamily = ''

    allProducts = []
    products = []
    familyOptions = []

    selectedProducts = [];
    selectedProductIds = [];

    columns = [
        { label: 'Product Name', fieldName: 'Name', type: 'text' },
        { label: 'Product Code', fieldName: 'ProductCode', type: 'text' },
        { label: 'Product Family', fieldName: 'Family', type: 'text' }
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
            this.allProducts = await getProducts({
                searchTerm: this.searchFieldValue,
                family: this.selectedFamily
            });
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

    handleGoToSummary() {
        if (this.selectedProductIds.length > 0) {
            this.stage = 1;
        } else {
            Toast.show({
                label: 'Warning',
                message: 'Please select at least one product',
                variant: 'warning'
            });
        }
    }

    handleCreateOrder() {
        console.log('Creating order with selected products:', this.selectedProductIds);
        console.log('Record ID:', this.recordId);
        createOrderForOpportunity({
            opportunityId: this.recordId,
            products: this.selectedProductIds
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