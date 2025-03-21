'use strict';

App.directive('dirDownloadStockCard', function ($window, $state, $stateParams, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.click( function () {
      $window.location.href = "/download_stock_card_pdf/" + $stateParams.pr_number;
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});