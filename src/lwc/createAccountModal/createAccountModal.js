import LightningModal from 'lightning/modal';
import LightningToast from "lightning/toast";
import { NavigationMixin } from 'lightning/navigation';

export default class CreateAccountModal extends NavigationMixin(LightningModal)  {
    selectedOrg = 'Local';

    orgOptions = [
        { label: 'Local Org', value: 'Local' },
        { label: 'External Org', value: 'External' }
    ];

    handleOrgChange(event) {
        this.selectedOrg = event.detail.value;
    }

    async handlePickType() {
        if (this.selectedOrg === 'Local') {
            this.close('navigateToNew'); 
        } else if (this.selectedOrg === 'External') {
            this.close('navigateToExternal')
        } else {
            this.close('error'); 
        }
    }

    handleCancel() {
        this.close('canceled')
    }
}