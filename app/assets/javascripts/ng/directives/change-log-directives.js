'use strict';

App.directive('dirGenerateKey', function ($state, $stateParams, $window, HelperService) {

  function linker(scope, element) {

    // instances
    var $helper = HelperService;
    var $routes = Routes;


    element.click(function (event) {
      event.preventDefault();

      if (!scope.log.doc && !scope.log.doc_number && !scope.log.message) {
        return;
      }

      $.ajax({
        url : $routes.change_logs_path(),
        type : 'post',
        data : $helper.injectAuthToken(scope.log),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function (response) {
        if (Object.keys(response)[0] === 'edit_key') {
          scope.edit_key = response.edit_key
          scope.us_disabled = true;
          scope.dn_input_disabled = true;
          scope.msg_textarea_disabled = true;

          scope.$apply();
        }
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
    restrict: 'C',
    link: linker
  };
})