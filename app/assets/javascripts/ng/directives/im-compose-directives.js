'use strict';

// Directive add a row item.
App.directive('dirBtnAddItem', function ($window, $state, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;


    element.click( function () {
      $.ajax({
        url : $routes.item_masterlists_path(),
        type : 'post',
        data : $helper.injectAuthToken(scope.item),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function () {
        $window.location.pathname = $state.href('im.collect');
      })
      .fail(function (error) {
        var key = error.responseJSON[0], msg = error.responseJSON[1];

        // hightlight error field and display message
        $helper.hightlightErrorField(key, msg);
      })
      .always(function () {
        $helper.animateProcessStop(element);
      })
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});