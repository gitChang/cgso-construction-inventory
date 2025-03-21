'use strict';

App.controller('ImCollectController', function ($rootScope, $scope, $http, HelperService) {

  // instances
  var $helper = HelperService;
  var $routes = Routes;

  // set page title
  $rootScope.pageTitle = 'Item Masterlist';

  $scope.itemName = null;
  $scope.getItems = function (page) {
    var name = $scope.itemName;
    $http({
      url : $routes.item_masterlists_path(),
      method : 'get',
      params: { page: page, name: name }
    })
    .then(function (response) {
      $scope.items = response.data.items;
      $scope.from_index = response.data.from_index
      $scope.to_index = response.data.to_index
      $scope.total_entries = response.data.total_entries;
      $scope.current_page = parseInt(response.data.current_page)
    })
  }


  // refresh item collection upon searched.
  $scope.$watch('itemName', function () {
    if ($scope.itemName == null) return;
    $scope.getItems(1);
  })


  $scope.getRowNumber = function (isfirst, ngIndex) {
    if (isfirst) return $scope.from_index;
    return parseInt($scope.from_index) + parseInt(ngIndex);
  }
});