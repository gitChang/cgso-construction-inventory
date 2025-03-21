'use strict';

App.controller('ProjectsPoCollectController', function ($rootScope, $scope, $stateParams, $http, HelperService) {

  // instances
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'PO Collection';

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  $scope.grand_total_cost = 0.00;
  $http({
    url: $routes.po_collection_projects_path(),
    method: 'get',
    params: { pr_number: $stateParams.pr_number }
  })
  .then( function (response) {
    $scope.project = response.data;
    $.each($scope.project.pos, function(index, obj) {
      $scope.grand_total_cost += parseFloat(obj.total_cost);
    })
  })
});