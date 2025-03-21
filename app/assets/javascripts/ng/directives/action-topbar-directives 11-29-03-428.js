'use strict';

// Directive add a row item.
App.directive('dirActionTopbar', function ($rootScope, $templateCache, $compile) {

  function linker(scope, element) {

  }

  return {
    restrict: 'C',
    link: linker
  };
});