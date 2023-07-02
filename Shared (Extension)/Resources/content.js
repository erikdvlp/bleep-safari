function applyFiltersToPage(message) {
    const settings = message.response;
    
    function generateAnimalFilter(wordToReplace) {
        const animals = {"a": "armadillo", "b": "baboon", "c": "chimpanzee", "d": "donkey", "e": "elephant", "f": "flamingo", "g": "giraffe", "h": "hippopotamus", "i": "iguana", "j": "jellyfish", "k": "kangaroo", "l": "lizard", "m": "monkey", "n": "narwhal", "o": "orangatan", "p": "pigeon", "q": "quail", "r": "reindeer", "s": "squid", "t": "tortoise", "u": "urial", "v": "vulture", "w": "whale", "x": "xiaosaurus", "y": "yellowthroat", "z": "zebra"}
        return animals[wordToReplace.slice(0, 1).toLowerCase()]
    }
    
    function generateMaskFilter(wordToReplace, replaceChar) {
        var replacement = ""
        i = 0
        if (settings.showFirstLetter) {
            replacement = wordToReplace.slice(0, 1)
            i = 1
        }
        for (i; i < wordToReplace.length; i++)
            replacement += replaceChar
        return replacement
    }

    // Generate a filtered replacement word to replace a blacklisted word
    function generateReplacement(wordToReplace) {
        const filterStyleFunctions = {
            0: generateMaskFilter(wordToReplace, "*"),
            1: generateMaskFilter(wordToReplace, "-"),
            2: generateAnimalFilter(wordToReplace)
        }
        return filterStyleFunctions[settings.filterStyle]
    }

    // Replace blacklisted word in the text node
    function replaceTextInTextNode(textNode, pattern, isRegex) {
        // Skip over nodes that aren't text nodes
        if (textNode.nodeType !== Node.TEXT_NODE)
            return;
        
        // And text nodes that don't have any text
        if (!textNode.nodeValue.length)
            return;
        
        // Generate a regular expression object to perform the replacement
        var replacementExpression = pattern
        if (isRegex)
            var replacementExpression = new RegExp(pattern, "gi");
        var nodeValue = textNode.nodeValue;
        var overlap = nodeValue.match(replacementExpression);
        if (overlap) {
            overlap = overlap[0]
            var replacement = generateReplacement(overlap);
            var newNodeValue = nodeValue.replace(replacementExpression, replacement);
            
            // Perform the replacement in the DOM if the regular expression had any effect
            if (nodeValue !== newNodeValue) {
                textNode.nodeValue = newNodeValue;
                browser.runtime.sendMessage({type: "wordReplaced"});
            }
        }
    }

    // Get text nodes on the webpage
    function replace(node, pattern, isRegex) {
        switch (node.nodeType) {
            case Node.ELEMENT_NODE:
                // We don't want to replace text in an input field or textarea
                if (node.tagName.toLowerCase() === "input" || node.tagName.toLowerCase() === "textarea")
                    return;
     
                // For other types of element nodes, we explicitly fall through to iterate over their children
            case Node.DOCUMENT_NODE:
            case Node.DOCUMENT_FRAGMENT_NODE:
                // If the node is a container node, iterate over all the children and recurse into them
                var child = node.firstChild;
                var next = undefined;
                while (child) {
                    next = child.nextSibling;
                    replace(child, pattern, isRegex);
                    child = next;
                }
                break;
            case Node.TEXT_NODE:
                // If the node is a text node, perform the text replacement
                replaceTextInTextNode(node, pattern, isRegex);
                break;
        }
    }

    // Check for each blacklisted word on the webpage
    for (var i in settings.blacklist.plaintext) {
        patternToReplace = atob(settings.blacklist.plaintext[i])
        replace(document.body, patternToReplace, false);
    }
    for (var j in settings.blacklist.regex) {
        patternToReplace = atob(settings.blacklist.regex[j])
        replace(document.body, patternToReplace, true);
    }
}

function applyFiltersToPageError(error) {
    console.log("Failed to apply filters to page");
}

// Get user settings from containing app before running
function getSettingsFromApp() {
    var sending = browser.runtime.sendMessage({type: "getSettings"});
    sending.then(applyFiltersToPage, applyFiltersToPageError);
}

// Watch for changes in the document and run again
function startDocumentObserver() {
    MutationObserver = window.MutationObserver || window.WebKitMutationObserver;
    
    var observer = new MutationObserver(function(mutations, observer) {
        getSettingsFromApp()
    });
    
    observer.observe(document, {
        subtree: true,
        characterData: true,
        childList: true,
        attributes: true
    });
}

getSettingsFromApp()
startDocumentObserver()
