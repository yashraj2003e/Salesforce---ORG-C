import { LightningElement } from "lwc";

import resetPassword from "@salesforce/apex/quintForgotPassword.resetPassword";

export default class QuingForgotPassword extends LightningElement {
  username;
  isPasswordReset = null;

  get isSuccess() {
    return this.isPasswordReset === "SUCCESS";
  }

  get isFailed() {
    return this.isPasswordReset === "ERROR";
  }

  handleUsernameChange(event) {
    this.username = event.target.value;
    this.isPasswordReset = null;
  }

  async handleSubmit() {
    console.log(1);
    if (this.username) {
      try {
        const result = await resetPassword({ username: this.username });
        if (result) {
          this.isPasswordReset = "SUCCESS";
          // eslint-disable-next-line @lwc/lwc/no-async-operation
          window.setTimeout(() => {
            window.location.href = "/quint/login";
          }, 5000);
        } else {
          this.isPasswordReset = "ERROR";
        }
      } catch (error) {
        console.log(error);
        this.isPasswordReset = "ERROR";
      }
    }
  }
}
