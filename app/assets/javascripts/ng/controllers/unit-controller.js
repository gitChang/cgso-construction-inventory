'use strict';

App.controller('UnitController', function ($rootScope, $scope, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Unit - New';


  $scope.unit = { name: null, abbrev: null };
});