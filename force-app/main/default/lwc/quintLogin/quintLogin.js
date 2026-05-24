import { LightningElement } from "lwc";

import SiteLogin from "@salesforce/apex/QuintLogin.SiteLogin";

export default class QuintLogin extends LightningElement {
  username;
  password;
  error;
  isListenerAdded = false;

  renderedCallback() {
    if (this.isListenerAdded) return;
    this.isListenerAdded = true;

    window.addEventListener("keydown", this.handleEnterPress);
  }

  handleEnterPress = (e) => {
    if (e.key === "Enter") {
      this.handleSubmit();
    }
  };

  handleUsernameChange(event) {
    this.username = event.target.value;
    this.error = "";
  }

  handlePasswordChange(event) {
    this.password = event.target.value;
    this.error = "";
  }

  get isFailed() {
    return this.error !== null;
  }

  handleSubmit() {
    if (!this.username || !this.password) {
      this.error = "Please enter username and password !";
      return;
    }

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

  disconnectedCallback() {
    window.removeEventListener("keydown", this.handleEnterPress);
  }
}
