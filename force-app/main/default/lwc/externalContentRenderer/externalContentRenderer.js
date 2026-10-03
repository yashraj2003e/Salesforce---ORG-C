import { LightningElement, api, wire } from "lwc";
import getExternalContentDetails from "@salesforce/apex/ExternalContent.getExternalContentDetails";

export default class ExternalContentRenderer extends LightningElement {
  @api externalContentName;

  method;
  outboundData;
  endpointURL;

  hasSubmitted = false;

  @wire(getExternalContentDetails, {
    ExternalContentName: "$externalContentName"
  })
  retrievedExternalContent({ data, error }) {
    if (data) {
      this.method = data.method;
      this.outboundData = data.outboundData;
      this.endpointURL = data.endpointURL;
    } else if (error) {
      console.error(error);
    }
  }

  renderedCallback() {
    if (
      this.hasSubmitted ||
      !this.endpointURL ||
      !this.method ||
      this.outboundData === undefined
    ) {
      return;
    }

    const form = this.template.querySelector("form");

    if (form) {
      this.hasSubmitted = true;
      form.submit();
    }
  }
}
