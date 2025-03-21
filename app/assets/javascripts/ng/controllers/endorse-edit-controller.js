'use strict';

App.controller('EndorseEditController', function ($rootScope, $scope, $http, $state, $stateParams, HelperService) {

  // vars and instances.
  var $routes = Routes;
  var $helper = HelperService;

  // set page title.
  $rootScope.pageTitle = 'Edit Endorsement';

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  // pow number search
  $scope.pow_number = null;

  // load endorsement
  $http({
    url : $routes.endorsement_path($stateParams.id),
    method : 'get'
  })
  .then(function (response) {
    $scope.endo = response.data;
  })

  $scope.$watchCollection('endo', function (en) {
    console.log(en);
  });

});
