App.directive('dirDownloadSavings', function ($window, $state, $stateParams, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.click( function () {
      if (scope.item.res)
        $window.location.href = 'download-saving-savings-report?item_id=' + scope.item.res.id;
      else
        $window.location.href = 'download-saving-savings-report'

    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});