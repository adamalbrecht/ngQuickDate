app = angular.module("ngQuickDateDemo", ["ngQuickDate"])

app.config((ngQuickDateDefaultsProvider) ->
  ngQuickDateDefaultsProvider.set({
    closeButtonHtml: "<i class='icon-remove'></i>"
    buttonIconHtml: "<i class='icon-time'></i>"
    nextLinkHtml: "<i class='icon-chevron-right'></i>"
    prevLinkHtml: "<i class='icon-chevron-left'></i>"
  })
)
app.controller "example1Ctrl", ($scope) ->
  $scope.date1 = new Date()
  $scope.date2 = null

app.controller "example2Ctrl", ($scope) ->
  $scope.myDate = null
