'use strict';


var App = angular.module('cgsois', [
  'ngResource',
  'ngCookies',
  'ui.router',
  'ngSanitize',
  'ui.select',
  'ui.bootstrap.datetimepicker',
  'templates',
  'angularMoment',
  'angular-clipboard'
]);


function configCallback($stateProvider, $urlRouterProvider, $locationProvider, uiSelectConfig) {
  $stateProvider
    .state('login', {
      url : '/login',
      templateUrl : 'login-page.html',
      controller : 'LoginController'
    })
    .state('home', {
      url : '/home',
      templateUrl : 'home-page.html',
      controller : 'HomeController'
    })
    .state('enroll', {
      url : '/enroll',
      templateUrl : 'enroll-page.html',
      controller : 'EnrollController'
    })
    .state('change-log', {
      url : '/change-log',
      templateUrl : 'change-log-page.html',
      controller : 'ChangeLogController'
    })

    // project stock card
    .state('projects', {
      redirectTo : 'projects.collect',
      url : '/projects',
      templateUrl : 'projects-page.html'
    })
      .state('projects.collect', {
        url : '/collect',
        templateUrl : 'projects-collect-page.html',
        controller : 'ProjectsCollectController'
      })
      .state('projects.compose', {
        url : '/compose',
        templateUrl : 'projects-compose-page.html',
        controller : 'ProjectsComposeController'
      })
      .state('projects.view', {
        url : '/view/:pr_number',
        templateUrl : 'projects-view-page.html',
        controller : 'ProjectsViewController'
      })
      .state('projects.edit', {
        url : '/edit/:id',
        templateUrl : 'projects-edit-page.html',
        controller : 'ProjectsEditController'
      })
      .state('projects.new_in_charge', {
        url : '/new-in-charge',
        templateUrl : 'project-in-charge-compose-page.html',
        controller : 'ProjectInChargeController'
      })
      // certification of delivery
      .state('projects.cert_of_delivery', {
        url : '/cert-of-delivery/:pr_number',
        templateUrl : 'cert-of-delivery.html',
        controller : 'CertOfDeliveryController'
      })
      .state('projects.po_collect', {
        url : '/po_collect/:pr_number',
        templateUrl : 'projects-po-collect-page.html',
        controller : 'ProjectsPoCollectController'
      })

    // item masterlist
    .state('im', {
      redirectTo : 'im.collect',
      url : '/im',
      templateUrl : 'im-page.html'
    })
      .state('im.collect', {
        url : '/collect',
        templateUrl : 'im-collect-page.html',
        controller : 'ImCollectController'
      })
      .state('im.compose', {
        url : '/compose',
        templateUrl : 'im-compose-page.html',
        controller : 'ImComposeController'
      })
      .state('im.view', {
        url : '/view/:id',
        templateUrl : 'im-view-page.html',
        controller : 'ImViewController'
      })
      .state('im.edit', {
        url : '/edit/:id',
        templateUrl : 'im-edit-page.html',
        controller : 'ImEditController'
      })
      .state('im.rcpi-filter', {
        url : '/rcpi-filter',
        templateUrl : 'im-rcpi-filter-page.html',
        controller : 'ImRcpiFilterController'
      })

    // stock card
    .state('stock-card', {
      url : '/stock-card/:item_id',
      templateUrl : 'stock-card-page.html',
      controller : 'StockCardController'
    })

    // Savings
    .state('savings', {
      redirectTo : 'savings.project',
      url : '/savings',
      templateUrl : 'savings-page.html'
    })
      .state('savings.project', {
        url : '/project',
        templateUrl : 'savings-project-page.html',
        controller : 'SavingsProjectController'
      })
      .state('savings.item', {
        url : '/item',
        templateUrl : 'savings-item-page.html',
        controller : 'SavingsItemController'
      })

    .state('add_unit', {
      url : '/add-unit',
      templateUrl : 'unit-page.html',
      controller : 'UnitController'
    })

    .state('add_supply', {
      url : '/add-supply',
      templateUrl : 'supply-page.html',
      controller : 'SupplyController'
    })

    .state('add_department', {
      url : '/add-department',
      templateUrl : 'department-page.html',
      controller : 'DepartmentController'
    })

    .state('add_mode_of_proc', {
      url : '/add-mode-of-proc',
      templateUrl : 'mode-of-proc-page.html',
      controller : 'ModeOfProcurementController'
    })

    .state('supplier', {
      redirectTo : 'supplier.collect',
      url : '/supplier',
      templateUrl : 'supplier-page.html'
    })
      .state('supplier.collect', {
        url : '/collect',
        templateUrl : 'supplier-collect-page.html',
        controller : 'SupplierCollectController'
      })
      .state('supplier.compose', {
        url : '/compose',
        templateUrl : 'supplier-compose-page.html',
        controller : 'SupplierComposeController'
      })
      .state('supplier.view', {
        url : '/view/:id',
        templateUrl : 'supplier-view-page.html',
        controller : 'SupplierViewController'
      })
      .state('supplier.edit', {
        url : '/edit/:id',
        templateUrl : 'supplier-edit-page.html',
        controller : 'SupplierEditController'
      })

    // propert return slip
    .state('prs', {
      redirectTo : 'prs.compose',
      url : '/prs',
      templateUrl : 'prs-page.html'
    })
      .state('prs.compose', {
        url : '/compose/:pr_number',
        templateUrl : 'prs-compose-page.html',
        controller : 'PrsComposeController'
      })

    // purchase order
    .state('po', {
      redirectTo : 'po.collect',
      url : '/po',
      templateUrl : 'po-page.html'
    })
      .state('po.collect', {
        url : '/collect',
        templateUrl : 'po-collect-page.html',
        controller : 'PoCollectController'
      })
      .state('po.compose', {
        url : '/compose',
        templateUrl : 'po-compose-page.html',
        controller : 'PoComposeController'
      })
      .state('po.view', {
        url : '/view/:id',
        templateUrl : 'po-view-page.html',
        controller : 'PoViewController'
      })
      .state('po.edit', {
        url : '/edit/:id',
        templateUrl : 'po-edit-page.html',
        controller : 'PoEditController'
      })
      .state('po.stock-card', {
        url : '/stock-card/:poid',
        templateUrl : 'po-stock-card-page.html',
        controller : 'PoStockCardController'
      })

    // requisition issued slip
    .state('ris', {
      redirectTo : 'ris.collect',
      url : '/ris',
      templateUrl : 'ris-page.html'
    })
      .state('ris.collect', {
        url : '/collect',
        templateUrl : 'ris-collect-page.html',
        controller : 'RisCollectController'
      })
      .state('ris.compose', {
        url : '/compose',
        templateUrl : 'ris-compose-page.html',
        controller : 'RisComposeController'
      })
      .state('ris.view', {
        url : '/view/:id',
        templateUrl : 'ris-view-page.html',
        controller : 'RisViewController'
      })
      .state('ris.edit', {
        url : '/edit/:id',
        templateUrl : 'ris-edit-page.html',
        controller : 'RisEditController'
      })

    // requisition issued slip
    .state('endorsement', {
      redirectTo : 'endorsement.collect',
      url : '/endorsement',
      templateUrl : 'endorsed-page.html'
    })
      .state('endorsement.collect', {
        url : '/collect',
        templateUrl : 'endorsed-collect-page.html',
        controller : 'EndorsedCollectController'
      })
      .state('endorsement.compose', {
        url : '/compose',
        templateUrl : 'endorse-compose-page.html',
        controller : 'EndorseComposeController'
      })
      .state('endorsement.edit', {
        url : '/edit/:id',
        templateUrl : 'endorse-edit-page.html',
        controller : 'EndorseEditController'
      })
      .state('endorsement.po_collect', {
        url : '/po-collect',
        templateUrl : 'endorsed-po-collect-page.html',
        controller : 'EndorsedPoCollectController'
      })
      .state('endorsement.po_compose', {
        url : '/po-compose',
        templateUrl : 'endorse-po-compose-page.html',
        controller : 'EndorsePoComposeController'
      })
      .state('endorsement.po_edit', {
        url : '/po-edit/:id',
        templateUrl : 'endorse-po-edit-page.html',
        controller : 'EndorsePoEditController'
      })

  //$urlRouterProvider.otherwise('/login');  // default fall back route.
  $locationProvider.html5Mode(true);  // remove hash on the url.


  // angular-ui-select config.
  uiSelectConfig.theme = 'bootstrap';
  uiSelectConfig.resetSearchInput = true;
  uiSelectConfig.appendToBody = true;
}

//
// configs
//
App.config(configCallback);

// initiate daemon service by injecting on run()
App.run(['DaemonService', function (DaemonService) {}]);