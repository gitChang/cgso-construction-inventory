'use strict';

App.controller('SavingsItemController', function ($rootScope, $scope, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Savings - Item';

  $scope.item = { res: null };
  // item collections
  $scope.items = [];
  $scope.refreshItems = function (name) {
    if (!name) {
      $scope.items = [];
      return;
    }

    $http({
      url : $routes.item_masterlists_path(),
      method : 'get',
      params : { name: name }
    })
    .then(function (response) {
      $scope.items = response.data.items;
    })
  };


  $scope.savings = { savings_items: [] };

  $http({
    url: $routes.per_item_savings_path(),
    method: 'get'
  })
  .then( function (response) {
    $scope.savings = response.data;
  })


  $scope.getSavingsItems = function (page) {

    if ($scope.item.res) {
      $http({
        url : $routes.per_item_savings_path(),
        method : 'get',
        params : { page: page, item_id: $scope.item.res.id }
      })
      .then(function (response) {
        $scope.savings = response.data;
        $scope.from_index = response.data.from_index;
        $scope.to_index = response.data.to_index;
        $scope.total_entries = response.data.total_entries;
        $scope.current_page = parseInt(response.data.current_page);
      })
    }

    if (!$scope.item.res) {
      $http({
        url : $routes.per_item_savings_path(),
        method : 'get',
        params : { page: page }
      })
      .then(function (response) {
        $scope.savings = response.data;
        $scope.from_index = response.data.from_index;
        $scope.to_index = response.data.to_index;
        $scope.total_entries = response.data.total_entries;
        $scope.current_page = parseInt(response.data.current_page);
      })
    }
  }

  // refresh ris collection upon searched.
  $scope.$watch('item.res', function (item) {
    if (item == null) return;
    $scope.getSavingsItems(1);
  })

});