'use strict';

App.controller('StockCardController', function ($rootScope, $scope, $stateParams, $http, HelperService) {

  // instances
  var $helper = HelperService;
  var $routes = Routes;

  // set page title
  $rootScope.pageTitle = 'Stock Card';

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  $http({
    url : $routes.get_item_description_item_masterlists_path(),
    method : 'get',
    params: { item_id: $stateParams.item_id }
  })
  .then(function (response) {
    $scope.item_details = response.data;
  })

  $http({
    url : $routes.stock_card_path($stateParams.item_id),
    method : 'get'
  })
  .then(function (response) {
    $scope.stock_card = response.data;
    $scope.total_balance = ($scope.stock_card.incoming_total_quantity - $scope.stock_card.outgoing_total_quantity).toFixed(2);
    $scope.stock_card_cache = $scope.stock_card;
  })

  // filters incoming : PO YEAR
  $scope.po_year = "";
  $scope.$watch('po_year', function (py) {
    // fetch default array values
    if ( !py.length ) {
      $http({
        url : $routes.stock_card_path($stateParams.item_id),
        method : 'get'
      })
      .then(function (response) {
        $scope.stock_card = response.data;
        $scope.total_balance = ($scope.stock_card.incoming_total_quantity - $scope.stock_card.outgoing_total_quantity).toFixed(2);
        $scope.stock_card_cache = $scope.stock_card;
      })
    }
    // ignore unless length is 4
    if ( !py.length || py.length !== 4 ) return;

    $http({
      url : "/api/stock_card/filter_incomings",
      method : 'get',
      params : { item_id: $stateParams.item_id, po_year: $scope.po_year }
    })
    .then(function (response) {
      $scope.stock_card = response.data;
      $scope.total_balance = ($scope.stock_card.incoming_total_quantity - $scope.stock_card.outgoing_total_quantity).toFixed(2);
      $scope.stock_card_cache = $scope.stock_card;
    })
  });

  // filters incoming : In-Charge
  $scope.in_charge = "";
  $scope.$watch('in_charge', function (nc) {
    // fetch default array values
    if ( !nc.length ) {
      $http({
        url : $routes.stock_card_path($stateParams.item_id),
        method : 'get'
      })
      .then(function (response) {
        $scope.stock_card = response.data;
        $scope.total_balance = ($scope.stock_card.incoming_total_quantity - $scope.stock_card.outgoing_total_quantity).toFixed(2);
        $scope.stock_card_cache = $scope.stock_card;
      })
    }
    // ignore unless length is 4
    if ( !nc.length ) return;

    $http({
      url : "/api/stock_card/filter_incomings",
      method : 'get',
      params : { item_id: $stateParams.item_id, in_charge: $scope.in_charge }
    })
    .then(function (response) {
      $scope.stock_card = response.data;
      $scope.total_balance = ($scope.stock_card.incoming_total_quantity - $scope.stock_card.outgoing_total_quantity).toFixed(2);
      $scope.stock_card_cache = $scope.stock_card;
    })
  });

  // filters incoming : DATE RECEIVED
  $scope.date_received = "";
  $scope.$watch('date_received', function (dr) {
    // fetch default array values
    if ( !dr.length ) {
      $http({
        url : $routes.stock_card_path($stateParams.item_id),
        method : 'get'
      })
      .then(function (response) {
        $scope.stock_card = response.data;
        $scope.total_balance = ($scope.stock_card.incoming_total_quantity - $scope.stock_card.outgoing_total_quantity).toFixed(2);
        $scope.stock_card_cache = $scope.stock_card;
      })
    }

    if ( !dr.length) return;
    if ( !moment(dr).isValid() ) return;

    $http({
      url : "/api/stock_card/filter_incomings",
      method : 'get',
      params : { item_id: $stateParams.item_id, date_received: $scope.date_received }
    })
    .then(function (response) {
      $scope.stock_card = response.data;
      $scope.total_balance = ($scope.stock_card.incoming_total_quantity - $scope.stock_card.outgoing_total_quantity).toFixed(2);
      $scope.stock_card_cache = $scope.stock_card;
    })
  });

});