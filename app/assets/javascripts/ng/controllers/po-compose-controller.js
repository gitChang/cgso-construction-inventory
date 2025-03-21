'use strict';

App.controller('PoComposeController', function ($rootScope, $scope, $http, $stateParams, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;


  $rootScope.pageTitle = 'Purchase Order - New';


  // payload
  $scope.po = {
    pr_number : null,
    pow_number : null,
    po_number : null,
    date_issued : null,
    remarks : null,
    iar_number : null,
    date_of_delivery : null,
    complete : null,
    inspector : null,
    supplier : null,
    mode_of_procurement : null,
    purpose : null,
    po_items : []
  };

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

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
    item: null, quantity: null, unit: null, cost: null, amount: 0, remarks: null
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
        $scope.po.pow_number = response.data.pow_number;
        $scope.po.department = response.data.department;
        $scope.po.purpose = response.data.purpose;
      } else {
        $scope.po.pow_number = null;
        $scope.po.department = null;
        $scope.po.purpose = null;
      }
    })
  })


  $scope.nextNumberIndicator = 1; // base number.

  $scope.totalAmount = 0.00;
  $scope.$watchCollection('po.po_items', function (newValue) {
    var total = 0.00;

    $.each(newValue, function (index, value) {
      total += parseFloat(value.amount)
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
