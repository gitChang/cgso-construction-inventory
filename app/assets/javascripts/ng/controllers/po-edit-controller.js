'use strict';

App.controller('PoEditController', function ($rootScope, $scope, $http, $state, $stateParams, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;

  // payload
  $scope.po = { po_items: [] };

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  // prevent edit po when project is already completed.
  /**$http({
    url : $routes.check_project_completion_purchase_orders_path(),
    method : 'get',
    params : { id: $stateParams.id }
  })
  .then(function (response) {
    if (response.data == true) {
      $state.go('po.view', { id: $stateParams.id })
    }
  })**/

  // load po
  $http({
    url : $routes.edit_purchase_order_path($stateParams.id),
    method : 'get'
  })
  .then(function (response) {
    $scope.po = response.data;
    $scope.nextNumberIndicator = $scope.po.po_items.length + 1; // base number.
    $rootScope.pageTitle = 'Purchase Order - Edit - ' + $scope.po.po_number;
  })

  // set IAR Number
  $scope.$watch('po.po_number', function (po) {
    if (po && po.split('-').length === 3)
      $scope.po.iar_number = po.split('-')[1] + '-' + po.split('-')[2];
    else
      $scope.po.iar_number = null;
  })

  // item collections
  $scope.items = [];
  // selected item
  $scope.selectedItem = {
    id: null, item: null, quantity: null, unit: null, cost: null, amount: 0, edited: 'no', remarks: null
  };

  $scope.refreshItems = function (name) {
    if (!name) {
      $scope.items = [];
      return;
    }

    $http({
      url : $routes.item_masterlists_path(),
      method : 'get',
      params : { name: name }
    })
    .then(function (response) {
      $scope.items = response.data.items;
    })
  };


  // inspector collections
  $scope.inspectors = null;
  $http({
    url : $routes.inspectors_path(),
    method : 'get'
  })
  .then(function (response) {
    $scope.inspectors = response.data;
  })


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
  /**$scope.departmentDivisions = null;
  $scope.$watch('po.department', function (dept) {
    // reset division on change department.
    $scope.po.department_division = null;
    $scope.departmentDivisions = null;

    if (!dept) {
      $scope.departmentDivisions = null;
      return;
    }

    $http({
      url: $routes.department_divisions_path(),
      method: 'get',
      params: { department: $scope.po.department }
    })
    .then( function (response) {
      $scope.departmentDivisions = response.data;
    })
  })**/


  // suppliers collection.
  $scope.suppliers = null;
  $scope.refreshSuppliers = function (supplier) {
    $http({
      url: $routes.get_names_suppliers_path(),
      method: 'get',
      params: { name: supplier }
    })
    .then( function (response) {
      $scope.suppliers = response.data;
    })
  };


  // mode of procurements collection.
  $scope.modes = null;
  $scope.refreshModes = function (mode) {
    $http({
      url: $routes.mode_of_procurements_path(),
      method: 'get',
      params: { mode: mode }
    })
    .then( function (response) {
      $scope.modes = response.data;
    })
  };


  // check if pr exist, then get the purpose / project name
  // of the project.
  $scope.$watch('po.pr_number', function (pr) {

    if (!pr) return;

    $http({
      url: $routes.get_project_detail_projects_path(),
      method: 'get',
      params: { pr_number: $scope.po.pr_number }
    })
    .then( function (response) {
      if (response.data) {
        $scope.po.department = response.data.department;
        $scope.po.purpose = response.data.purpose;
      } else {
        $scope.po.department = null;
        $scope.po.purpose = null;
      }
    })
  })


  $scope.totalAmount = 0.00;
  $scope.$watchCollection('po.po_items', function (items) {
    var total = 0.00;

    $.each(items, function (index, item) {
      if (item.delete !== 'yes')
        total += parseFloat(item.amount)
    })
    $scope.totalAmount = $scope.formatAmt(total.toFixed(2));
  })

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
