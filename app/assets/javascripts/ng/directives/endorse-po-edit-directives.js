'use strict';

App.directive('selectEditPo', function ($http, $stateParams, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;

    element.on('click', function (e) {
      var selected = element.val();
      var aidx = element.closest("tr").attr("idx");
      var pon = element.closest("tr").find(".po-n").html().trim();

      if (selected == "true") {
        $http({
          url: '/api/endorsement_pos/endorse_po',
          method: 'post',
          params: $helper.injectAuthToken({ endopoid: $stateParams.id, po_number: pon })
        }).then(function (response) {
          var has_dup = false;
          for (var i = scope.endo.pos.length - 1; i >= 0; i--)
            if (scope.endo.pos[i].po_number == pon) has_dup = true;
          if (!has_dup)
            scope.endo.pos.unshift( scope.project_pos[parseInt(aidx)] );
        })
      }
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});


App.directive('unendoPo', function ($http, $stateParams, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;

    element.on('click', function (e) {
      var aidx = element.attr("idx");
      var pon = element.closest("tr").find(".po-n").html().trim();

      $http({
        url: '/api/endorsement_pos/unendorse_po',
        method: 'post',
        params: $helper.injectAuthToken({ endopoid: $stateParams.id, po_number: pon })
      }).then(function (response) {
        scope.endo.pos.splice(aidx, 1);
      })
    })
  }

  return {
    restrict : 'C',
    link : linker
  };
});


App.directive('updatePoEndorsement', function ($window, $http, $stateParams, HelperService) {

  function linker(scope, element) {

    // instances.
    var $helper = HelperService;

    element.click( function () {
      $.ajax({
        url : '/api/endorsement_pos/' + $stateParams.id,
        type : 'put',
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