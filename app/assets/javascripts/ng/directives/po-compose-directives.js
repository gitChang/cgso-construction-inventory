'use strict';

App.directive('dirFmtPoNum', function ($templateCache, $compile, $http, $window, $state, $stateParams, HelperService) {

  function linker(scope, element) {
    element.on('keydown', function (e) {
      var key = e.keyCode || e.charCode;
      if( key == 8 || key == 46 ) return true;

      var elen = element.val().length;
      if (elen == 2) {
        element.val(element.val() + '-');
      }
      if (elen == 5) {
        element.val(element.val() + '-');
      }
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});

App.directive('dirFmtPowNum', function ($templateCache, $compile, $http, $window, $stateParams, HelperService) {

  function linker(scope, element) {
    element.on('keydown', function (e) {
      var key = e.keyCode || e.charCode;
      if( key == 8 || key == 46 ) return true;

      var elen = element.val().length;
      if (elen == 3) {
        element.val(element.val() + '-');
      }
      if (elen == 6) {
        element.val(element.val() + '-');
      }
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});

App.directive('dirFmtPrNum', function ($templateCache, $compile, $http, $window, $stateParams, HelperService) {

  function linker(scope, element) {
    element.on('keydown', function (e) {
      var key = e.keyCode || e.charCode;
      if( key == 8 || key == 46 ) return true;

      var elen = element.val().length;
      if (elen == 3) {
        element.val(element.val() + '-');
      }
      if (elen == 6) {
        element.val(element.val() + '-');
      }
      if (elen == 9) {
        element.val(element.val() + '-');
      }
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});


// Directive add a row item.
App.directive('dirPoAddItem', function ($templateCache, $compile, $http, $window, $stateParams, HelperService) {

  function linker(scope, element) {

    var $routes = Routes;
    var $helper = HelperService;

    // append new item to po item scope.
    element.click(function(e) {
      e.preventDefault();

      if (scope.selectedItem.item === null) return;

      // include PR, to check item number dups!
      scope.selectedItem.pr_number = scope.po.pr_number;

      if (scope.selectedItem.quantity)
        scope.selectedItem.quantity = parseFloat(scope.selectedItem.quantity);

      scope.selectedItem.unit = scope.selectedItem.item.unit;

      // set to two decimal places.
      if (scope.selectedItem.cost)
        scope.selectedItem.cost = parseFloat(scope.selectedItem.cost).toFixed(2);

      scope.selectedItem.amount = (scope.selectedItem.cost * scope.selectedItem.quantity).toFixed(2);
      // -- item number is base on PR item order. shud be encoded instead.
      // scope.selectedItem.item_number = scope.nextNumberIndicator;

      // validate item in the backend
      $.ajax({
        url : $routes.validate_item_stocks_path(),
        type : 'post',
        data : $helper.injectAuthToken(scope.selectedItem),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element);
        }
      })
      .done(function () {
        $helper.removeNotify();

        // look for duplicate added item.
        var duplicate = false;
        $.each(scope.po.po_items, function(index, obj) {
          /**if ( obj.item.id == scope.selectedItem.item.id ) {
            $helper.hightlightErrorField('model_po_items', 'Duplicate item found in row no. ' + index + 1 + '.');
            duplicate = true;
          }**/
          if ( obj.id == scope.selectedItem.item.id ) {
            $helper.hightlightErrorField('model_po_items', 'Duplicate item found in row no. ' + index + 1 + '.');
            duplicate = true;
          }
        })

        if (duplicate) return;

        // append to item collection po.
        scope.po.po_items.push(scope.selectedItem);
        scope.selectedItem = {
          id: null, quantity: null, unit: null, cost: null, amount: 0, remarks: null
        };
        scope.nextNumberIndicator += 1;
        scope.$apply();
        $('#new_item_number').focus();
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


// Directive delete row item.
App.directive('dirPoRemoveItem', function () {

  function linker(scope, element) {
    element.click(function() {
      var rowElement = element.parents('tr');
      var arrIndex = null;

      $.each(scope.po.po_items, function(index, obj) {
        if ( obj.item_number == rowElement.attr('inum') ) {
          arrIndex = index;
        }
      })

      // delete element from array po items.
      scope.po.po_items.splice(arrIndex, 1);
      rowElement.remove();
      scope.$apply();
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});


// Directive save PO.
App.directive('dirSavePo', function ($templateCache, $compile, $state, $http, $window, HelperService) {

  function linker(scope, element) {

    // instances
    var $helper = HelperService;
    var $routes = Routes;


    element.click(function (event) {
      event.preventDefault();

      scope.$apply();

      $.ajax({
        url : $routes.purchase_orders_path(),
        type : 'post',
        data : $helper.injectAuthToken(scope.po),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function (data) {
        //$window.location.pathname = $state.href('po.collect');
        $state.go('po.view', { id: data.id });
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



