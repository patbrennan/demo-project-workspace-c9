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