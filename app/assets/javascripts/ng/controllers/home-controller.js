'use strict';

App.controller('HomeController', function ($rootScope, $scope, $http) {

  // instances
  var $routes = Routes;

  // set page title
  $rootScope.pageTitle = 'Welcome';


  // get count of po's
  $scope.badges = {};
  $http({
    url : $routes.home_index_path(),
    method : 'get'
  })
  .then(function (response) {
    $scope.badges = response.data;
  })


  // prevent access if not admin.
  $http({
    url : $routes.is_admin_application_index_path(),
    method : 'get'
  })
  .then(function (response) {
    if (response.data.access_granted !== 'yes') {
      $scope.limited = true;
    }
  })
});