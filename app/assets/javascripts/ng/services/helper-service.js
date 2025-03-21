'use strict';

App.service('HelperService', function ($templateCache, $cookies) {

  // this
  var self = this;

  // check if server is online
  self.isOnline = function() {
    $.ajax({
     type: 'get',
     url: '/images/tagum-logo.png',
     success: function () {
       return;
     },
     error: function (XMLHttpRequest, textStatus, errorThrown) {
       if(textStatus == 'timeout') {
          $('#notify-center').show()
                             .find('.msg')
                             .text('Connection to Server lost.');
       }
     }
   });
  }


  // show notification to user.
  self.notify = function (msg) {
    var notifyCenter = $('#notif-center')

    self.removeNotify(); // remove first.

    // place msg and display warning
    notifyCenter.find('.msg').text(msg);
    notifyCenter.removeClass('hidden');
  }
  // remove notification.
  self.removeNotify = function () {
    var notifyCenter = $('#notif-center');

    notifyCenter.find('.msg').text('');
    notifyCenter.addClass('hidden');
  }


  // cache the original html content of element requesting.
  self.originalHtml;
  // show animate process
  self.animateProcess = function (element) {
    // cache original template for reset html content.
    self.originalHtml = $(element).html();
    $(element).html('<i class="fa fa-spinner fa-pulse fa-lg"></i>');

    return true;
  }
  // restore original html content to animated element.
  self.animateProcessStop = function (element) {
    // reset element html
    $(element).html(self.originalHtml);
    return true;
  }


  // combat can't verify csrf token from backend
  self.getAuthToken = function () {
    return { authenticity_token: $cookies.get('xsrf_token') };
  }
  self.injectAuthToken = function (payload) {
    return $.extend(payload, self.getAuthToken());
  }


  // hightlight form-group with error input
  self.hightlightErrorField = function (key, msg) {
    // reset hightlight first
    $('.form-group, .panel').removeClass('has-error');

    // hightlight target form-group.
    $('#model_' + key).addClass('has-error')

    // set focus
    $('#model_' + key).find('.form-control').focus();
    $('#model_' + key).find('.form-control').select();

    // display error message on notification.
    self.notify(msg);
  }

  self.formatMoney = function(amt, c, d, t){
    var n = amt,
        c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "",
        j = (j = i.length) > 3 ? j % 3 : 0;
       return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
   };


  // Convert numbers to words
  // copyright 25th July 2006, by Stephen Chapman http://javascript.about.com
  // permission to use this Javascript on your web page is granted
  // provided that all of the code (including this copyright notice) is
  // used exactly as shown (you can change the numbering system if you wish)

  // American Numbering System
  var th = ['','thousand','million', 'billion','trillion'];
  // uncomment this line for English Number System
  // var th = ['','thousand','million', 'milliard','billion'];

  var dg = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
  var tn = ['ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'];
  var tw = ['twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

  self.toWords = function (s) {
    s = s.toString();
    s = s.replace(/[\, ]/g, '');
    if (s != parseFloat(s)) return 'not a number';
    var x = s.indexOf('.');
    if (x == -1) x = s.length;
    if (x > 15) return 'too big';
    var n = s.split('');
    var str = '';
    var sk = 0;
    for (var i = 0; i < x; i++) {
      if ((x - i) % 3 == 2) {
        if (n[i] == '1') {
          str += tn[Number(n[i + 1])] + ' ';
          i++;
          sk = 1;
        } else if (n[i] != 0) {
          str += tw[n[i] - 2] + ' ';
          sk = 1;
        }
      } else if (n[i] != 0) {
        str += dg[n[i]] + ' ';
        if ((x - i) % 3 == 0) str += 'hundred ';
        sk = 1;
      }
      if ((x - i) % 3 == 1) {
        if (sk) str += th[(x - i - 1) / 3] + ' ';
        sk = 0;
      }
    }
    if (x != s.length) {
      var y = s.length;
      str += 'point ';
      for (var i = x + 1; i < y; i++) str += dg[n[i]] + ' ';
    }

    var numWords = str.replace(/\s+/g, ' ').toLowerCase();

    // remove point zer zero and replace with only.
    numWords = numWords.replace('point zero zero', '');

    // replace Point with And when not 0.0
    numWords = numWords.replace('point', 'and');

    // remove first zero and replace with centavo/s
    numWords = numWords.replace('zero', '');
    //
    if (numWords.match(/ and /)) {
      if (numWords.match(/ and  one /g)) // double space after 'and'. fix this!
        numWords = numWords.concat(' centavo');
      else
        numWords = numWords.concat(' centavos');
    }

    return numWords.trim().concat('.').toUpperCase();
  }

});