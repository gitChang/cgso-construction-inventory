'use strict';

App.controller('EndorsedPoCollectController', function ($rootScope, $scope, $stateParams, $http, HelperService) {

  // instances
  var $helper = HelperService;
  var $routes = Routes;

  // set page title
  $rootScope.pageTitle = 'Endorsed POs';

  $scope.query = null;

  $scope.getEndorsedPos = function (page) {
    if ($scope.query) {
      $http({
        url : '/api/endorsement_pos',
        method : 'get',
        params : { page: page, po_number: $scope.query }
      })
      .then(function (response) {
        $scope.endorsed_pos = response.data.endorsed_pos;
        $scope.from_index = response.data.from_index
        $scope.to_index = response.data.to_index
        $scope.total_entries = response.data.total_entries;
        $scope.current_page = parseInt(response.data.current_page)
      })
    }

    if (!$scope.query) {
      $http({
        url : '/api/endorsement_pos',
        method : 'get',
        params : { page: page }
      })
      .then(function (response) {
        $scope.endorsed_pos = response.data.endorsed_pos;
        $scope.from_index = response.data.from_index
        $scope.to_index = response.data.to_index
        $scope.total_entries = response.data.total_entries;
        $scope.current_page = parseInt(response.data.current_page)
      })
    }
  }

  // refresh projects collection upon searched.
  $scope.$watch('query', function (q) {
    if (q == null) return;
    $scope.getEndorsedPos(1);
  })

  $scope.getRowNumber = function (isfirst, ngIndex) {
    if (isfirst) return $scope.from_index;
    return parseInt($scope.from_index) + parseInt(ngIndex);
  }

});