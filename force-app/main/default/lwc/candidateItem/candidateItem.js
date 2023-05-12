import { LightningElement, wire, api} from 'lwc';

// Імпортуємо канал звʼязку для події додатку (application event)
import { publish, MessageContext} from 'lightning/messageService';
import APP_EVENT from '@salesforce/messageChannel/SelectedContactEvent__c';


export default class CandidateItem extends LightningElement {

    @api contact;

    // метод, який підключає імпортований канал звʼязку
    @wire(MessageContext)
    context; 

    tileClick() {
        var payload = { contactMessage: this.contact };
        // викликати подію додатку (publish) та передати payload в повідомлення.
        // коли вибираємо кандидата, клікаємо на аватар, то ця подія має передатись в інший компонент - candidateDetail
        // розкоментуйте, та передайте змінні в подію: 
        publish(this.context, APP_EVENT, payload);
    }
    
}