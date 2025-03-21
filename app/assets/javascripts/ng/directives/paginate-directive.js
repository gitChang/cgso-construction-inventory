// Directive delete row item.
App.directive('paginate', function () {
  return {
    restrict: 'E',
    scope: {
      from: '=',
      to: '=',
      total: '=',
      currentPage: '=',
      action: '&'
    },
    controller: ["$scope", function($scope){
      $scope.previousPage = function () {
        if ($scope.from == 1) return;
        $scope.currentPage -= 1;
        $scope.action({ page: $scope.currentPage });
      }
      $scope.nextPage = function () {
        if ($scope.to == $scope.total) return;
        $scope.currentPage += 1;
        $scope.action({ page: $scope.currentPage });
      }
    }],
    templateUrl: 'paginate.html'
  };
});