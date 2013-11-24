var app;

app = angular.module("ngQuickDateDemo", ["ngQuickDate"]);

app.config(function(ngQuickDateDefaultsProvider) {
  return ngQuickDateDefaultsProvider.set({
    closeButtonHtml: "<i class='fa fa-times'></i>",
    buttonIconHtml: "<i class='fa fa-clock-o'></i>",
    nextLinkHtml: "<i class='fa fa-chevron-right'></i>",
    prevLinkHtml: "<i class='fa fa-chevron-left'></i>"
  });
});

app.controller("example1Ctrl", function($scope) {
  $scope.date1 = new Date();
  return $scope.date2 = null;
});

app.controller("example2Ctrl", function($scope) {
  return $scope.myDate = null;
});
