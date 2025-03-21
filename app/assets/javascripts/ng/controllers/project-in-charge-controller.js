'use strict';

App.controller('ProjectInChargeController', function ($rootScope, $scope, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  $rootScope.pageTitle = 'New Project In-Charge';

  // payload
  $scope.in_charge = {
    department : null,
    name : null,
    designation : null
  };


  // department collection.
  $scope.departments = null;
  $scope.refreshDepartments = function (department) {
    $http({
      url: $routes.departments_path(),
      method: 'get',
      params: { department: department }
    })
    .then( function (response) {
      $scope.departments = response.data;
    })
  };


  // submit payload.
  $scope.submit = function () {
    $('.dir-save-in-charge').trigger('click');
  };

});