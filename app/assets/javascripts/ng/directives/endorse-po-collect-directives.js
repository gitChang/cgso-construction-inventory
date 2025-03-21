  'use strict';

App.directive('viewEndoPo', function ($window, $http, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.on('click', function (e) {
      e.preventDefault();
      // redirect to endorsement. view/revisit pdf report
      $http({
        url : '/api/endorsement_pos/download_pdf',
        method : 'get',
        params : { id: element.attr("data-endopoid") }
      })
      .then(function (response) {
        $window.location.href = '/endorsement_po.pdf';
      })
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
})