'use strict';

// Directive add a row item.
App.directive('dirRisAddItem', function ($templateCache, $compile, $http, $window, HelperService) {

  function linker(scope, element) {

    var $routes = Routes;
    var $helper = HelperService;

    // append new item to po item scope.
    element.click(function(e) {
      e.preventDefault();

      if (scope.selected.item === null) return;

      scope.selected.item.item_number = scope.selected.item.item_number; //scope.nextNumberIndicator;

      if (scope.selected.item.quantity)
        scope.selected.item.quantity = parseFloat(scope.selected.item.quantity).toFixed(2);;

      scope.selected.item.unit = scope.selected.item.unit;

      // set to two decimal places.
      if (scope.selected.item.cost)
        scope.selected.item.cost = parseFloat(scope.selected.item.cost).toFixed(2);

      scope.selected.item.amount = (scope.selected.item.cost * scope.selected.item.quantity).toFixed(2);

      // validate item in the backend
      $.ajax({
        url : $routes.validate_item_stocks_path(),
        type : 'post',
        data : $helper.injectAuthToken(scope.selected.item),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function () {
        $helper.removeNotify();

        // look for duplicate added item.
        var duplicate = false;
        $.each(scope.ris.ris_items, function(index, obj) {
          if ( obj.item.id == scope.selected.item.item.id ) {
            $helper.hightlightErrorField('model_ris_items', 'Duplicate item found in row no. ' + index + 1 + '.');
            duplicate = true;
          }
        })

        if (duplicate) return;

        // append to item collection po.
        scope.ris.ris_items.push(scope.selected.item);

        scope.selected.item = {
          source_stock_id: null,
          source_procurement_form: null,
          source_number: null,
          item: null,
          quantity: null,
          unit: null,
          cost: null,
          amount: 0
        };

        scope.nextNumberIndicator += 1;
        scope.$apply();
      })
      .fail(function (error) {
        if (error.status !== 500) {
          var key = error.responseJSON[0], msg = error.responseJSON[1];
          // hightlight error field and display message
          $helper.hightlightErrorField(key, msg);
        }
      })
      .always(function () {
        $helper.animateProcessStop(element);
      })
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});


// Directive delete row item.
App.directive('dirRisRemoveItem', function () {

  function linker(scope, element) {
    element.click(function() {
      var rowElement = element.parents('tr');
      var arrIndex = null;

      $.each(scope.ris.ris_items, function(index, obj) {
        if ( obj.item.id == rowElement.attr('iid') ) {
          arrIndex = index;
        }
      })

      // delete element from array ris items.
      scope.ris.ris_items.splice(arrIndex, 1);
      rowElement.remove();
      scope.$apply();
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});

// Directive update RIS.
App.directive('dirSaveRis', function ($templateCache, $compile, $state, $stateParams, $http, $window, HelperService) {

  function linker(scope, element) {

    // instances
    var $helper = HelperService;
    var $routes = Routes;


    element.click(function (event) {
      event.preventDefault();
      $.ajax({
        url : $routes.req_issued_slip_index_path(),
        type : 'post',
        data : $helper.injectAuthToken(scope.ris),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function (data) {
        //$window.location.pathname = $state.href('ris.collect');
        $state.go('ris.view', { id: data.id });
      })
      .fail(function (error) {
        var key = error.responseJSON[0], msg = error.responseJSON[1];
        // hightlight error field and display message
        $helper.hightlightErrorField(key, msg);
      })
      .always(function () {
        $helper.animateProcessStop(element);
      })
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});