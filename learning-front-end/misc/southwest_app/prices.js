var priceTable = {
  outbounds: {},
  inbounds: {},
};
var $outbounds = $("tr[id^=outbound]");
var $inbounds = $("tr[id^=inbound]");

function parsePrices($elementsArray) {
  
  $elementsArray.forEach(function($set, idx) {
    var type = idx === 0 ? "outbounds" : "inbounds";
    
    $set.each(function() {
      var depTime = $(this).find(".depart_column .time").text();
      var indicator = $(this).find(".depart_column .indicator").text();
      var prices = [];
      
      $(this).find(".product_price").each(function() {
        prices.push( Number( this.innerText.slice(1) ) );
      });
      
      priceTable[type][depTime + indicator] = prices;
    });
  });
}

parsePrices([$outbounds, $inbounds]);
console.log(priceTable);

// NOTE: Use Js's FormData() to create & submit a form:
function sendForm() {
  var formData = new FormData();
  formData.append('username', 'johndoe');
  formData.append('id', 123456);

  var xhr = new XMLHttpRequest();
  xhr.open('POST', '/server', true);
  xhr.onload = function(e) { ... };

  xhr.send(formData);
}

// Essentially, we're just dynamically creating a <form> and tacking on <input> values to it by calling the append method.