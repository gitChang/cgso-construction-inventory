'use strict';

App.controller('SupplierComposeController', function ($rootScope, $scope, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Supplier - New';


  $scope.supplier = { name: null, address: null };

});