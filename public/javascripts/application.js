$( function() {
  /**
   * referrals/share
   *
   * Share pop up for Facebook and Twitter
   */
  $("a.share.facebook, a.share.twitter, a.share.email").click( function (e) {
    e.preventDefault();
    var share_link = $(this).attr("href");
    window.open( share_link, "Share", "height=360,width=600" );
  });

  /**
   * referrals/:id/offer
   *
   * Display expiry countdown timer
   */
  (function() {
    var countdownTimer = $("#expiry-countdown"),
        expiredAt = Date.parse( countdownTimer.attr("data-expired-at") ),
        timeLeft = expiredAt - (+new Date);

    setInterval( function() {
      if ( timeLeft > 0 ) {
        var SECOND =  1000, // 1000 milliseconds in one second
          MINUTE = 60 * SECOND,
          HOUR = 60 * MINUTE,
          DAY = 24 * HOUR,
          daysLeft = Math.floor(timeLeft/DAY),
          remainder = timeLeft - daysLeft*DAY,
          hoursLeft = Math.floor(remainder/HOUR),
          remainder = remainder - hoursLeft*HOUR,
          minutesLeft = Math.floor(remainder/MINUTE),
          remainder = remainder - minutesLeft*MINUTE,
          secondsLeft = Math.floor(remainder/SECOND),
          countdown = [];

        if (daysLeft > 0) countdown.push(daysLeft + " days");
        if (! (daysLeft === 0 && hoursLeft === 0) ) countdown.push(hoursLeft + " hours");
        if (! (daysLeft === 0 && hoursLeft === 0 && minutesLeft === 0) ) countdown.push(minutesLeft + " minutes");
        countdown.push(secondsLeft + " seconds");

        countdownTimer.html("Expires in " + countdown.join(" "));
        timeLeft = timeLeft - SECOND;
      } else {
        countdownTimer.html("Expired!");
        clearInterval();
      }
    }, 1000);
  })();

  /**
   * offer acceptance tracking
   *
   * TODO extract this into js file to disseminate to third party users
   */
  $("#accept-offer").submit( function() {
    var url = "http://socialreferral.dev/referrals/" + $("[name=referral_id]", this).val() + "/register/signup";

    $.ajax({
      url: url,
      dataType: "jsonp",
      data: $(this).serialize(),
      type: 'PUT'
    });

    // allow normal submit event to process
    if ( $(this).attr("action") === "#" ) {
      return false;
    }
  });
});
