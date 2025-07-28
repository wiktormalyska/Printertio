import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from 'lightning/uiRecordApi';
import createSignatureDocument from '@salesforce/apex/GenerateOrderPdfAction.createSignatureDocument';
import generatePdfWithSignatureAndReturnVersionId from '@salesforce/apex/GenerateOrderPdfAction.generatePdfWithSignatureAndReturnVersionId';

const ORDER_FIELDS = ['Order.OrderNumber'];

export default class ElectronicSignature extends LightningElement {
    @api recordId; // Order ID
    @track showSpinner = false;
    @track latestPdfVersionId; // Store the latest PDF version ID
    
    @wire(getRecord, { recordId: '$recordId', fields: ORDER_FIELDS })
    orderRecord;
    
    get orderNumber() {
        return this.orderRecord?.data?.fields?.OrderNumber?.value || this.recordId;
    }
    
    isDrawing = false;
    canvas;
    context;
    
    renderedCallback() {
        if (!this.canvas) {
            this.canvas = this.refs.signatureCanvas;
            if (this.canvas) {
                this.context = this.canvas.getContext('2d');
                this.context.strokeStyle = '#0176d3';
                this.context.lineWidth = 3;
                this.context.lineCap = 'round';
                this.context.lineJoin = 'round';
            }
        }
    }
    
    getCoordinates(event) {
        const rect = this.canvas.getBoundingClientRect();
        const scaleX = this.canvas.width / rect.width;
        const scaleY = this.canvas.height / rect.height;
        
        let clientX, clientY;
        
        if (event.touches && event.touches[0]) {
            clientX = event.touches[0].clientX;
            clientY = event.touches[0].clientY;
        } else {
            clientX = event.clientX;
            clientY = event.clientY;
        }
        
        return {
            x: (clientX - rect.left) * scaleX,
            y: (clientY - rect.top) * scaleY
        };
    }
    
    startDrawing(event) {
        event.preventDefault();
        this.isDrawing = true;
        
        const coords = this.getCoordinates(event);
        
        this.context.beginPath();
        this.context.moveTo(coords.x, coords.y);
    }
    
    draw(event) {
        if (!this.isDrawing) return;
        
        event.preventDefault();
        const coords = this.getCoordinates(event);
        
        this.context.lineTo(coords.x, coords.y);
        this.context.stroke();
    }
    
    stopDrawing(event) {
        if (!this.isDrawing) return;
        event.preventDefault();
        this.isDrawing = false;
        this.context.closePath();
    }
    
    clearSignature() {
        if (this.context) {
            this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
        }
    }
    
    async saveSignature() {
        const imageData = this.context.getImageData(0, 0, this.canvas.width, this.canvas.height);
        const hasSignature = imageData.data.some(channel => channel !== 0);
        
        if (!hasSignature) {
            this.showToast('Error', 'Please provide a signature before saving.', 'error');
            return;
        }
    
        this.showSpinner = true;
        
        const signatureDataUrl = this.canvas.toDataURL('image/png');
        const base64Data = signatureDataUrl.split(',')[1];
        createSignatureDocument({
            orderId: this.recordId,
            signatureBase64: base64Data
        }).then(signatureVersionId => generatePdfWithSignatureAndReturnVersionId({
            orderId: this.recordId,
            signatureVersionId
        })).then(result => {
            if (result.isSuccess) {
                let successMessage = 'PDF generated successfully with electronic signature!';
                
                // If we have the latest PDF version ID, log it or use it as needed
                if (result.latestPdfVersionId) {
                    console.log('Latest PDF Version ID:', result.latestPdfVersionId);
                    successMessage += ` Version ID: ${result.latestPdfVersionId}`;
                    
                    // Store the version ID for potential future use
                    this.latestPdfVersionId = result.latestPdfVersionId;
                }
                
                this.showToast('Success', successMessage, 'success');
                this.closeModal();
            } else {
                this.showToast('Error', result.message, 'error');
            }
        }).catch(error => {
                console.error('Error generating PDF:', error);
                this.showToast('Error', 'Failed to generate PDF: ' + (error.body?.message || error.message), 'error');
        }).finally(() => {
                this.showSpinner = false;
        });
    }
    
    handleCancel() {
        this.closeModal();
    }
    
    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}