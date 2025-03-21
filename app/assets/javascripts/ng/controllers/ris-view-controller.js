'use strict';

App.controller('RisViewController', function ($rootScope, $scope, $http, $stateParams, HelperService) {

  // vars, instances
  var $routes = Routes;
  var $helper = HelperService;


  // content
  $scope.ris = {};

  //
  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };


  $http({
    url : $routes.req_issued_slip_path($stateParams.id),
    method : 'get'
  })
  .then(function (response) {
    $scope.ris = response.data;
    // set page title
    $rootScope.pageTitle = 'RIS No. ' + $scope.ris.ris_number;
  })


  // get logs
  $http({
    url : $routes.get_logs_change_logs_path(),
    method : 'get',
    params : { risid: $stateParams.id }
  })
  .then(function (response) {
    $scope.change_logs = response.data;
  })

});