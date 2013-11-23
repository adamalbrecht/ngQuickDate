(function() {
  var app;

  app = angular.module("ngQuickDateDemo", ["ngQuickDate"]);

  app.config(function(ngQuickDateDefaultsProvider) {
    return ngQuickDateDefaultsProvider.set({
      labelFormat: 'EEEE, MMMM d, yyyy',
      closeButtonHtml: "<i class='icon-remove'></i>",
      buttonIconHtml: "<i class='icon-time'></i>",
      nextLinkHtml: "<i class='icon-chevron-right'></i>",
      prevLinkHtml: "<i class='icon-chevron-left'></i>"
    });
  });

  app.controller("example1Ctrl", function($scope) {
    $scope.date1 = new Date(Date.parse("10/16/2013"));
    return $scope.date2 = null;
  });

  app.controller("example2Ctrl", function($scope) {
    return $scope.myDate = null;
  });

}).call(this);
