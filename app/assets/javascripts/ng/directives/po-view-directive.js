'use strict';

App.directive('dirDownloadPo', function ($window, $state, $stateParams, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.click( function () {
      $window.location.href = 'download_po_pdf' + '/' + $stateParams.id;
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});