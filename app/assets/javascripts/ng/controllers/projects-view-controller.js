'use strict';

App.controller('ProjectsViewController', function ($rootScope, $scope, $http, $stateParams, HelperService) {

  // vars, instances
  var $routes = Routes;
  var $helper = HelperService;


  // content
  $scope.project = {};
  $scope.pdf_name = null;

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  $http({
    url : $routes.stock_card_projects_path(),
    method : 'get',
    params: { pr_number: $stateParams.pr_number }
  })
  .then(function (response) {
    $scope.project = response.data;
    $scope.pdf_name = response.data.pdf_name;
    // set page title
    $rootScope.pageTitle = 'Project Stock Card : PR No. ' + $scope.project.pr_number;;
  })

  $scope.user = {};
  $http({
    url : $routes.user_details_path(),
    method : 'get'
  })
  .then( function (response) {
    $scope.user = response.data;
  })

  // check if has prs number then show certification.
  //$scope.show_cert = false;
  // NAGBAGO NG TUNO (bisag wala daw na-withdraw tanan, pwede na daw maka-issue ug cert).
  // CHANGE PLAN. SHOW CERT. OF DELIVERY BY DEFAULT.
  $scope.show_cert = true;
  /**$http({
    url : $routes.prs_present_projects_path(),
    method : 'get',
    params: { pr_number: $stateParams.pr_number }
  })
  .then(function (response) {
    $scope.show_cert = response.data;
  })**/

});