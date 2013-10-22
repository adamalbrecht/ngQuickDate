(function() {
  var app;

  app = angular.module("aaDatepickerLib", []);

  app.directive("aaDatepicker", [
    function() {
      return {
        restrict: "E",
        require: "ngModel",
        scope: {
          label: "@",
          hoverText: "@",
          placeholder: "@",
          iconClass: "@",
          ngModel: "="
        },
        replace: true,
        link: function(scope, element, attrs, ngModel) {
          var setDate;
          scope.calendarShown = false;
          scope.dayCodes = ["Su", "M", "Tu", "W", "Th", "F", "Sa"];
          scope.weeks = [];
          setDate = function() {
            scope.chosenDateTime = (scope.ngModel ? Date.parse(scope.ngModel) : null);
            return scope.chosenDateStr = (scope.chosenDateTime ? scope.chosenDateTime.toString("M/d/yyyy") : attrs.placeholder);
          };
          scope.$watch("ngModel", setDate);
          return scope.toggleCalendar = function() {
            return scope.calendarShown = !scope.calendarShown;
          };
        },
        template: "<div class='aa-datepicker'><a href='' ng-click='toggleCalendar()' class='aa-datepicker-button' title='{{hoverText}}'><i class='{{iconClass}}' ng-show='iconClass'></i>{{chosenDateStr}}</a>\n  <div class='aa-calendar-wrapper' ng-class='{open: calendarShown}'>\n    <div class='aa-calendar-header'>{{chosenDateStr}}<a href='' class='close' ng-click='toggleCalendar()'>X</a></div>\n    <div class='aa-input-wrapper'><label>Date</label><input class='aa-date-text-input' type='text' ng-model='chosenDateStr' placeholder='1/1/2013' /></div>\n    <table class='aa-calendar'>\n      <thead>\n        <tr>\n          <th ng-repeat='day in dayCodes'>{{day}}</th>\n        </tr>\n      </thead>\n      <tbody>\n        <tr ng-repeat='week in weeks'>\n          <td ng-repeat='day in week.days'>{{day}}</td>\n        </tr>\n      </tbody>\n    </table>\n  </div>\n</div>"
      };
    }
  ]);

}).call(this);
