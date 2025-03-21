'use strict';

App.controller('ProjectsComposeController', function ($rootScope, $scope, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  $rootScope.pageTitle = 'Project - New';

  // payload
  $scope.project = {
    pr_number : null,
    pow_number : null,
    department : null,
    in_charge : null,
    designation : null,
    purpose : null
  };

  // if for shelter
  $scope.shel_ass = false;
  $scope.$watch('shel_ass', function(val) {
    if (val === true) $scope.project.purpose = 'SHELTER ASSISTANCE PROGRAM';
  });


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


  // submit payload.
  $scope.submit = function () {
    $('.dir-save-in-charge').trigger('click');
  };

});
