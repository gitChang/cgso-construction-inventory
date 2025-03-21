'use strict';

App.directive('dirSavePrs', function ($state, $stateParams, $window, HelperService) {

  function linker(scope, element) {

    // instances
    var $helper = HelperService;
    var $routes = Routes;


    element.click(function (event) {
      event.preventDefault();
      $.ajax({
        url : $routes.save_prs_projects_path(),
        type : 'post',
        data : $helper.injectAuthToken({ pow_number: $stateParams.pow_number, pr_number: $stateParams.pr_number, items: scope.prs.materials }),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function () {
        $window.location.pathname = $state.href('projects');
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
});


App.directive('dirDownloadPrs', function ($window, $state, $stateParams, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.click( function () {
      $window.location.href = 'download_prs_report_pdf' + '/' + $stateParams.pr_number;
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});