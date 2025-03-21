'use strict';

App.directive('removePowEdit', function (HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;
    var $routes = Routes;

    element.on('click', function (e) {
      e.preventDefault();

      angular.forEach(scope.endo.projects, function(obj, index) {
        if (obj.$$hashKey === element.attr('data-hk')) {
          $.ajax({
            url : '/api/endorsements/remove_project',
            type : 'post',
            data : $helper.injectAuthToken({ pow_number: obj.pow_number }),
            dataType : 'json'
          })
          .done(function (pow) {
            scope.endo.projects.splice(index, 1);
            scope.$apply();
            return;
          })
          .fail(function (error) {
            // hightlight error field and display message
            $helper.notify('Unable to find POW Number.');
          })
        }
      });
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});


App.directive('updateEndorsement', function ($http, $stateParams, $window, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;

    element.click( function () {
      $.ajax({
        url : Routes.endorsement_path($stateParams.id),
        type : 'put',
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