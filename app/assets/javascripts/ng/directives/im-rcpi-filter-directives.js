'use strict';

App.directive('rcpiGetPdf', function ($window, $state, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;


    element.on('click', function () {
      $window.location.href = "/download_items_stock_card_pdf?year=" + scope.parameters.year;
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});