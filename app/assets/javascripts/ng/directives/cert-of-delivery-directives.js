'use strict';

App.directive('dirDownloadCert', function ($window, $state, $stateParams, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.click( function () {
      $window.location.href = 'download_cert_of_delivery_report_pdf' + '/' + $stateParams.pr_number;
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});