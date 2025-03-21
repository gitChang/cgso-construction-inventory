'use strict';

App.controller('ActionTopbarController', function ($rootScope, $scope, $compile, $location, $state, $http) {

  $rootScope.inventoryElementName = null;
  $rootScope.navigators = [];
  var $routes = Routes;

  // change the actionbar content base on state name
  $rootScope.$on('$stateChangeSuccess', function (event, toState, toParams, fromState, fromParams) {
    event.preventDefault();

    // autofocus first input.
    setTimeout(function () { $(".panel-default > text:input:visible:first").focus(); }, 1500);

    $http({
      url : $routes.user_details_path(),
      method : 'get'
    })
    .then(function (response) {
      $rootScope.active_user = response.data.name.split(' ')[0];
    })

    // show by default navlink home#homie
    $('#homie').removeAttr('style');

    // when login state
    if ( $location.path().indexOf('/login') > -1 ) {
      // hide home navlink
      $('#homie').css('display', 'none');
      // set values to null to signal (N/A)
      $rootScope.inventoryElementName = null;
      $rootScope.navigators = [];
      $rootScope.faIcon = null;
    }

    // when home state
    if ( $location.path().indexOf('/home') > -1 ) {
      // hide home navlink
      $('#homie').css('display', 'none');

      $rootScope.inventoryElementName = 'CGSO / Construction';
      $rootScope.navigators = [];
      $rootScope.faIcon = '';
    }

    // when po state
    if ( $location.path().indexOf('/po') > -1 ) {
      $rootScope.inventoryElementName = 'Purchase Order';
      $rootScope.navigators = [
        {state: 'po.collect', name: 'list'},
        {state: 'po.compose', name: 'new'}
      ];
      $rootScope.faIcon = 'shopping-cart';
    }

    // when ris state
    if ( $location.path().indexOf('/ris') > -1 ) {
      $rootScope.inventoryElementName = 'Requisition Issued Slip';
      $rootScope.navigators = [
        {state: 'ris.collect', name: 'list'},
        {state: 'ris.compose', name: 'new'}
      ];
      $rootScope.faIcon = 'pencil-square-o';
    }

    // when endorse state
    if ( $location.path().indexOf('/endorsement') > -1 ) {
      $rootScope.inventoryElementName = 'Endorsement';
      $rootScope.navigators = [
        {state: 'endorsement.collect', name: 'Endorsed Projects'},
        {state: 'endorsement.po_collect', name: 'Endorsed PO\'s'},
        {state: 'endorsement.compose', name: 'Create / Project'},
        {state: 'endorsement.po_compose', name: 'Create / PO'}
      ];
      $rootScope.faIcon = 'file-o';
    }

    // stock card
    if ( $location.path().indexOf('/stock-card') > -1 ) {
      $rootScope.inventoryElementName = 'Stock Card';
      $rootScope.navigators = [];
      $rootScope.faIcon = 'cubes';
    }

    // when savings state
    if ( $location.path().indexOf('/savings') > -1 ) {
      $rootScope.inventoryElementName = 'Savings';
      $rootScope.navigators = [
        {state: 'savings.item', name: 'item'},
        {state: 'savings.project', name: 'project'}
      ];
      $rootScope.faIcon = 'archive';
    }

    // when property return slip
    if ( $location.path().indexOf('/prs') > -1 ) {
      $rootScope.inventoryElementName = 'Property Return Slip';
      $rootScope.navigators = [];
      $rootScope.faIcon = 'cubes';
    }

    // when certification of delivery
    if ( $location.path().indexOf('/cert-of-delivery') > -1 ) {
      $rootScope.inventoryElementName = 'Certification';
      $rootScope.navigators = [];
      $rootScope.faIcon = 'star';
    }

    // when project-in-charge state
    if ( $location.path().indexOf('/project-in-charge') > -1 ) {
      $rootScope.inventoryElementName = 'Project In-Charge';
      $rootScope.navigators = [];
      $rootScope.faIcon = 'users';
    }

    // when stock card state
    if ( $location.path().indexOf('/projects') > -1 ) {
      $rootScope.inventoryElementName = 'Projects';
      $rootScope.navigators = [
        {state: 'projects.collect', name: 'list'},
        {state: 'projects.compose', name: 'new'},
        {state: 'projects.new_in_charge', name: 'New In-Charge'}
      ];
      $rootScope.faIcon = 'clone';
    }

    // when item masterlist state
    if ( $location.path().indexOf('/im') > -1 ) {
      $rootScope.inventoryElementName = 'Item Masterlist';
      $rootScope.navigators = [
        {state: 'im.collect', name: 'items'},
        {state: 'im.compose', name: 'new item'}
      ];
      $rootScope.faIcon = 'list-alt';
    }

    // when supplier state
    if ( $location.path().indexOf('/supplier') > -1 ) {
      $rootScope.inventoryElementName = 'Supplier';
      $rootScope.navigators = [
        {state: 'supplier.collect', name: 'list'},
        {state: 'supplier.compose', name: 'new'}
      ];
      $rootScope.faIcon = 'truck fa-flip-horizontal';
    }

    // when enroll user state
    if ( $location.path().indexOf('/enroll') > -1 ) {
      $rootScope.inventoryElementName = 'Enroll a User';
      $rootScope.navigators = [];
      $rootScope.faIcon = 'users';
    }

    // when change log
    if ( $location.path().indexOf('/change-log') > -1 ) {
      $rootScope.inventoryElementName = 'Change Log';
      $rootScope.navigators = [];
      $rootScope.faIcon = 'ticket';
    }

    // when add unit state
    if ( $location.path().indexOf('/add-unit') > -1 ) {
      $rootScope.inventoryElementName = 'Add Unit';
      $rootScope.navigators = [];
      $rootScope.faIcon = 'plus';
    }

    // when add department state
    if ( $location.path().indexOf('/add-department') > -1 ) {
      $rootScope.inventoryElementName = 'Add Department';
      $rootScope.navigators = [];
      $rootScope.faIcon = 'plus';
    }

    // when add supply state
    if ( $location.path().indexOf('/add-supply') > -1 ) {
      $rootScope.inventoryElementName = 'Add Supply';
      $rootScope.navigators = [];
      $rootScope.faIcon = 'plus';
    }
  })

  // action topbar patial html path. hide or show with condition.
  $rootScope.actionTopbarTpl = null;
  $rootScope.$watch('inventoryElementName', function (title) {
    if (title === null)
      $rootScope.actionTopbarTpl = null;
    else
      $rootScope.actionTopbarTpl = 'partials/action-topbar.html';
  })

  // set active navbar links
  $rootScope.routed = function (state) {
    return $location.path() === $state.href(state);
  }

});
