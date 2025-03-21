'use strict';

App.service('DaemonService',
function ($templateCache, $cookies, $http, $rootScope, $location, $state, $q, $window, HelperService) {

  // store authenticity token to cookies every action.
  function inspectAccess() {
    var deferred = $q.defer();
    $http.get(Routes.user_access_path()).then(function(res) {
      deferred.resolve(res.data);
    })
    return deferred.promise;
  }

  // parent state redirect to default child state.
  $rootScope.$on('$stateChangeStart', function(evt, to, params) {
    // remove notification.
    HelperService.removeNotify();

    if (to.redirectTo) {
      evt.preventDefault();
      $state.go(to.redirectTo, params)
    }
  });
  // change body color to white when /login
  $rootScope.$on('$locationChangeSuccess', function () {
    // redirect to login if not aunthenticated.
    inspectAccess().then( function (access) {
      if (access === false) {
        if ($location.path().indexOf('/login') > -1) return;
        $window.location.pathname = $state.href('login');
      }

      if (access === true) {
        if ($location.path().indexOf('/login') > -1) {
          $window.location.pathname = $state.href('home');
        }
      }
    })

    // change body color to #fff
    if ($location.path().indexOf('/login') > -1
    || $location.path().indexOf('/view/') > -1
    || $location.path().indexOf('/po/stock-card/') > -1
    || $location.path().indexOf('/cert-of-delivery/') > -1) {
      $('body').css('background-color', '#fff')
    } else {
      $('body').removeAttr('style');
    }
  })
  // hide nav items in navbar on click navbar-links click
  $rootScope.$on('$viewContentLoaded', function () {
    if ($('button.navbar-toggle').attr('aria-expanded') === 'true') {
      $('button.navbar-toggle').trigger('click');
    }
  })
})