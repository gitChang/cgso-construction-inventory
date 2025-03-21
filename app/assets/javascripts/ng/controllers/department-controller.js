'use strict';

App.controller('DepartmentController', function ($rootScope, $scope, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Department - New';

  $scope.Department = { name: null, abbrev: null };
});