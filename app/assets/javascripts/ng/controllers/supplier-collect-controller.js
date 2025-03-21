'use strict';

App.controller('SupplierCollectController', function ($rootScope, $scope, $http, HelperService) {

  // instances
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Supplier';

  $scope.supplierName = null;


  $scope.getSuppliers = function (page) {

    if ($scope.supplierName) {
      $http({
        url : $routes.suppliers_path(),
        method : 'get',
        params : { page: page, name: $scope.supplierName }
      })
      .then(function (response) {
        $scope.suppliers = response.data.suppliers;
        $scope.from_index = response.data.from_index
        $scope.to_index = response.data.to_index
        $scope.total_entries = response.data.total_entries;
        $scope.current_page = parseInt(response.data.current_page)
      })
    }

    if (!$scope.supplierName) {
      $http({
        url : $routes.suppliers_path(),
        method : 'get',
        params : { page: page }
      })
      .then(function (response) {
        $scope.suppliers = response.data.suppliers;
        $scope.from_index = response.data.from_index
        $scope.to_index = response.data.to_index
        $scope.total_entries = response.data.total_entries;
        $scope.current_page = parseInt(response.data.current_page)
      })
    }
  }

  // refresh po collection upon searched.
  $scope.$watch('supplierName', function (s) {
    if (s == null) return;
    $scope.getSuppliers(1);
  })

  $scope.getRowNumber = function (isfirst, ngIndex) {
    if (isfirst) return $scope.from_index;
    return parseInt($scope.from_index) + parseInt(ngIndex);
  }

  //============


  // all suppliers
  /**$scope.suppliers = null;
  $http({
    url : $routes.suppliers_path(),
    method : 'get'
  })
  .then(function (response) {
    $scope.suppliers = response.data;
  })

  // refresh item collection upon searched.
  $scope.supplierName = null;
  $scope.$watch('supplierName', function (name) {
    $http({
      url : $routes.suppliers_path(),
      method : 'get',
      params : { name: name }
    })
    .then(function (response) {
      // load to items.
      $scope.suppliers = response.data;
    })
  })**/
});