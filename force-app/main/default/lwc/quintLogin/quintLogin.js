import { LightningElement } from "lwc";

import SiteLogin from "@salesforce/apex/QuintLogin.SiteLogin";

export default class QuintLogin extends LightningElement {
  username;
  password;
  error;

  handleUsernameChange(event) {
    this.username = event.target.value;
  }

  handlePasswordChange(event) {
    this.password = event.target.value;
  }

  get isFailed() {
    return this.error !== null;
  }

  handleSubmit() {
    try {
      console.log(this.username, this.password);
      SiteLogin({ username: this.username, password: this.password })
        .then((siteUrl) => {
          console.log(siteUrl);
          if (siteUrl) {
            window.location.href = siteUrl;
          } else {
            this.error = "Invalid username/password";
          }
        })
        .catch((e) => {
          console.log(e);
          this.error = "An error occurred !";
        });
    } catch (e) {
      console.log(e);
      this.error = "Invalid username/password";
    }
  }
}
