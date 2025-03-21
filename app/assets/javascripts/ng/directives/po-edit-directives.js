// Directive add a row item.
App.directive('dirPoEditAddItem', function ($templateCache, $compile, $http, $window, $stateParams, HelperService) {

  function linker(scope, element) {

    var $routes = Routes;
    var $helper = HelperService;

    // append new item to po item scope.
    element.click(function(e) {
      e.preventDefault();

      if (scope.selectedItem.item === null) return;
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
          if ( obj.item_id == scope.selectedItem.item.id && obj.delete !== 'yes' ) {
            var idx = index + 1
            $helper.hightlightErrorField('model_po_items', 'Duplicate item found in row no. ' + idx + '.');
            duplicate = true;
          }

          // compare to newly added item. --> remove this. conflict on delete item.
          if ( obj.hasOwnProperty('item') ) {
            if ( obj.item.id == scope.selectedItem.item.id && obj.delete !== 'yes' ) {
              var idx = index + 1
              $helper.hightlightErrorField('model_po_items', 'Duplicate item found in row no. ' + idx + '.');
              duplicate = true;
            }
          }
        })

        if (duplicate) return;

        // append to item collection po.
        scope.po.po_items.push(scope.selectedItem);
        scope.selectedItem = {
          id: null, quantity: null, unit: null, cost: null, amount: 0
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


// Directive edit an item on stock table.
App.directive('dirPoEditItem', function ($templateCache, $compile, $http, $window, $stateParams, HelperService) {

  function linker(scope, element) {
    var $routes = Routes;
    var $helper = HelperService;

    element.click(function(e) {
      e.preventDefault();

      var rowElement = element.parents('tr');
      var arrIndex = null;
      var stock_id = null;

      $.each(scope.po.po_items, function(index, obj) {
        if ( obj.id == rowElement.attr('iid') ) {
          arrIndex = index;
          stock_id = obj.id;

          $('#no-more-tables').find('.dir-po-edit-item').removeAttr('disabled').text('Edit');
          return false;
        }
      })

      if (!stock_id) {
        $.each(scope.po.po_items, function(index, obj) {
          if ( obj.item_number == rowElement.attr('inum') ) {
            arrIndex = index;

            //scope.selectedItem.id = scope.po.po_items[arrIndex].id;
            scope.selectedItem.item_number = scope.po.po_items[arrIndex].item_number;
            scope.selectedItem.item = scope.po.po_items[arrIndex];
            scope.selectedItem.quantity = scope.po.po_items[arrIndex].quantity;
            scope.selectedItem.unit = scope.po.po_items[arrIndex].unit;
            scope.selectedItem.cost = scope.po.po_items[arrIndex].cost;
            scope.selectedItem.amount = scope.po.po_items[arrIndex].amount;
            scope.selectedItem.remarks = scope.po.po_items[arrIndex].remarks;
            scope.selectedItem.edited = 'yes';

            scope.$apply();

            element.attr('disabled', true);
            element.text('Editing..');
            $helper.removeNotify();
            return false;
          }
        })
        return;
      }

      $http({
        url: $routes.has_dependents_stocks_path(),
        method: 'get',
        params: { id: stock_id }
      })
      .then(function(response) {
        if (response.data == false) {
          // allow edit item
          //scope.selectedItem.id = scope.po.po_items[arrIndex].id;
          scope.selectedItem.id = scope.po.po_items[arrIndex].id;
          scope.selectedItem.item_number = scope.po.po_items[arrIndex].item_number;
          scope.selectedItem.item = scope.po.po_items[arrIndex];
          scope.selectedItem.quantity = scope.po.po_items[arrIndex].quantity;
          scope.selectedItem.unit = scope.po.po_items[arrIndex].unit;
          scope.selectedItem.cost = scope.po.po_items[arrIndex].cost;
          scope.selectedItem.amount = scope.po.po_items[arrIndex].amount;
          scope.selectedItem.remarks = scope.po.po_items[arrIndex].remarks;
          scope.selectedItem.edited = 'yes';

          element.attr('disabled', true);
          element.text('Editing..');
          $helper.removeNotify(response.data.message);
        } else {
          $helper.notify(response.data.message);
        }
      })
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});

// Directive update an item on stock table.
App.directive('dirPoEditUpdateItem', function ($templateCache, $compile, $http, $window, $stateParams, HelperService) {

  function linker(scope, element) {
    var $routes = Routes;
    var $helper = HelperService;

    element.click(function(event) {
      event.preventDefault();
      $.each(scope.po.po_items, function(index, obj) {
        if ( obj.item_number == scope.selectedItem.item_number ) {
          obj.item_number = scope.selectedItem.item_number;
          obj.item = scope.selectedItem;
          obj.name = scope.selectedItem.item.name;
          obj.item_id = scope.selectedItem.item.id;
          obj.quantity = scope.selectedItem.quantity;
          obj.unit = scope.selectedItem.unit;
          obj.cost = scope.selectedItem.cost;
          obj.amount = scope.selectedItem.quantity * scope.selectedItem.cost;
          obj.remarks = scope.selectedItem.remarks;
          obj.edited = 'yes';

          scope.$apply();

          // reset seleted item.
          scope.selectedItem = {
            item: null, quantity: null, unit: null, cost: null, amount: 0, edited: 'no', remarks: null
          };
          scope.$apply();

          // reset edit buttons.
          $('#no-more-tables').find('.dir-po-edit-item').removeAttr('disabled').text('Edit');
          return false;
        }
      })
    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});

// Directive delete an item on stock table.
App.directive('dirPoEditDeleteItem', function ($templateCache, $compile, $http, $window, $stateParams, HelperService) {

  function linker(scope, element) {
    var $routes = Routes;
    var $helper = HelperService;

    element.click(function() {
      var rowElement = element.parents('tr');
      var arrIndex = null;
      var stock_id = null;

      $.each(scope.po.po_items, function(index, obj) {
        if ( obj.id == rowElement.attr('iid') ) {
          arrIndex = index;
          stock_id = obj.id;
          return false;
        }
      })

      if (stock_id) {
        $http({
          url: $routes.has_dependents_stocks_path(),
          method: 'get',
          params: { id: stock_id }
        })
        .then(function(response) {
          if (response.data == false) {
            if ( confirm('Please confirm delete action.') ) {
              scope.po.po_items[arrIndex].delete = 'yes';
              rowElement.addClass('hidden');
              $helper.removeNotify();
            }
          } else {
            $helper.notify(response.data.message);
          }
        })
      }

    })
  }

  return {
    restrict: 'C',
    link: linker
  };
});


// Directive update PO.
App.directive('dirUpdatePo', function ($templateCache, $compile, $state, $stateParams, $http, $window, HelperService) {

  function linker(scope, element) {

    // instances
    var $helper = HelperService;
    var $routes = Routes;


    element.click(function (event) {
      event.preventDefault();
      $.ajax({
        url : $routes.purchase_order_path($stateParams.id),
        type : 'put',
        data : $helper.injectAuthToken(scope.po),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element);
        }
      })
      .done(function () {
        $state.go('po.view', { id: $stateParams.id });
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