  'use strict';

App.directive('viewEndo', function ($window, $http, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.on('click', function (e) {
      e.preventDefault();
      // redirect to endorsement. view/revisit pdf report
      $http({
        url : '/api/endorsements/download_pdf',
        method : 'get',
        params : { id: element.attr("data-endoid") }
      })
      .then(function (response) {
        $window.location.href = '/endorsement.pdf';
      })
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
})