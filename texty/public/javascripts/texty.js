// $.ajaxSetup({
//   cache: false
// });

$(document).ready(function() {
  // Hide reply form & show if reply is clicked
  $(".reply").hide();
  $(".reply_button").on("click", function() {
    $(".reply", this).slideDown("fast");
    $(".reply textarea", this).focus();
  });
  
  // pad with zeros for formatting
  function pad(num) {
    if (num < 10) {
      return "0" + num;
    } else {
      return num;
    }
  }

  // Get browser's timezone & set current date / time
  var userDate = new Date();
  var userTimeZone = ( userDate.getTimezoneOffset()/60 )*(-1);
  var month = userDate.getMonth() + 1;
  var date = userDate.getDate();
  var year = userDate.getFullYear();

  var newDate = (year + "-" + pad(month) + "-" + pad(date));

  $("input[name=timezone]").val(userTimeZone);
  $("#current_date").val(newDate);

  var hours = userDate.getHours();
  var mins = userDate.getMinutes();
  var plus = (mins < 58 ? 2 : 0);

  var newTime = (pad(hours) + ":" + pad(mins + plus));

  $("#current_time").val(newTime);
  
  // countdown chars left for textarea
  $("[name=body]").keyup(function() {
    var contentLength = $(this).val().length;
    $("#countdown").text(160 - contentLength);
    
    if (160 - contentLength < 10) {
      $("#countdown").css("color", "red");
    } else {
      $("#countdown").css("color", "black");
    }
  });
  
  // Convert dates in history to better format
  $(".local_date").each(function() {
    var systemDate = $(this).text();
    var jsDate = new Date(systemDate.trim());

    var month = jsDate.getMonth() + 1;
    var date = jsDate.getDate();
    var year = jsDate.getFullYear();

    var hours = jsDate.getHours();
    var mins = jsDate.getMinutes();

    var newDate = (month + "/" + date + "/" + year);
    var newTime = (hours + ":" + pad(mins));

    var localDate = (newDate + ", @ " + newTime);

    $(this).text(localDate);
  });
});

// Check for history updates every 2 seconds & load it
// function loadList() {
//     $("#sms_list").load("/update-history");
// }

// setInterval(function() {
//   loadList();
// }, 20000);