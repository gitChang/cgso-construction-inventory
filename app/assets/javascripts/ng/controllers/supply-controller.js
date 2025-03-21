'use strict';

App.controller('SupplyController', function ($rootScope, $scope, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Supply - New';


  $scope.supply = { kind: null };
});