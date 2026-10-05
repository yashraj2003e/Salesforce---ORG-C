import { LightningElement, api } from "lwc";
import getExternalContentDetails from "@salesforce/apex/ExternalContent.getExternalContentDetails";

export default class ExternalContentRenderer extends LightningElement {
  @api externalContentName;

  method;
  outboundData;
  endpointURL;


  isLoading;
  hasSubmitted = false;


  // * Migrated to Imperative APEX call 
  // @wire(getExternalContentDetails, {
  //   ExternalContentName: "$externalContentName"
  // })
  // retrievedExternalContent({ data, error }) {
  //   if (data) {
  //     this.method = data.method;
  //     this.outboundData = data.outboundData;
  //     this.endpointURL = data.endpointURL;
  //   } else if (error) {
  //     console.error(error);
  //   }
  // }

  connectedCallback() {
    this.getExternalContent();
  }

  async getExternalContent() {
    this.isLoading = true;
    try {
      const data = await getExternalContentDetails({ExternalContentName:this.externalContentName});
      this.method = data.method;
      this.outboundData = data.outboundData;
      this.endpointURL = data.endpointURL;
    } 
    catch(err) {
      console.log(err);
      this.isLoading = false;
    }
  }

  handleiFrameLoad() {
    if(this.hasSubmitted) this.isLoading = false;
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