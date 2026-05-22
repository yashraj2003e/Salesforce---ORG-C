import { LightningElement } from 'lwc';

import resetPassword from '@salesforce/apex/quintForgotPassword.resetPassword';

export default class QuingForgotPassword extends LightningElement {

    username;
    isPasswordReset = null;

    get isSuccess() {
        return this.isPasswordReset === 'SUCCESS';
    }

    get isFailed() {
        return this.isPasswordReset === 'ERROR';
    }

    handleUsernameChange(event) {
        this.username = event.target.value;
    }

    async handleSubmit() {
        console.log(1);
        if(this.username) {

            try {
                resetPassword({ username: this.username }).then(result => {
                    if (result) {
                        this.isPasswordReset = 'SUCCESS';
                        setTimeout(() => {
                        window.location.href = 'quint/login';
                        }, 5000);
                    }
                    else {
                        this.isPasswordReset = 'ERROR';
                    }
                })
            } catch(error) {
                console.log(error);
                this.isPasswordReset = 'ERROR';
            }
        }
    }
}