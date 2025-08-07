({
    doInit: function(component, event, helper) {
        component.set("v.discountRecord", {
            'sobjectType': 'Discount__c'
        });

        component.set("v.discountTypeOptions", [
            { 'label': $A.get("$Label.c.Discount_Type_Option_Recurring"), 'value': 'Recurring' },
            { 'label': $A.get("$Label.c.Discount_Type_Option_Time_Bound"), 'value': 'Time-Bound' },
            { 'label': $A.get("$Label.c.Discount_Type_Option_Conditional"), 'value': 'Conditional' }
        ]);

        component.set("v.repeatByOptions", [
            { 'label': $A.get("$Label.c.Recursive_Option_Daily"), 'value': 'Daily' },
            { 'label': $A.get("$Label.c.Recursive_Option_Weekly"), 'value': 'Weekly' },
            { 'label': $A.get("$Label.c.Recursive_Option_Monthly"), 'value': 'Monthly' },
            { 'label': $A.get("$Label.c.Recursive_Option_Yearly"), 'value': 'Yearly' }
        ]);

        const picklistAction = component.get("c.getConditionLogicPicklistValues");
        picklistAction.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const picklistValues = response.getReturnValue();
                component.set("v.conditionLogicOptions", picklistValues);
            } else if (state === "ERROR") {
                const errors = response.getError();
                console.error("Error fetching picklist values: ", errors);
            }
        });
        $A.enqueueAction(picklistAction);

        const action = component.get("c.getRecurringHelpTexts");
        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === "SUCCESS") {
                const helpTextMap = response.getReturnValue();

                component.set("v.recurringHelpTextMap", helpTextMap);

                helper.toggleVisibility(component, component.get("v.selectedDiscountType"));
                helper.updateRecurringHelpText(component, component.get("v.discountRecord.Recurring_Date_Repeat_By__c"));

            } else if (state === "ERROR") {
                const errors = response.getError();
            }
        });

        $A.enqueueAction(action);
    },

    handleTypeChange: function(component, event, helper) {
        let selectedType = event.getSource().get("v.value");
        component.set("v.selectedDiscountType", selectedType);

        helper.toggleVisibility(component, selectedType);
    },

    handleRepeatByChange: function(component, event, helper) {
        let selectedRepeatBy = event.getSource().get("v.value");
        component.set("v.selectedRepeatBy", selectedRepeatBy);
        helper.updateRecurringHelpText(component, selectedRepeatBy);
    },

    handleValueTypeChange: function(component, event, helper) {
        const selectedValue = event.getSource().get("v.value");
        component.set("v.selectedValueType", selectedValue);
    },

    handleSave: function(component, event, helper) {
        const discountName = component.get("v.discountName");
        const discountValue = component.get("v.discountValue");
        const selectedDiscountType = component.get("v.selectedDiscountType");
        const selectedValueType = component.get("v.selectedValueType");

        if (!discountName || discountName.trim() === "") {
            helper.showError(component, $A.get("$Label.c.Error_Discount_Name_Required_Text"));
            return;
        }

        if (!selectedDiscountType) {
            helper.showError(component, $A.get("$Label.c.Error_Discount_Type_Required_Text"));
            return;
        }

        if (!selectedValueType) {
            helper.showError(component, $A.get("$Label.c.Error_Value_Type_Required_Text"));
            return;
        }

        if (!discountValue) {
            helper.showError(component, $A.get("$Label.c.Error_Discount_Value_Required_Text"));
            return;
        }

        if (selectedDiscountType === 'Recurring') {
            const selectedRepeatBy = component.get("v.selectedRepeatBy");
            const recurringStartDate = component.get("v.recurringStartDate");
            const recurringEndDate = component.get("v.recurringEndDate");

            if (!selectedRepeatBy) {
                helper.showError(component, $A.get("$Label.c.Error_Select_Repeat_By_Required_Text"));
                return;
            }

            if (!recurringStartDate) {
                helper.showError(component, $A.get("$Label.c.Error_Start_Date_Required_Text"));
                return;
            }

            if (!recurringEndDate) {
                helper.showError(component, $A.get("$Label.c.Error_End_Date_Required_Text"));
                return;
            }
        }

        if (selectedDiscountType === 'Time-Bound') {
            const timeBoundStartDate = component.get("v.timeBoundStartDate");
            const timeBoundEndDate = component.get("v.timeBoundEndDate");

            if (!timeBoundStartDate) {
                helper.showError(component, $A.get("$Label.c.Error_Time_Bound_Start_Date_Required_Text"));
                return;
            }

            if (!timeBoundEndDate) {
                helper.showError(component, $A.get("$Label.c.Error_Time_Bound_End_Date_Required_Text"));
                return;
            }
        }

        if (selectedDiscountType === 'Conditional') {
            const conditionalCriteria = component.get("v.conditionalCriteria");

            if (!conditionalCriteria || conditionalCriteria.trim() === "") {
                helper.showError(component, $A.get("$Label.c.Error_Conditional_Criteria_Required_Text"));
                return;
            }
        }
        component.set("v.isLoading", true);
        let discount = component.get("v.discountRecord");

        discount.Name = discountName;
        discount.Discount_Value__c = discountValue;
        discount.Value_Type__c = selectedValueType;
        discount.Discount_Type__c = selectedDiscountType;
        discount.Recurring_Date_Repeat_By__c = component.get("v.selectedRepeatBy");
        discount.Recurring_Date_Start__c = component.get("v.recurringStartDate");
        discount.Recurring_Date_End__c = component.get("v.recurringEndDate");
        discount.Start_Date__c = component.get("v.timeBoundStartDate");
        discount.End_Date__c = component.get("v.timeBoundEndDate");
        discount.Condition_Logic__c = component.get("v.conditionalCriteria");
        discount.Is_Active__c = component.get("v.isActivated");

        component.set("v.discountRecord", discount);

        const action = component.get("c.saveDiscount");
        action.setParams({ discount: discount });

        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            const state = response.getState();
            if (state === "SUCCESS") {
                const discountId = response.getReturnValue();

                const dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get("e.force:showToast").setParams({
                    "title": "Success",
                    "message": $A.get("$Label.c.Discount_Saved_Successfully_Text"),
                    "type": "success"
                }).fire();

                const navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": discountId,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            } else if (state === "ERROR") {
                const errors = response.getError();
                const message = (errors && errors[0] && errors[0].message) ? errors[0].message : "Unknown error";
                $A.get("e.force:showToast").setParams({
                    "title": "Error",
                    "message": message,
                    "type": "error"
                }).fire();
            }
        });

        $A.enqueueAction(action);
    },

    handleCancel: function(component, event, helper) {
        const dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    handleConditionalCriteriaChange: function(component, event, helper) {
        const conditionalCriteria = event.getSource().get("v.value");
        component.set("v.conditionalCriteria", conditionalCriteria);
    },

    handleActivationChange: function(component, event, helper) {
        const isActive = event.getSource().get("v.checked");
        component.set("v.isActivated", isActive);
    }
});