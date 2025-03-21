'use strict';

App.controller('ProjectsEditController', function ($rootScope, $scope, $state, $stateParams, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  $rootScope.pageTitle = 'Project - Edit';

  // payload
  $scope.project = {
                    pr_number: null,
                    pow_number: null,
                    department: null,
                    in_charge: null,
                    purpose: null
                  };


  $http({
    url: $routes.edit_project_path($stateParams.id),
    method: 'get'
  }).then( function (response) {
    $scope.project = response.data;
  })


  // in-charge collections
  $scope.in_charges = [];
  $scope.refreshInCharges = function (name) {
    if (!name) {
      $scope.in_charges = [];
      return;
    }

    $http({
      url : $routes.project_in_charges_path(),
      method : 'get',
      params : { name: name, department: $scope.project.department }
    })
    .then(function (response) {
      $scope.in_charges = response.data;
    })
  };


  // get designation of the in-charge
  $scope.$watch('project.in_charge', function (in_charge) {
    if ( !in_charge ) {
      $scope.project.designation = null;
      return;
    }

    $http({
      url : $routes.get_designation_project_in_charges_path(),
      method : 'get',
      params : { name: in_charge }
    })
    .then(function (response) {
      $scope.project.designation = response.data.designation;
    })
  })

  // nullify in-charges when department not set.
  $scope.$watch('project.department', function (dept) {
    if ( !dept ) {
      $scope.project.in_charges = null;
    }
  })


  // department collection.
  $scope.departments = null;
  $scope.refreshDepartments = function (department) {
    $http({
      url: $routes.departments_path(),
      method: 'get',
      params: { abbrev: department }
    })
    .then( function (response) {
      $scope.departments = response.data;
    })
  };

});
