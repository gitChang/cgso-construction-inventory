'use strict';

App.controller('SupplierViewController', function ($rootScope, $scope, $stateParams, $http, HelperService) {

  // instances
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Supplier';

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  // get supplier and items
  $http({
    url: $routes.supplier_path($stateParams.id),
    method: 'get'
  })
  .then( function (response) {
    $scope.supplier = response.data;
  })
});