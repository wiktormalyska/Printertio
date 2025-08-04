({
    doInit: function(component, event, helper) {
        var action = component.get("c.getRecurringHelpTexts");
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var helpTextMap = response.getReturnValue();

                component.set("v.recurringHelpTextMap", helpTextMap);

                helper.toggleVisibility(component, component.get("v.selectedDiscountType"));
                helper.updateRecurringHelpText(component, component.get("v.discountRecord.Recurring_Date_Repeat_By__c"));

            } else if (state === "ERROR") {
                var errors = response.getError();
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
    }
});