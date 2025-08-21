import LightningModal from 'lightning/modal';
import { api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOrderItemsFromOrderId from '@salesforce/apex/ComplaintFormController.getOrderItemsFromOrderId';
import submitComplaintForApproval from '@salesforce/apex/ComplaintFormController.submitComplaintForApproval';
import LightningToast from "lightning/toast";
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class ComplaintForm extends NavigationMixin(LightningModal) {
    _recordId;
    currentUUID;
    caseId;
    subscription = {};
    channelName = '/event/External_Complaint_Approval_Status__e';
    isLoading = false;

    get isNotLoading() {
        return !this.isLoading;
    }

    @api
    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.loadOrderProducts();
        }
    }

    get recordId() {
        return this._recordId;
    }

    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Product Code', fieldName: 'ProductCode', type: 'text' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number' },
        { label: 'Unit Price', fieldName: 'TotalPrice', type: 'currency' },
        { label: 'Is External', fieldName: 'IsExternal', type: 'boolean' }
    ];

    orderItems = []
    selectedOrderItems = []

    connectedCallback() {
        this.loadOrderProducts()
        this.registerErrorListener()
        this.subscribeToEvents()
    }

    disconnectedCallback() {
        this.unsubscribeFromEvents();
    }

    subscribeToEvents() {
        const messageCallback = (response) => {
            this.handlePlatformEvent(response);
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {
            this.subscription = response;
            console.log('Subscribed to platform events');
        });
    }
    unsubscribeFromEvents() {
        unsubscribe(this.subscription, response => {
            console.log('Unsubscribed from platform events');
        });
    }

    registerErrorListener() {
        onError(error => {
            console.error('Błąd serwera lub utrata połączenia: ', JSON.stringify(error));
            this.showErrorToast('Error with subscription API');
        });
    }



    handlePlatformEvent(response) {
        const eventData = response.data.payload;
        console.log('Received platform event:', eventData);

        if (eventData.External_Complaint_Request_ID__c === this.currentUUID) {
            this.isLoading = false;
            if (eventData.Status__c === 'SUCCESS') {
                this.handleSuccessfulApproval();
            } else {
                this.showErrorToast('Complaint approval failed for external product');
            }
        }
    }

    async handleSuccessfulApproval() {
        this.showSuccessToast('Complaint approved successfully');
        if (this.caseId) {
            this.navigateToCase(this.caseId);
        }
    }

    async loadOrderProducts() {
        this.isLoading = true;
        if (this.recordId == undefined) {
            return
        }
        try {
            const orderItems = await getOrderItemsFromOrderId({ orderId: this.recordId });
            this.orderItems = orderItems.map(item => ({
                Id: item.Id,
                Name: item.Product2?.Name,
                ProductCode: item.Product2?.ProductCode,
                Quantity: item.Quantity,
                TotalPrice: item.TotalPrice,
                IsExternal: item.Product2?.IsExternal__c
            }));
        } catch (error) {
            this.showErrorToast(error.message)
        }
        this.isLoading = false;
    }

    showErrorToast(message) {
        LightningToast.show({
            label: "Error in Complaint Form",
            message: message,
            variant: "error",
            mode: "sticky"
        })
    }

    showSuccessToast(message) {
        LightningToast.show({
            label: "Success",
            message: message,
            variant: "success"
        })
    }

    navigateToCase(caseId) {
        console.log(caseId)
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }

    handleRowSelection(event) {
        this.selectedOrderItems = event.detail.selectedRows;
    }

    async handleComplaintSubmit() {
        this.isLoading = true;
        if (this.selectedOrderItems.length === 0) {
            this.showErrorToast('Pick at least one product to create complaint');
            this.isLoading = false;
            return;
        }

        try {
            const response = await submitComplaintForApproval({ orderItemIds: this.selectedOrderItems.map(item => item.Id) });
            this.currentUUID = response.uuid;
            this.caseId = response.caseId;
            console.log('Tracking UUID Saved: ', this.currentUUID);
            this.showSuccessToast('Complaint sent, waiting for response...');
        } catch (error) {
            this.showErrorToast(error.body?.message || error.message);
        }
    }
}