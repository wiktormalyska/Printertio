import LightningModal from 'lightning/modal';
import { NavigationMixin } from 'lightning/navigation';
import createAccountInDamianOrg from '@salesforce/apex/AccountSearchController.createAccountInDamianOrg';

export default class CreateExternalAccount extends NavigationMixin(LightningModal)  {
    accountName;
    phone;
    industry;
    ownerEmail;

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

    handleCreate() {
        console.log('Account Name:', this.accountName);
        console.log('Phone:', this.phone);
        console.log('Industry:', this.industry);
        console.log('Owner Email:', this.ownerEmail);
        
        const params = {
            accountName: this.accountName,
            phone: this.phone,
            industry: this.industry,
            ownerEmail: this.ownerEmail
        };
        
        createAccountInDamianOrg(params)
        .then(result => {
            console.log('Account created successfully:', result);
            this.close('success');
        })
        .catch(error => {
            console.error('Error creating account:', error);
            this.close('error');
        })
    }

    handleCancel() {
        this.close('canceled')
    }
}