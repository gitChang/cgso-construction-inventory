'use strict';

App.controller('EndorsePoEditController', function ($rootScope, $scope, $http, $state, $stateParams, HelperService) {

  // vars and instances.
  var $routes = Routes;
  var $helper = HelperService;

  // set page title.
  $rootScope.pageTitle = 'Edit Endorsement per PO';

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  // pow number search
  $scope.pow_number = null;
  $scope.project_pos = [];
  $scope.endo = { pos: [] };

  // load endorsement
  $http({
    url : '/api/endorsement_pos/' + $stateParams.id,
    method : 'get'
  })
  .then(function (response) {
    $scope.endo = response.data;
  })

  $scope.$watchCollection('endo', function (en) {
    console.log(en);
  });

  $scope.$watch('pow_number', function(pow) {
    if (!pow) {
      return;
    }
    $http({
      method: "get",
      url: "/api/endorsement_pos/get_project_pos",
      params: { pow_number: pow }
    })
    .then(function (response) {
      $scope.project_pos = response.data;
    })
  })

});
