'use strict';

App.controller('ProjectsCollectController', function ($rootScope, $scope, $http, HelperService) {

  // instances
  var $helper = HelperService;
  var $routes = Routes;

  // set page title
  $rootScope.pageTitle = 'Projects';

  $scope.query = null;

  // filter projects, fetch already endorsed.
  //$scope.endorsed_only = false;

  // array of selected projects
  $rootScope.selected_projects = [];

  $scope.getProjects = function (page) {

    if ($scope.query) {
      if ( $scope.query.indexOf(':') > -1 ) {

        var key = $scope.query.split(':')[0];
        var val = $scope.query.split(':')[1];

        $http({
          url : $routes.projects_path(),
          method : 'get',
          params : {
            page: page,
            key: key,
            val: val
            //endorsed_only: $scope.endorsed_only
          }
        })
        .then(function (response) {
          $scope.projects = response.data.projects;
          $scope.from_index = response.data.from_index
          $scope.to_index = response.data.to_index
          $scope.total_entries = response.data.total_entries;
          $scope.current_page = parseInt(response.data.current_page)
        })
      }
    }

    if (!$scope.query) {
      $http({
        url : $routes.projects_path(),
        method : 'get',
        params : {
          page: page
          //endorsed_only: $scope.endorsed_only
        }
      })
      .then(function (response) {
        $scope.projects = response.data.projects;
        $scope.from_index = response.data.from_index
        $scope.to_index = response.data.to_index
        $scope.total_entries = response.data.total_entries;
        $scope.current_page = parseInt(response.data.current_page)
      })
    }
  }

  // refresh projects collection upon searched.
  $scope.$watch('query', function (q) {
    if (q == null) return;
    $scope.getProjects(1);
  })

  // refresh projects collection upon endorsed project check.
  //$scope.$watch('endorsed_only', function (eo) {
  //  if (eo == null) return;
  //  $rootScope.selected_projects = [];
  //  $scope.getProjects(1);
  //})

  $scope.getRowNumber = function (isfirst, ngIndex) {
    if (isfirst) return $scope.from_index;
    return parseInt($scope.from_index) + parseInt(ngIndex);
  }

});