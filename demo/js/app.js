(function() {
  var app;

  app = angular.module("aaDatepickerDemo", ["aaDatepickerLib"]);

  app.controller("example1Ctrl", function($scope) {
    return $scope.date1 = "10/26/2013";
  });

}).call(this);
