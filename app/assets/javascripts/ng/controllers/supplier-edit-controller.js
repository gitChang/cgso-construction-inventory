'use strict';

App.controller('SupplierEditController', function ($rootScope, $scope, $http, $stateParams, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Supplier - Edit';


  $scope.supplier = null;

  $http({
    url: $routes.edit_supplier_path($stateParams.id),
    method: 'get'
  })
  .then( function (response) {
    $scope.supplier = response.data;
  })
});