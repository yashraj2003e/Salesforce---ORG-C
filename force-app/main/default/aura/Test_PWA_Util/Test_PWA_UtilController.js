({
  doInit: function (component) {
    if (window.f4ath) {
      component.set("v.addToHomeScreenPrompt", window.f4ath);
    } else {
      document.addEventListener(
        "f4ath",
        $A.getCallback(function (evt) {
          component.set("v.addToHomeScreenPrompt", evt.detail);
        }),
        false
      );
    }
  },

  showPrompt: function (component) {
    var prompt = component.get("v.addToHomeScreenPrompt");

    if (prompt) {
      prompt.prompt();
    } else {
      console.log("No prompt available");
    }
  }
});
