'use strict';

// Directive add a row item.
App.directive('dirBtnLogin', function ($window, $state, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;


    element.click( function () {
      $.ajax({
        url : $routes.login_path(),
        type : 'post',
        data : $helper.injectAuthToken(scope.credentials),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function () {
        $window.location.pathname = $state.href('home');
      })
      .fail(function (error) {
        // display failed message.
        $('#login-failed-msg').removeClass('hidden');
        // apply error style.
        $('.form-group').addClass('has-error');
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