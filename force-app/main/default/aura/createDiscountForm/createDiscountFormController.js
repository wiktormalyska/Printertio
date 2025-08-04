({
    doInit: function(component, event, helper) {
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
                console.error('5. [ERROR] Wystąpiły błędy:', errors);
                if (errors && errors[0] && errors[0].message) {
                    alert("Błąd podczas pobierania opisów z Apex: " + errors[0].message);
                }
            }
        });

        $A.enqueueAction(action);
    },

    handleTypeChange: function(component, event, helper) {
        let selectedType = event.getSource().get("v.value");
        component.set("v.selectedDiscountType", selectedType);
        console.log("Selected Discount Type: " + selectedType);

        helper.toggleVisibility(component, selectedType);
    },

    handleRepeatByChange: function(component, event, helper) {
        let selectedRepeatBy = event.getSource().get("v.value");
        component.set("v.selectedRepeatBy", selectedRepeatBy);
        helper.updateRecurringHelpText(component, selectedRepeatBy);
    },

    handleValueTypeChange: function(component, event, helper) {
        const selectedValue = event.getSource().get("v.value");
        const discountRecord = component.get("v.discountRecord");
        discountRecord.Value_Type__c = selectedValue;
        component.set("v.discountRecord", discountRecord);
    },

    handleSave: function(component, event, helper) {
        let discount = component.get("v.discountRecord");

        discount.Name = component.find("discountName").get("v.value");
        discount.Discount_Value__c = component.find("discountValue").get("v.value");
        discount.Value_Type__c = component.get("v.selectedValueType");
        discount.Recurring_Date_Repeat_By__c = component.get("v.selectedRepeatBy");
        discount.Recurring_Date_Start__c = component.find("recurringStartDate") ? component.find("recurringStartDate").get("v.value") : null;
        discount.Recurring_Date_End__c = component.find("recurringEndDate") ? component.find("recurringEndDate").get("v.value") : null;
        discount.Time_Bound_Start__c = component.find("timeBoundStartDate") ? component.find("timeBoundStartDate").get("v.value") : null;
        discount.Time_Bound_End__c = component.find("timeBoundEndDate") ? component.find("timeBoundEndDate").get("v.value") : null;
        discount.Conditional_Criteria__c = component.find("conditionalCriteria") ? component.find("conditionalCriteria").get("v.value") : null;

        component.set("v.discountRecord", discount);
        console.log("Discount Record to Save: ", discount);

        const action = component.get("c.saveDiscount");
        action.setParams({ discount: discount });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get("e.force:showToast").setParams({
                    "title": "Success",
                    "message": "Discount saved successfully.",
                    "type": "success"
                }).fire();
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
});