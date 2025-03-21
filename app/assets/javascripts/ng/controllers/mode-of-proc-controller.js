'use strict';

App.controller('ModeOfProcurementController', function ($rootScope, $scope, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Mode of Procurement - New';


  $scope.mode = { mode: null };
});