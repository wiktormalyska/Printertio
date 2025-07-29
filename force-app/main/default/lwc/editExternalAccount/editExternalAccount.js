import LightningModal from 'lightning/modal';
import { NavigationMixin } from 'lightning/navigation';
import { api } from 'lwc';
import updateAccountInDamianOrg from '@salesforce/apex/AccountSearchController.updateAccountInDamianOrg';

export default class EditExternalAccount extends NavigationMixin(LightningModal) {
    @api account

    accountId;
    accountName;
    phone;
    industry;
    ownerEmail;
    isLoading = false;

    industryOptions = [
        { label: 'Agriculture', value: 'Agriculture' },
        { label: 'Apparel', value: 'Apparel' },
        { label: 'Banking', value: 'Banking' },
        { label: 'Biotechnology', value: 'Biotechnology' },
        { label: 'Chemicals', value: 'Chemicals' },
        { label: 'Communications', value: 'Communications' },
        { label: 'Construction', value: 'Construction' },
        { label: 'Consulting', value: 'Consulting' },
        { label: 'Education', value: 'Education' },
        { label: 'Electronics', value: 'Electronics' },
        { label: 'Energy', value: 'Energy' },
        { label: 'Engineering', value: 'Engineering' },
        { label: 'Entertainment', value: 'Entertainment' },
        { label: 'Environmental', value: 'Environmental' },
        { label: 'Finance', value: 'Finance' },
        { label: 'Food & Beverage', value: 'Food & Beverage' },
        { label: 'Government', value: 'Government' },
        { label: 'Healthcare', value: 'Healthcare' },
        { label: 'Hospitality', value: 'Hospitality' },
        { label: 'Insurance', value: 'Insurance' },
        { label: 'Machinery', value: 'Machinery' },
        { label: 'Manufacturing', value: 'Manufacturing' },
        { label: 'Media', value: 'Media' },
        { label: 'Not For Profit', value: 'Not For Profit' },
        { label: 'Recreation', value: 'Recreation' },
        { label: 'Retail', value: 'Retail' },
        { label: 'Shipping', value: 'Shipping' },
        { label: 'Technology', value: 'Technology' },
        { label: 'Telecommunications', value: 'Telecommunications' },
        { label: 'Transportation', value: 'Transportation' },
        { label: 'Utilities', value: 'Utilities' },
        { label: 'Other', value: 'Other' }
    ];

    connectedCallback() {
        // Pobierz dane z account przekazane podczas otwierania modala
        if (this.account) {
            this.accountId = this.account.Id;
            this.accountName = this.account.Name;
            this.phone = this.account.Phone;
            this.industry = this.account.Industry;
            
            // Pobierz owner email z account
            if (this.account.Owner && this.account.Owner.Email) {
                this.ownerEmail = this.account.Owner.Email;
            }
        }
    }

    handleAccountNameChange(event) {
        this.accountName = event.target.value;
    }
    
    handlePhoneChange(event) {
        this.phone = event.target.value;
    }
    
    handleIndustryChange(event) {
        this.industry = event.detail.value;
    }
    
    handleOwnerEmailChange(event) {
        this.ownerEmail = event.target.value;
    }

    handleUpdate() {
        console.log('Updating account:', this.accountId);
        console.log('Account Name:', this.accountName);
        console.log('Phone:', this.phone);
        console.log('Industry:', this.industry);
        console.log('Owner Email:', this.ownerEmail);

        this.isLoading = true;
        
        updateAccountInDamianOrg({
            accountId: this.accountId,
            accountName: this.accountName,
            phone: this.phone,
            industry: this.industry,
            ownerEmail: this.ownerEmail
        })
        .then(result => {
            console.log('Account updated successfully:', result);
            this.close('success');
        })
        .catch(error => {
            console.error('Error updating account:', error);
            this.close('error');
        })
        .finally(() => {
            this.isLoading = false;
        })
    }

    handleCancel() {
        this.close('canceled');
    }
}