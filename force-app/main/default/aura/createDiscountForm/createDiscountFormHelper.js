({
    toggleVisibility: function(component, selectedType) {
        component.set("v.isRecurring", false);
        component.set("v.isTimeBound", false);
        component.set("v.isConditional", false);

        if (selectedType === 'Recurring') {
            component.set("v.isRecurring", true);
        } else if (selectedType === 'Time-Bound') {
            component.set("v.isTimeBound", true);
        } else if (selectedType === 'Conditional') {
            component.set("v.isConditional", true);
        }
    },

    updateRecurringHelpText: function(component, selectedRepeatBy) {
        let helpTextMap = component.get("v.recurringHelpTextMap");
        let helpText = '';

        if (helpTextMap && selectedRepeatBy) {
            helpText = helpTextMap[selectedRepeatBy];
            if (!helpText) {
                helpText = $A.get("$Label.c.Recurring_Help_Text_Not_Found_Text");
            }

        } else {
            helpText = $A.get("$Label.c.Recurring_Help_Text_Default_Text");
        }

        component.set("v.recurringHelpText", helpText);
    },

    showError: function(component, message) {
        const errorEvent = $A.get("e.force:showToast");
        errorEvent.setParams({
            "title": "Error",
            "message": message,
            "type": "error"
        });
        errorEvent.fire();
    },

    getConditionLogicPicklistValues: function(component) {
        const action = component.get("c.getConditionLogicPicklistValues");
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const picklistValues = response.getReturnValue();
                component.set("v.conditionLogicOptions", picklistValues);
            } else if (state === "ERROR") {
                const errors = response.getError();
                console.error("Error fetching picklist values: ", errors);
            }
        });
        $A.enqueueAction(action);
    }
})