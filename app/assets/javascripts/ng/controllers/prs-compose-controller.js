'use strict';

App.controller('PrsComposeController', function ($rootScope, $scope, $http, $stateParams, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  // set page title
  $rootScope.pageTitle = 'Property Return Slip';

  $scope.prs = {};

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  // ....
  $http({
    url : $routes.prs_content_projects_path(),
    method : 'get',
    params: { pr_number: $stateParams.pr_number,  }
  })
  .then(function (response) {
    $scope.prs = response.data;
    $scope.pow_number = $scope.prs.pow_number;
  })

})