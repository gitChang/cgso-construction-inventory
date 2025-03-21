'use strict';

App.controller('RisCollectController', function ($rootScope, $scope, $http, HelperService) {

  // instances.
  var $helper = HelperService;
  var $routes = Routes;

  // set page title
  $rootScope.pageTitle = 'Requisition Issued Slip';


  $scope.getRisItems = function (page) {

    if ($scope.query) {
      if ( $scope.query.indexOf(':') > -1 ) {

        var key = $scope.query.split(':')[0];
        var val = $scope.query.split(':')[1];

        $http({
          url : $routes.req_issued_slip_index_path(),
          method : 'get',
          params : { page: page, key: key, val: val }
        })
        .then(function (response) {
          $scope.risItems = response.data.ris_items;
          $scope.from_index = response.data.from_index
          $scope.to_index = response.data.to_index
          $scope.total_entries = response.data.total_entries;
          $scope.current_page = parseInt(response.data.current_page)
        })
      }
    }

    if (!$scope.query) {
      $http({
        url : $routes.req_issued_slip_index_path(),
        method : 'get',
        params : { page: page }
      })
      .then(function (response) {
        $scope.risItems = response.data.ris_items;
        $scope.from_index = response.data.from_index
        $scope.to_index = response.data.to_index
        $scope.total_entries = response.data.total_entries;
        $scope.current_page = parseInt(response.data.current_page)
      })
    }
  }

  // refresh ris collection upon searched.
  $scope.$watch('query', function () {
    if ($scope.query == null) return;
    $scope.getRisItems(1);
  })

  $scope.getRowNumber = function (isfirst, ngIndex) {
    if (isfirst) return $scope.from_index;
    return parseInt($scope.from_index) + parseInt(ngIndex);
  }
});