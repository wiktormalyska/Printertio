import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import findAccounts from '@salesforce/apex/AccountSearchController.findAccounts';
import getDamianOrgAccounts from '@salesforce/apex/AccountSearchController.getDamianOrgAccounts'
import CreateAccountModal from 'c/createAccountModal';
import CreateExternalAccount from 'c/createExternalAccount';
import LightningToast from "lightning/toast";
import EditExternalAccount from 'c/editExternalAccount';

const COLUMNS = [
    { 
        label: 'Name', 
        fieldName: 'Name', 
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'Name' },
            name: 'view_record',
            variant: 'base'
        }
    },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Industry', fieldName: 'Industry', type: 'text' },
    { label: 'Owner Email', fieldName: 'OwnerEmail', type: 'email' },
    { label: 'Org Type', fieldName: 'OrgType', type: 'text' },
    { 
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'Edit', name: 'edit_record' }
                 
            ]
        }
    }
];

export default class AccountSearch extends NavigationMixin(LightningElement) {
    searchKey = '';
    accounts;
    columns = COLUMNS;
    isLoading = false;
    hasSearched = false;
    showCreateModal = false;

    // Paginacja
    page = 1;
    pageSize = 5;
    totalRecords;
    paginatedAccounts;
    pageSizeOptions = [
        { label: '5', value: 5 },
        { label: '10', value: 10 },
        { label: '15', value: 15 }
    ];

    // Modal handling
    async handleCreateAccountClick() {
        const result = await CreateAccountModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            content: 'Passed into content api',
        })
        if (result === 'navigateToNew') {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Account',
                    actionName: 'new'
                }
            });
        } else if (result === 'navigateToExternal') {
            const result = await CreateExternalAccount.open({
                size: 'large',
                description: 'Accessible description of modal\'s purpose',
                content: 'Passed into content api',
            })
            
            if (result === 'success') {
                await LightningToast.show(
                    {
                        label: "Account Created",
                        message: "Account was successfully created in the External Org.",
                        variant: "success",
                        mode: "dismissable"
                    },
                    this
                );
                if (this.hasSearched) {
                    this.handleSearch();
                }

            } else if (result === 'canceled') {
                await LightningToast.show(
                    {
                        label: "Canceled",
                        message: "Account creation was canceled.",
                        variant: "info",
                        mode: "dismissable"
                    },
                    this
                );

            } else if (result === 'error') {
                await LightningToast.show(
                    {
                        label: "Error",
                        message: "Failed to create account in Damian Org.",
                        variant: "error",
                        mode: "sticky"
                    },
                    this
                );
            }
        } else if (result === 'error') {
            await LightningToast.show(
                {
                    label: "Wrong Org type Picked",
                    message: "Please select Correct Org type",
                    variant: "error",
                    mode: "sticky"
                },
                this
            )
        }
    }

    handleCloseModal() {
        this.showCreateModal = false;
    }

    handleAccountCreated() {
        if(this.hasSearched){
            this.handleSearch();
        }
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
    }

    handleKeyDown(event) {
        if (event.key === 'Enter') {
            this.handleSearch();
        }
    }

    handleSearch() {
        if (this.searchKey.length < 3) {
            this.showToast('Search Term Too Short', 'Your search must be at least 3 characters long.', 'warning');
            return;
        }
        this.isLoading = true;
        this.hasSearched = true;

        Promise.all([
            findAccounts({ searchKeys: this.searchKey }),
            getDamianOrgAccounts({ searchKeys: this.searchKey })
        ]).then(([localResult, externalResult]) => {
            const localAccounts = localResult.map(record => ({
                ...record,
                OwnerEmail: record.Owner ? record.Owner.Email : '',
                OrgType: 'Local'
            }));

            const externalAccounts = externalResult.map(record => ({
                ...record,
                OwnerEmail: record.Owner ? record.Owner.Email : '',
                OrgType: 'External'
            }));
            
            this.accounts = [...localAccounts, ...externalAccounts];
            this.totalRecords = this.accounts.length;
            this.page = 1;
            this.paginate();

        }).catch(error => {
            this.accounts = null;
            this.totalRecords = 0;
            const message = error.body ? error.body.message : 'An unknown error occurred.';
            this.showToast('Search Error', message, 'error');
        }).finally(() => {
            this.isLoading = false;
        });
    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleClear() {
        this.searchKey = '';
        this.accounts = null;
        this.hasSearched = false;
        this.template.querySelector('lightning-input').value = null;
    }

    paginate() {
        const start = (this.page - 1) * this.pageSize;
        const end = this.page * this.pageSize;
        this.paginatedAccounts = this.accounts.slice(start, end);
    }

    handlePageSizeChange(event) {
        this.isLoading = true;
        this.pageSize = parseInt(event.detail.value, 10);
        this.page = 1;
        this.paginate();
        setTimeout(() => {
            this.isLoading = false;
        }, 300);
    }

    handleFirstPage() {
        if (!this.isFirstPage) {
            this.page = 1;
            this.paginate();
        }
    }

    handlePreviousPage() {
        if (this.page > 1) {
            this.page--;
            this.paginate();
        }
    }

    handleNextPage() {
        if (this.page < this.totalPages) {
            this.page++;
            this.paginate();
        }
    }

    handleLastPage() {
        if (!this.isLastPage) {
            this.page = this.totalPages;
            this.paginate();
        }
    }

    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }

    get isFirstPage() {
        return this.page === 1;
    }

    get isLastPage() {
        return this.page === this.totalPages;
    }

    get isFirstPageOrLoading() {
        return this.isFirstPage || this.isLoading;
    }

    get isLastPageOrLoading() {
        return this.isLastPage || this.isLoading;
    }

    get showNoResultsMessage() {
        return this.hasSearched && (!this.accounts || this.accounts.length === 0);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'view_record' && row.OrgType === 'Local') {
            this.navigateToRecord(row.Id);
            return;
        }
        if (actionName === 'edit_record') {
            if (row.OrgType === 'Local') {
                this.navigateToEditRecord(row.Id);
            } else if (row.OrgType === 'External'){
                this.handleEditExternalAccount(row);
            }
        }

    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    navigateToEditRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Account',
                actionName: 'edit'
            }
        });
    }

    get accountsListNotEmpty(){
        return this.accounts && this.accounts.length > 0;
    }

    async handleEditExternalAccount(row) {
        const result = await EditExternalAccount.open({
            account: row,
            size: 'large',
            description: 'Edit External Account'
        });

        if (result === 'success') {
            await LightningToast.show(
                {
                    label: "Account Updated",
                    message: "Account was successfully updated in the External Org.",
                    variant: "success",
                    mode: "dismissable"
                },
                this
            );
            
            if (this.hasSearched) {
                this.handleSearch();
            }
            
        } else if (result === 'canceled') {
            await LightningToast.show(
                {
                    label: "Canceled",
                    message: "Account update was canceled.",
                    variant: "info",
                    mode: "dismissable"
                },
                this
            );
            
        } else if (result === 'error') {
            await LightningToast.show(
                {
                    label: "Error",
                    message: "Failed to update account in External Org.",
                    variant: "error",
                    mode: "sticky"
                },
                this
            );
        }
    }
}