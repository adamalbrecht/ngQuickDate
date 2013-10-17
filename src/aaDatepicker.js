angular.module('aaDatepickerLib', []).directive('aaDatepicker', function() {
  return {
    restrict: 'E',
    scope: {
      label: '@',
      hoverText: '@',
      placeholder: '@'
    },
    transclude: true,
    replace: true,
    link: function($scope, element, attrs) {
      $scope.displayValue = attrs.placeholder;
      $scope.buttonClass = attrs.buttonClass ? attrs.buttonClass : 'aa-datepicker-button';
      $scope.calendarShown = false;
      $scope.toggleCalendar = function() {
        console.log("Opening calendar");
        $scope.calendarShown = !$scope.calendarShown;
      }
    },
    template:
      "<div class='aa-datepicker'><a href='' ng-click='toggleCalendar()' class='{{buttonClass}}' title='{{hoverText}}'><span ng-transclude></span><span>{{displayValue}}</a>"
        + "<div class='aa-calendar-wrapper' ng-class='{open: calendarShown}'>"
          + "<div class='aa-calendar-header'>{{displayValue}}<a href='' class='close' ng-click='toggleCalendar()'>X</a></div>"
          + "<div class='aa-input-wrapper'><label>Date</label><input type='text' placeholder='1/1/2013' /></div>"
          + "<div class='aa-input-wrapper'><label>Time</label><input type='text' placeholder='12:00pm' /></div>"
          + "<div class='aa-calendar'>Calendar goes here</div>"
        + "</div>"
      + "</div>"
  };
});
