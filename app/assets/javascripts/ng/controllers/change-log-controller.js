'use strict';

App.controller('ChangeLogController', function ($rootScope, $scope, $http, $state) {

  // vars and instances.
  var $routes = Routes;


  // set page title.
  $rootScope.pageTitle = 'Change Log';

  // payload.
  $scope.log = { doc: null, doc_number: null, message: null };

  // response key/edit key
  $scope.edit_key = null;

  $scope.us_disabled = false;
  $scope.dn_input_disabled = false;
  $scope.msg_textarea_disabled = false;

  // prevent access if not admin.
  $http({
    url : $routes.is_admin_application_index_path(),
    method : 'get'
  })
  .then(function (response) {
    if (response.data.access_granted !== 'yes') {
      $state.go('home');
    }
  })
})