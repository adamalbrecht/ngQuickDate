app = angular.module("aaDatepickerDemo", ["aaDatepickerLib"])
app.controller "example1Ctrl", ($scope) ->
  $scope.myDate = Date.parse("10/26/2013")

app.controller "example2Ctrl", ($scope) ->
  $scope.myDate = null
