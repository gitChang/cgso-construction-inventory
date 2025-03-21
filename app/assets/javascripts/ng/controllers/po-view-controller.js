'use strict';

App.controller('PoViewController', function ($rootScope, $scope, $http, $stateParams, HelperService) {

  // vars, instances
  var $helper = HelperService;
  var $routes = Routes;


  // content
  $scope.po = {};

  $http({
    url : $routes.purchase_order_path($stateParams.id),
    method : 'get'
  })
  .then(function (response) {
    $scope.po = response.data;
    // set page title
    $rootScope.pageTitle = 'PO No. ' + $scope.po.po_number;
  })

  // get logs
  $http({
    url : $routes.get_logs_change_logs_path(),
    method : 'get',
    params : { poid: $stateParams.id }
  })
  .then(function (response) {
    $scope.change_logs = response.data;
  })


  $scope.totalAmountInWords = null;
  $scope.totalAmount = 0.00;
  $scope.$watchCollection('po.po_items', function (newValue) {
    var total = 0.00;

    if (newValue) {
      $.each(newValue, function (index, value) {
        total += parseFloat(value.amount);
      })
    }

    $scope.totalAmount = $helper.formatMoney(total.toFixed(2), 2);
    $scope.totalAmountInWords = $helper.toWords($scope.totalAmount);
  })


  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

});