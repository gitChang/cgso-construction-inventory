'use strict';

App.directive('selectProject', function ($rootScope, HelperService) {

  function linker(scope, element) {
    element.click(function () {
      var pow_num = element.closest('tr')
                           .find('td[data-title="POW Number"]')
                           .children('a')
                           .text();
      var total_cost = element.closest('tr')
                              .find('td[data-title="total_cost"]')
                              .text();
      var purpose = element.closest('tr')
                           .find('td[data-title="Name of Project"]')
                           .children('a')
                           .text().trim();

      if ( element.is(':checked') ) {
        $rootScope.selected_projects.push({ pow_number: pow_num, total_cost: total_cost, purpose: purpose });
      } else {
        for(var i = $rootScope.selected_projects.length - 1; i >= 0; i--) {
          if($rootScope.selected_projects[i].pow_number === pow_num)
            $rootScope.selected_projects.splice(i, 1);
        }
      }
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});


App.directive('nextEndoLett', function ($rootScope, $state, HelperService) {

  function linker(scope, element) {
    element.click(function () {
      if (!$rootScope.selected_projects.length) return;
      $state.go('endorse');
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});

