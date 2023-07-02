// Send a message from the Safari Web Extension to the containing app extension
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    function gotNativeResponse(nativeResponse) {
        sendResponse({response: nativeResponse});
    }
    function gotNativeError(error) {
        sendResponse({response: `Error: ${error}`});
    }
    if (request.type == "getSettings") {
        var sending = browser.runtime.sendNativeMessage({message: "getSettings"});
        sending.then(gotNativeResponse, gotNativeError);
        return true
    }
    else if (request.type == "wordReplaced") {
        browser.runtime.sendNativeMessage({message: "wordReplaced"});
    }
});
