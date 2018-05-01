// demos
var clipboardDemos = new Clipboard('[data-clipboard-target]');

function showButtonMessage(trigger, success) {
  var message = success ? "Copied!" : "Copy Failed";
  var $currentText = $(trigger).text();
  
  $(trigger).text(message);
  setTimeout(function() {
    $(trigger).text( $currentText );
  }, 3000);
}

clipboardDemos.on('success', function(e) {
    e.clearSelection();
    console.info('Action:', e.action);
    console.info('Text:', e.text);
    console.info('Trigger:', e.trigger);
    showButtonMessage(e.trigger, true);
});

clipboardDemos.on('error', function(e) {
    console.error('Action:', e.action);
    console.error('Trigger:', e.trigger);
    showButtonMessage(e.trigger, false);
});

