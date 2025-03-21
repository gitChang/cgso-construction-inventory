'use strict';

App.controller('EndorsePoComposeController', function ($rootScope, $scope, $http, $state, HelperService) {

  // vars and instances.
  var $routes = Routes;
  var $helper = HelperService;

  // set page title.
  $rootScope.pageTitle = 'Create Endorsement per PO';

  $scope.formatAmt = function (amt) {
    return $helper.formatMoney(amt);
  };

  // pow number search
  $scope.pow_number = null;
  $scope.project_pos = [];

  // endorsement payload
  $scope.endo = {
    pos: [],
    recipient: { name: 'RAMIL Y. TIU, CPA', designation: 'City Accountant' },
    thru: { name: 'EDWIN I. SALGADOS, CPA', designation: 'Accountant IV' },
    sender: { name: 'JALMAIDA L. JAMIRI-MORALES, MPA', designation: 'General Services Officer' },
    cc: 'GSO-Admin',
    active_user: $rootScope.active_user
  };

  $scope.$watch('pow_number', function(pow) {
    if (!pow) {
      return;
    }
    $http({
      method: "get",
      url: "/api/endorsement_pos/get_project_pos",
      params: { pow_number: pow }
    })
    .then(function (response) {
      $scope.project_pos = response.data;
    })
  })

});
