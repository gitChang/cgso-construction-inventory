'use strict';

App.service('TopNavUtility', function($templateCache) {

  //-- doc header template.
  this.pageBrander = function (brand, tplPath) {
    //-- change page title
    $('#brander').text(brand);

    //-- render navbar items from template
    $('#top-menu-items').html($templateCache.get(tplPath));
  };


  //-- ?
})