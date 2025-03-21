'use strict';

App.controller('PoStockCardController', function ($rootScope, $scope, $http, $stateParams, HelperService) {

  // instances.
  var $helper = HelperService;

  // set page title
  $rootScope.pageTitle = 'PO Stock Card';


  $scope.po_stock_card = null;

  $http({
    url: '/api/purchase_orders/po_stack_card',
    method: 'get',
    params: { poid: $stateParams.poid }
  })
  .then( function (response) {
    $scope.po_stock_card = response.data;
  })
});