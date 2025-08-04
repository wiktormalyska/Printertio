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
                helpText = 'Description for this option was not found.';
            }

        } else {
            helpText = 'Please select a repeat option to see the description.';
        }

        component.set("v.recurringHelpText", helpText);
    }
})