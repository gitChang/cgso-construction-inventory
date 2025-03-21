App.directive('tr', function () {

  function linker(scope, element) {
    element.click(function () {
      $('table tbody tr').removeClass('active');
      element.addClass('active');
    });
  }

  return {
    restrict : 'E',
    link : linker
  };
});
