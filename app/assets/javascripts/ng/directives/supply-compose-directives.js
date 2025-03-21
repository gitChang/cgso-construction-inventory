'use strict';

// Directive add a row item.
App.directive('dirBtnSaveSupply', function ($window, $state, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;


    element.click( function () {
      $.ajax({
        url : $routes.supplies_path(),
        type : 'post',
        data : $helper.injectAuthToken(scope.supply),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function () {
        $window.location.pathname = $state.href('im');
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