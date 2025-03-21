'use strict';

App.controller('SavingsProjectController', function ($rootScope, $scope, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;

  // set page title
  $rootScope.pageTitle = 'Savings - Project';


  $scope.que_pow_number = null;
  $scope.project = {};

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  $scope.$watch('que_pow_number', function (pow) {
    $http({
      url: $routes.per_project_savings_path(),
      method: 'get',
      params: { pow_number: pow }
    })
    .then( function (response) {
      $scope.project = response.data;
    })
  })
});