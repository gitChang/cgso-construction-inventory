'use strict';

App.directive('removePow', function (HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;

    element.on('click', function (e) {
      e.preventDefault();

      angular.forEach(scope.endo.projects, function(obj, index) {
        if (obj.$$hashKey === element.attr('data-hk')) {
          scope.endo.projects.splice(index, 1);
          scope.$apply();
          return;
        }
      });
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});


App.directive('pushPowNumber', function (HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.on('keyup', function (e) {
      if (e.keyCode == 13) {
        $helper.removeNotify();

        // see if duplicate
        for (var i in scope.endo.projects) {
          if (scope.endo.projects[i].pow_number == scope.pow_number) {
            $helper.notify('Duplicate POW Number.');
            return;
          }
        }

        // VERIFY IF ALREADY ENDORSED.
        $.ajax({
          url : '/api/endorsements/is_endorsed',
          type : 'get',
          data : { pow_number: scope.pow_number },
          dataType : 'json'
        })
        .done(function (pow) {
          // GET POW INFO WHEN OK.
          $.ajax({
            url : '/api/endorsements/get_pow_data',
            type : 'get',
            data : $helper.injectAuthToken({ pow_number: scope.pow_number }),
            dataType : 'json'
          })
          .done(function (pow) {
            scope.endo.projects.unshift({
              pow_number: pow.pow_number,
              purpose: pow.purpose,
              total_cost: pow.total_cost
            });
            scope.pow_number = null;
            scope.$apply();
          })
          .fail(function (error) {
            // ????
          })
        })
        .fail(function (error) {
          $helper.notify('Project is already endorsed!');
        })
      }
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});


App.directive('createEndorsement', function ($window, $http, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;

    element.click( function () {
      $.ajax({
        url : '/api/endorsements',
        type : 'post',
        data : $helper.injectAuthToken({ letter: scope.endo }),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function (data) {
        $http({
          url : '/api/endorsements/download_pdf',
          method : 'get',
          params : { id: data.endoid }
        })
        .then(function (response) {
          $window.location.href = '/endorsement.pdf';
        })
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
    restrict : 'C',
    link : linker
  };
});