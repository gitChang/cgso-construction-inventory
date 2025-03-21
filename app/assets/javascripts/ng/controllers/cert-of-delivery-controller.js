'use strict';

App.controller('CertOfDeliveryController', function ($rootScope, $scope, $http, $stateParams, HelperService) {

  // vars, instances
  var $routes = Routes;
  var $helper = HelperService;

  $scope.project = {};

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };


  $http({
    url : $routes.cert_of_delivery_purchase_orders_path(),
    method : 'get',
    params : { pr_number: $stateParams.pr_number }
  })
  .then(function (response) {
    $scope.project = response.data;
    // set page title
    $rootScope.pageTitle = 'Certification of Delivery - POW No. ' + $scope.project.pow_number;
  })

});