'use strict';

App.directive('dirDownloadRis', function ($window, $state, $stateParams, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.click( function () {
      $window.location.href = 'download_ris_pdf' + '/' + $stateParams.id;
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});

App.directive('dirDeleteRis', function ($window, $state, $stateParams, $http, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.click( function () {
      $http({
        method: "delete",
        url: "api/req_issued_slip/" + $stateParams.id,
        params: $helper.injectAuthToken({})
      }).then(function () {
        window.location.href = "/ris/collect";
      })
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});