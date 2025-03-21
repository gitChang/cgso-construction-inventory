'use strict';

App.controller('LoginController', function ($scope, $http, HelperService) {

  // vars and instances.
  var $helper = HelperService;


  // payload.
  $scope.credentials = {
    username : null,
    password : null
  };

});