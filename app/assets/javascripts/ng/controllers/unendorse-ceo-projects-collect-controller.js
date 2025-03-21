'use strict';

App.controller('UnendorseCeoProjectsCollectController', function ($rootScope, $scope, $stateParams, $http, HelperService) {

  // instances
  var $helper = HelperService;
  var $routes = Routes;

  // set page title
  $rootScope.pageTitle = 'Unendorse CEO Projects';

  $scope.query = null;

  $http({
    url : $routes.unendorse_ceo_projects_endorsement_ceos_path(),
    method : 'get'
  })
  .then(function (response) {
    $scope.unendorse_ceo_projects = response.data;
  })

});