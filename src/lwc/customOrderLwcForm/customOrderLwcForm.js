import { LightningElement,wire } from 'lwc';
import LightningToast from "lightning/toast";
import { createRecord, deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Contract.AccountId';
import STATUS_FIELD from '@salesforce/schema/Contract.Status';
import START_DATE_FIELD from '@salesforce/schema/Contract.StartDate';
import CONTRACT_TERM_FIELD from '@salesforce/schema/Contract.ContractTerm';

import BILLING_STREET_FIELD from '@salesforce/schema/Contract.BillingStreet';
import BILLING_CITY_FIELD from '@salesforce/schema/Contract.BillingCity';
import BILLING_STATE_FIELD from '@salesforce/schema/Contract.BillingState';
import BILLING_POSTAL_CODE_FIELD from '@salesforce/schema/Contract.BillingPostalCode';
import BILLING_COUNTRY_FIELD from '@salesforce/schema/Contract.BillingCountry';

import ORDER_OBJECT from '@salesforce/schema/Order';
import ORDER_STATUS_FIELD from '@salesforce/schema/Order.Status';
import ORDER_ACCOUNT_ID_FIELD from '@salesforce/schema/Order.AccountId';
import ORDER_EFFECTIVE_DATE_FIELD from '@salesforce/schema/Order.EffectiveDate';
import ORDER_CONTRACT_ID_FIELD from '@salesforce/schema/Order.ContractId';
import ORDER_SHIPPING_STREET_FIELD from '@salesforce/schema/Order.ShippingStreet';
import ORDER_SHIPPING_CITY_FIELD from '@salesforce/schema/Order.ShippingCity';
import ORDER_SHIPPING_STATE_FIELD from '@salesforce/schema/Order.ShippingState';
import ORDER_SHIPPING_POSTAL_CODE_FIELD from '@salesforce/schema/Order.ShippingPostalCode';
import ORDER_SHIPPING_COUNTRY_FIELD from '@salesforce/schema/Order.ShippingCountry';
import ORDER_BILLING_STREET_FIELD from '@salesforce/schema/Order.BillingStreet';
import ORDER_BILLING_CITY_FIELD from '@salesforce/schema/Order.BillingCity';
import ORDER_BILLING_STATE_FIELD from '@salesforce/schema/Order.BillingState';
import ORDER_BILLING_POSTAL_CODE_FIELD from '@salesforce/schema/Order.BillingPostalCode';
import ORDER_BILLING_COUNTRY_FIELD from '@salesforce/schema/Order.BillingCountry';

export default class CustomOrderLwcForm extends NavigationMixin(LightningElement) {

    //Order Fields
    startDate;
    accountId;
    contractTerm = 1;
    shippingAddress = {};
    useSameAddress = true;
    billingAddress = {};

    connectedCallback() {
        this.startDate = this.getToday;
    }

    //OnChange
    handleAccountChange(event) {
        this.accountId = event.detail.value[0];
    }
    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }
    handleContractTermChange(event) {
        this.contractTerm = event.target.value;
    }
    handleShippingAddressChange(event) {
        this.shippingAddress = {
            street: event.detail.street,
            city: event.detail.city,
            state: event.detail.province,
            postalCode: event.detail.postalCode,
            country: event.detail.country
        }
        if (this.useSameAddress) {
            this.billingAddress = this.shippingAddress;
        }
    }
    handleAddressCheckboxChange(event) {
        this.useSameAddress = event.target.checked;
        if (this.useSameAddress) {
            this.billingAddress = this.shippingAddress;
        }
    }
    handleBillingAddressChange(event) {
        this.billingAddress = {
            street: event.detail.street,
            city: event.detail.city,
            state: event.detail.province,
            postalCode: event.detail.postalCode,
            country: event.detail.country
        }
    }

    async handleSubmit() {
        console.log(this.status);
        if (
            !this.startDate ||
            !this.accountId ||
            !this.contractTerm ||
            !this.shippingAddress ||
            !this.billingAddress 
        ) {
            await LightningToast.show({
                label: 'Error',
                message: 'Please fill in all required fields.',
                variant: 'error',
                mode: 'sticky'
            }, this);
            return;
        }

        let contract = await this.createContract();
        console.log(contract.id);
        let order = await this.createOrder(contract.id);
        console.log(order.id);

        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: order.id,
                    actionName: 'view'
                }
            });
        } catch (error) {
            await LightningToast.show({
                label: 'Error',
                message: `Error navigating to order: ${JSON.stringify(error)}`,
                variant: 'error',
                mode: 'sticky'
            }, this);
        }
    }

    async createContract() {

        let contract = null;

        const fields = {};
        fields[ACCOUNT_ID_FIELD.fieldApiName] = this.accountId;
        fields[STATUS_FIELD.fieldApiName] = "Draft";
        fields[START_DATE_FIELD.fieldApiName] = this.startDate;
        fields[CONTRACT_TERM_FIELD.fieldApiName] = this.contractTerm;
        fields[BILLING_STREET_FIELD.fieldApiName] = this.billingAddress.street;
        fields[BILLING_CITY_FIELD.fieldApiName] = this.billingAddress.city;
        fields[BILLING_STATE_FIELD.fieldApiName] = this.billingAddress.state;
        fields[BILLING_POSTAL_CODE_FIELD.fieldApiName] = this.billingAddress.postalCode;
        fields[BILLING_COUNTRY_FIELD.fieldApiName] = this.billingAddress.country;

        const recordInput = { apiName: CONTRACT_OBJECT.objectApiName, fields };
        try {
            contract = await createRecord(recordInput);
        } catch (error) {
            await LightningToast.show({
                label: 'Error',
                message: `Error creating contract: ${JSON.stringify(error)}`,
                variant: 'error',
                mode: 'sticky'
            }, this);
        }
        return contract;
    }

    async createOrder(contractId) {
        let order = null;

        const fields = {};
        fields[ORDER_STATUS_FIELD.fieldApiName] = "Draft";
        fields[ORDER_ACCOUNT_ID_FIELD.fieldApiName] = this.accountId;
        fields[ORDER_EFFECTIVE_DATE_FIELD.fieldApiName] = this.startDate;
        fields[ORDER_CONTRACT_ID_FIELD.fieldApiName] = contractId;
        fields[ORDER_SHIPPING_STREET_FIELD.fieldApiName] = this.shippingAddress.street;
        fields[ORDER_SHIPPING_CITY_FIELD.fieldApiName] = this.shippingAddress.city;
        fields[ORDER_SHIPPING_STATE_FIELD.fieldApiName] = this.shippingAddress.state;
        fields[ORDER_SHIPPING_POSTAL_CODE_FIELD.fieldApiName] = this.shippingAddress.postalCode;
        fields[ORDER_SHIPPING_COUNTRY_FIELD.fieldApiName] = this.shippingAddress.country;
        fields[ORDER_BILLING_STREET_FIELD.fieldApiName] = this.billingAddress.street;
        fields[ORDER_BILLING_CITY_FIELD.fieldApiName] = this.billingAddress.city;
        fields[ORDER_BILLING_STATE_FIELD.fieldApiName] = this.billingAddress.state;
        fields[ORDER_BILLING_POSTAL_CODE_FIELD.fieldApiName] = this.billingAddress.postalCode;
        fields[ORDER_BILLING_COUNTRY_FIELD.fieldApiName] = this.billingAddress.country;
        

        const recordInput = { apiName: ORDER_OBJECT.objectApiName, fields };
        try {
            order = await createRecord(recordInput);
            await LightningToast.show({
                label: 'Success',
                message: 'Order created successfully.',
                variant: 'success',
                mode: 'dismissable'
            }, this);
        } catch (error) {
            await deleteRecord(contractId);
            await LightningToast.show({
                label: 'Error',
                message: `Error creating order: ${JSON.stringify(error)}`,
                variant: 'error',
                mode: 'sticky'
            }, this);
        }
        return order;
    }

    //Helpers
    get getToday() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0'); 
        var mm = String(today.getMonth() + 1).padStart(2, '0');            
        var yyyy = today.getFullYear();
        return yyyy + '-' + mm + '-' + dd;
    }     
}