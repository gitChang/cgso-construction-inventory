'use strict';

App.controller('EnrollController', function ($rootScope, $scope, $http, $state) {

  // vars and instances.
  var $routes = Routes;


  // set page title.
  $rootScope.pageTitle = 'Enroll a User';


  // payload.
  $scope.credentials = {
    name : null,
    designation : null,
    department : null,
    department_division : null,
    username : null,
    password : null,
    password_confirmation : null,
    system_role: null
  };

  // prevent access if not admin.
  $http({
    url : $routes.is_admin_application_index_path(),
    method : 'get'
  })
  .then(function (response) {
    if (response.data.access_granted !== 'yes') {
      $state.go('home');
    }
  })


  // department collection.
  $scope.departments = null;
  $scope.refreshDepartments = function (abbrev) {
    $http({
      url: $routes.departments_path(),
      method: 'get',
      params: { abbrev: abbrev }
    })
    .then( function (response) {
      $scope.departments = response.data;
    })
  };


  // division collection accord. to department.
  $scope.departmentDivisions = null;
  $scope.$watch('credentials.department', function (dept) {
    // reset division on change department.
    $scope.credentials.department_division = null;
    $scope.departmentDivisions = null;

    if (!dept) {
      $scope.departmentDivisions = null;
      return;
    }

    $http({
      url: $routes.department_divisions_path(),
      method: 'get',
      params: { department: $scope.credentials.department }
    })
    .then( function (response) {
      $scope.departmentDivisions = response.data;
    })
  })


  // system roles collection.
  $scope.systemRoles = null;
  $http({
    url: $routes.system_roles_path(),
    method: 'get'
  })
  .then( function (response) {
    $scope.systemRoles = response.data;
  })

});
