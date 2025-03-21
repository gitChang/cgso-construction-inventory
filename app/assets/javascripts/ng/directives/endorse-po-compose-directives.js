'use strict';

App.directive('selectPo', function (HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;

    element.on('click', function (e) {
      var selected = element.val();
      var aidx = element.closest("tr").attr("idx");
      var pon = element.closest("tr").find(".po-n").html().trim();
      console.log(pon);

      if (selected == "true") {
        scope.endo.pos.unshift( scope.project_pos[parseInt(aidx)] );
        scope.$apply();
      } else {
        for (var i = scope.endo.pos.length - 1; i >= 0; i--) {
          if (scope.endo.pos[i].po_number == pon) {
            scope.endo.pos.splice(i, 1);
            scope.$apply();
          }
        }
      }
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});


App.directive('createPoEndorsement', function ($window, $http, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;

    element.click( function () {
      $.ajax({
        url : '/api/endorsement_pos',
        type : 'post',
        data : $helper.injectAuthToken({ letter: scope.endo }),
        dataType : 'json',
        beforeSend : function () {
          $helper.animateProcess(element)
        }
      })
      .done(function (data) {
        $http({
          url : '/api/endorsement_pos/download_pdf',
          method : 'get',
          params : { id: data.endo_po_id }
        })
        .then(function (response) {
          $window.location.href = '/endorsement_po.pdf';
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