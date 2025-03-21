'use strict';

App.controller('ImComposeController', function ($rootScope, $scope, $http, HelperService, clipboard) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Item Masterlist - New';

  $scope.item = { photo_data: null, filename: null, name: null, unit: null, supply: null };

  // unit collection.
  $scope.units = null;
  $scope.refreshUnits = function (unit) {
    $http({
      url: $routes.units_path(),
      method: 'get',
      params: { unit: unit }
    })
    .then( function (response) {
      $scope.units = response.data;
    })
  };

  // system roles collection.
  $scope.supplies = null;
  $http({
    url: $routes.supplies_path(),
    method: 'get'
  })
  .then( function (response) {
    $scope.supplies = response.data;
  })


  // click button to copy symbol.
  $scope.copy_diameter = function () {
    clipboard.copyText('Ø');
  };

  $scope.copy_half = function () {
    clipboard.copyText('½');
  };

  $scope.copy_one_fourth = function () {
    clipboard.copyText('¼');
  };

  $scope.copy_three_fourth = function () {
    clipboard.copyText('¾');
  };

  $scope.copy_one_eigth = function () {
    clipboard.copyText('⅛');
  };

  $scope.copy_squared = function () {
    clipboard.copyText('²');
  };

  $scope.copy_cube = function () {
    clipboard.copyText('³');
  };
  $scope.copy_degree = function () {
    clipboard.copyText('°');
  }
});