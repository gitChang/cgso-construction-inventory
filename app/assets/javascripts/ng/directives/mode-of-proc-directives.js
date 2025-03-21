'use strict';

// Directive add a row item.
App.directive('dirBtnSaveModeOfProc', function ($window, $state, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;


    element.click( function () {
      $.ajax({
        url : $routes.mode_of_procurements_path(),
        type : 'post',
        data : $helper.injectAuthToken(scope.mode),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function () {
        $window.location.pathname = $state.href('home');
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