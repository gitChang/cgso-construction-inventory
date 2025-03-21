'use strict';

App.controller('ImRcpiFilterController', function ($rootScope, $scope, $http, HelperService) {

  // instances
  var $helper = HelperService;
  var $routes = Routes;

  // set page title
  $rootScope.pageTitle = 'RCPI Filter Parameters';

  $scope.parameters = { year: null };
});