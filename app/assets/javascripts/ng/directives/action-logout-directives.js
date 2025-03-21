'use strict';

// Directive add a row item.
App.directive('actionLogout', function ($http, $window, $state) {

  function linker(scope, element) {
    var $routes = Routes;

    element.click( function () {
      $http({
        url : $routes.logout_path(),
        method : 'post'
      })
      .then(function (response) {
        $window.location.pathname = $state.href('login');
      })
    });
  }

  return {
    restrict: 'C',
    link: linker
  };
});