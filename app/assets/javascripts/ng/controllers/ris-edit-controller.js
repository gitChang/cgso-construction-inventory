'use strict';

App.controller('RisEditController', function ($rootScope, $scope, $http, $state, $stateParams, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  // payload
  $scope.ris = {ris_items: []};


  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };


  // prevent edit when project is already completed.
  /**$http({
    url : $routes.check_project_completion_req_issued_slip_index_path(),
    method : 'get',
    params : { id: $stateParams.id }
  })
  .then(function (response) {
    if (response.data == true)
      $state.go('ris.view', { id: $stateParams.id })
  })**/

  // load ris
  $http({
    url : $routes.edit_req_issued_slip_path($stateParams.id),
    method : 'get'
  })
  .then(function (response) {
    $scope.ris = response.data;
    $scope.nextNumberIndicator = $scope.ris.ris_items.length + 1; // base number.
    $rootScope.pageTitle = 'Requisition Issued Slip - Edit - ' + $scope.ris.ris_number;
  })

  $scope.selected = {
    item: null
  };

  // item collections
  $scope.items = [];
  //$scope.refreshItems = function (description) {
  $scope.$watch('ris.pr_number', function (pr) {
    if ( !pr ) {
      $scope.items = [];
      return;
    }

    $http({
      url : $routes.source_items_req_issued_slip_index_path(),
      method : 'get',
      params : { pr_number: $scope.ris.pr_number }
    })
    .then(function (response) {
      $scope.items = response.data;
    })
  });


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


  // division collection accord. to department.
  $scope.departmentDivisions = null;
  $scope.$watch('ris.department', function (dept) {
    if (!dept) {
      $scope.departmentDivisions = null;
      return;
    }

    $http({
      url: $routes.department_divisions_path(),
      method: 'get',
      params: { department: $scope.ris.department }
    })
    .then( function (response) {
      $scope.departmentDivisions = response.data;
    })
  })


  $scope.warehousemen = null;
  // warehousemen collections.
  $http({
    url : $routes.warehousemen_path(),
    method : 'get'
  })
  .then(function (response) {
    $scope.warehousemen = response.data;
  })


  // check if pr exist, then get the purpose / project name
  // of the project.
  /**$scope.$watch('ris.pow_number', function (pow) {

    if (!pow) return;

    $http({
      url: $routes.get_project_detail_projects_path(),
      method: 'get',
      params: { pow_number: $scope.ris.pow_number }
    })
    .then( function (response) {
      if (response.data) {
        $scope.ris.pr_number = response.data.pr_number;
        $scope.ris.department = response.data.department;
        $scope.ris.purpose = response.data.purpose;
      } else {
        $scope.ris.pr_number = null;
        $scope.ris.department = null;
        $scope.ris.purpose = null;
      }
    })
  })**/


  // check if pow exist, then get the purpose / project name
  // of the project.
  $scope.$watch('ris.pr_number', function (pr) {

    if (!pr) return;

    $http({
      url: $routes.get_project_detail_projects_path(),
      method: 'get',
      params: { pr_number: $scope.ris.pr_number }
    })
    .then( function (response) {
      if (response.data) {
        $scope.ris.pow_number = response.data.pow_number;
        $scope.ris.department = response.data.department;
        $scope.ris.purpose = response.data.purpose;
      } else {
        $scope.ris.pow_number = null;
        $scope.ris.department = null;
        $scope.ris.purpose = null;
      }
    })
  })


  // check if pr exist, then get the in-charge
  // of the project.
  $scope.$watch('ris.pr_number', function (pr) {

    if (!pr) return;

    $http({
      url: $routes.get_in_charge_projects_path(),
      method: 'get',
      params: { pr_number: $scope.ris.pr_number }
    })
    .then( function (response) {
      $scope.ris.in_charge = response.data[0];
    })
  })


  // collect all approved_by data.
  $scope.approvers = [];
  $http({
    url: $routes.get_approvers_req_issued_slip_index_path(),
    method: 'get'
  })
  .then( function (response) {
    $scope.approvers = response.data;
  })

  // if not in approved_by data, add to collection.
  $scope.getApprovers = function(search) {
    var newApprovers = $scope.approvers.slice();

    if (search && newApprovers.indexOf(search) === -1) {
      newApprovers.unshift(search);
    }
    return newApprovers;
  }

  // collect all issued_by data.
  $scope.issuers = [];
  $http({
    url: $routes.get_issuers_req_issued_slip_index_path(),
    method: 'get'
  })
  .then( function (response) {
    $scope.issuers = response.data;
  })

  // if not in issuers_by data, add to collection.
  $scope.getIssuers = function(search) {
    var newIssuers = $scope.issuers.slice();

    if (search && newIssuers.indexOf(search) === -1) {
      newIssuers.unshift(search);
    }
    return newIssuers;
  }

  // collect all receivers/withdrawn_by data.
  $scope.receivers = [];
  $http({
    url: $routes.get_receivers_req_issued_slip_index_path(),
    method: 'get'
  })
  .then( function (response) {
    $scope.receivers = response.data;
  })

  // if not in issuers_by data, add to collection.
  $scope.getReceivers = function(search) {
    var newReceivers = $scope.receivers.slice();

    if (search && newReceivers.indexOf(search) === -1) {
      newReceivers.unshift(search);
    }
    return newReceivers;
  }


  // next item number indicator/label.
  $scope.nextNumberIndicator = 1; // base number.

  // get the total amount of items selected.
  $scope.totalAmount = 0.00;
  $scope.$watchCollection('ris.ris_items', function (newValue) {
    var total = 0.00;

    $.each(newValue, function (index, value) {
      total += parseFloat(value.amount)
    })
    $scope.totalAmount = $scope.formatAmt(total.toFixed(2));
  })


  // submit payload.
  $scope.submit = function () {
    $('.dir-update-po').trigger('click');
  };

  window.onbeforeunload = function (e) {
    e = e || window.event;
    // For IE and Firefox prior to version 4
    if (e) {
      e.returnValue = 'Changes you made may not be saved.';
    }
    // For Safari
    return 'Changes you made may not be saved.';
  };

});
