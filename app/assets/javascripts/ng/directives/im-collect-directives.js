'use strict';

// Directive add a row item.
App.directive('dirOnHand', function ($window, $http, $state, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;


    element.keyup(function (e) {
      e.preventDefault();

      if (e.which == 13) {
        var key_id = element.closest('tr').attr('iid');
        var input_on_hand_count = element.closest('tr').find('input');

        $http.post($routes.set_on_hand_count_item_masterlists_path(), $helper.injectAuthToken({
            id: key_id,
            on_hand_count: input_on_hand_count.val().trim()
        }))
        .then(function(res) {
          input_on_hand_count.addClass('dir-on-hand-good');
          $('#q-desc').focus();
        }, function () {
          input_on_hand_count.addClass('dir-on-hand-bad');
        })
      }
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});