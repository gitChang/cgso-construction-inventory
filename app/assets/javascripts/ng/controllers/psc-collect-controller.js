'use strict';

App.controller('PscCollectController', function ($rootScope, $scope, $http, HelperService) {

  // instances
  var $helper = HelperService;
  var $routes = Routes;

  // set page title
  $rootScope.pageTitle = 'Project\'s Stock Card';


  // all items
  $scope.projects = null;

  // refresh stock collection upon searched.
  $scope.powNumber = null;
  $scope.$watch('powNumber', function (pow) {
    $http({
    url : $routes.project_stock_card_index_path(),
      method : 'get',
      params : { pow_number: pow }
    })
    .then(function (response) {
      // load to items.
      $scope.projects = response.data;
    })
  })
});