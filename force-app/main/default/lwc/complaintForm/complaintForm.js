import LightningModal from 'lightning/modal';
import { api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOrderItemsFromOrderId from '@salesforce/apex/ComplaintFormController.getOrderItemsFromOrderId';
import submitComplaintForApproval from '@salesforce/apex/ComplaintFormController.submitComplaintForApproval';
import LightningToast from "lightning/toast";
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

import getExternalComplaintApprovalStatusChannel from '@salesforce/apex/PlatformEventConst.getExternalComplaintApprovalStatusChannel';
import getExternalComplaintApprovalStatus_StatusSuccess from '@salesforce/apex/PlatformEventConst.getExternalComplaintApprovalStatus_StatusSuccess'
import getExternalComplaintApprovalStatus_StatusFailed from '@salesforce/apex/PlatformEventConst.getExternalComplaintApprovalStatus_StatusFailed'

import Submit_Complaint from "@salesforce/label/c.Submit_Complaint";
import Name from "@salesforce/label/c.Name";
import Product_Code from "@salesforce/label/c.Product_Code"
import Quantity from "@salesforce/label/c.Quantity"
import Unit_Price from "@salesforce/label/c.Unit_Price"
import Is_External from "@salesforce/label/c.Is_External"
import Error_with_subscription_API from "@salesforce/label/c.Error_with_subscription_API"
import Complaint_approval_failed_for_external_product from "@salesforce/label/c.Complaint_approval_failed_for_external_product"
import Complaint_approved_successfully from "@salesforce/label/c.Complaint_approved_successfully"
import Error_in_Complaint_Form from "@salesforce/label/c.Error_in_Complaint_Form"
import Success from "@salesforce/label/c.Success"
import Pick_at_least_one_product_to_create_complaint from "@salesforce/label/c.Pick_at_least_one_product_to_create_complaint"
import Complaint_sent_waiting_for_response from "@salesforce/label/c.Complaint_sent_waiting_for_response"
import Complaint_Form from "@salesforce/label/c.Complaint_Form"

import PRODUCT_NAME_FIELD from '@salesforce/schema/Product2.Name'
import PRODUCT_CODE_FIELD from '@salesforce/schema/Product2.ProductCode'
import QUANTITY_FIELD from '@salesforce/schema/OrderItem.Quantity'
import TOTAL_PRICE_FIELD from '@salesforce/schema/OrderItem.TotalPrice'
import PRODUCT_IS_EXTERNAL_FIELD from '@salesforce/schema/Product2.IsExternal__c'

export default class ComplaintForm extends NavigationMixin(LightningModal) {
    label = {
        Submit_Complaint,
        Name,
        Product_Code,
        Quantity,
        Unit_Price,
        Is_External,
        Error_with_subscription_API,
        Complaint_approval_failed_for_external_product,
        Complaint_approved_successfully,
        Error_in_Complaint_Form,
        Success,
        Pick_at_least_one_product_to_create_complaint,
        Complaint_sent_waiting_for_response,
        Complaint_Form
    }

    _recordId;
    currentUUID;
    caseId;
    subscription = {};
    channelName = getExternalComplaintApprovalStatusChannel();
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

    get columns() {
        return [
            { label: this.label.Name, fieldName: PRODUCT_NAME_FIELD.fieldApiName, type: 'text' },
            { label: this.label.Product_Code, fieldName: PRODUCT_CODE_FIELD.fieldApiName, type: 'text' },
            { label: this.label.Quantity, fieldName: QUANTITY_FIELD.fieldApiName, type: 'number' },
            { label: this.label.Unit_Price, fieldName: TOTAL_PRICE_FIELD.fieldApiName, type: 'currency' },
            { label: this.label.Is_External, fieldName: PRODUCT_IS_EXTERNAL_FIELD.fieldApiName, type: 'boolean' }
        ];
    }

    orderItems = []
    selectedOrderItems = []

    async connectedCallback() {
        this.channelName = await getExternalComplaintApprovalStatusChannel();
        this.loadOrderProducts();
        this.registerErrorListener();
        await this.subscribeToEvents(this.channelName);
    }

    disconnectedCallback() {
        this.unsubscribeFromEvents();
    }

    async subscribeToEvents(channelName) {
        const messageCallback = async (response) => {
            await this.handlePlatformEvent(response);
        };
        subscribe(channelName, -1, messageCallback).then(response => {
            this.subscription = response;
        });
    }

    unsubscribeFromEvents() {
        unsubscribe(this.subscription, response => {
        });
    }

    registerErrorListener() {
        onError(error => {
            this.showErrorToast(this.label.Error_with_subscription_API);
        });
    }



    async handlePlatformEvent(response) {
        const eventData = response.data.payload;
        if (eventData.External_Complaint_Request_ID__c === this.currentUUID) {
            this.isLoading = false;
            let statusSuccess = await getExternalComplaintApprovalStatus_StatusSuccess();
            if (eventData.Status__c === statusSuccess) {
                this.handleSuccessfulApproval();
            } else {
                this.showErrorToast(this.label.Complaint_approval_failed_for_external_product);
            }
        }
    }

    async handleSuccessfulApproval() {
        this.showSuccessToast(this.label.Complaint_approved_successfully);
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
                IsExternal__c: item.Product2?.IsExternal__c
            }));
        } catch (error) {
            this.showErrorToast(error.message)
        }
        this.isLoading = false;
    }

    showErrorToast(message) {
        LightningToast.show({
            label: this.label.Error_in_Complaint_Form,
            message: message,
            variant: "error",
            mode: "sticky"
        })
    }

    showSuccessToast(message) {
        LightningToast.show({
            label: this.label.Success,
            message: message,
            variant: "success"
        })
    }

    navigateToCase(caseId) {
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
            this.showErrorToast(this.label.Pick_at_least_one_product_to_create_complaint);
            this.isLoading = false;
            return;
        }

        try {
            const response = await submitComplaintForApproval({ orderItemIds: this.selectedOrderItems.map(item => item.Id) });
            this.currentUUID = response.uuid;
            this.caseId = response.caseId;
            this.showSuccessToast(this.label.Complaint_sent_waiting_for_response);
        } catch (error) {
            this.showErrorToast(error.body?.message || error.message);
        }
    }
}