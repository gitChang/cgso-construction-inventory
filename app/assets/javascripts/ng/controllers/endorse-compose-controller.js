'use strict';

App.controller('EndorseComposeController', function ($rootScope, $scope, $http, $state, HelperService) {

  // vars and instances.
  var $routes = Routes;
  var $helper = HelperService;

  // set page title.
  $rootScope.pageTitle = 'Create Endorsement';

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  // pow number search
  $scope.pow_number = null;

  // endorsement payload
  $scope.endo = {
    projects: [],
    recipient: { name: 'RAMIL Y. TIU, CPA', designation: 'City Accountant' },
    thru: { name: 'EDWIN I. SALGADOS, CPA', designation: 'Accountant IV' },
    sender: { name: 'JALMAIDA J. MORALES, MPA', designation: 'General Services Officer' },
    cc: 'GSO-Admin',
    active_user: $rootScope.active_user
  };

  $scope.$watchCollection('endo', function(en) {
    console.log(en);
  })

});
