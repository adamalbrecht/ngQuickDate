(function() {
  var app;

  app = angular.module("ngQuickDate", []);

  app.provider("ngQuickDateDefaults", function() {
    return {
      options: {
        dateFormat: 'M/d/yyyy',
        timeFormat: 'h:mm a',
        labelFormat: null,
        placeholder: 'Click to Set Date',
        hoverText: null,
        buttonIconHtml: null,
        closeButtonHtml: 'X',
        nextLinkHtml: 'Next',
        prevLinkHtml: 'Prev',
        disableTimepicker: false,
        disableClearButton: false,
        dayAbbreviations: ["Su", "M", "Tu", "W", "Th", "F", "Sa"],
        parseDateFunction: function(str) {
          var seconds;
          seconds = Date.parse(str);
          if (isNaN(seconds)) {
            return null;
          } else {
            return new Date(seconds);
          }
        }
      },
      $get: function() {
        return this.options;
      },
      set: function(keyOrHash, value) {
        var k, v, _results;
        if (typeof keyOrHash === 'object') {
          _results = [];
          for (k in keyOrHash) {
            v = keyOrHash[k];
            _results.push(this.options[k] = v);
          }
          return _results;
        } else {
          return this.options[keyOrHash] = value;
        }
      }
    };
  });

  app.directive("datepicker", [
    'ngQuickDateDefaults', '$filter', '$sce', function(ngQuickDateDefaults, $filter, $sce) {
      return {
        restrict: "E",
        require: "ngModel",
        scope: {
          ngModel: "=",
          onChange: "&"
        },
        replace: true,
        link: function(scope, element, attrs, ngModel) {
          var dateToString, datepickerClicked, datesAreEqual, debug, getDaysInMonth, initialize, parseDateString, setCalendarDateFromModel, setCalendarRows, setConfigOptions, setInputDateFromModel;
          debug = attrs.debug && attrs.debug.length;
          initialize = function() {
            scope.toggleCalendar(false);
            scope.weeks = [];
            scope.inputDate = null;
            if (typeof scope.ngModel === 'string') {
              scope.ngModel = parseDateString(scope.ngModel);
            }
            if (typeof attrs.initValue === 'string') {
              scope.ngModel = parseDateString(attrs.initValue);
            }
            setConfigOptions();
            setInputDateFromModel();
            return setCalendarDateFromModel();
          };
          setConfigOptions = function() {
            var key, value;
            for (key in ngQuickDateDefaults) {
              value = ngQuickDateDefaults[key];
              if (key.match(/[Hh]tml/)) {
                scope[key] = $sce.trustAsHtml(ngQuickDateDefaults[key] || "");
              } else if (attrs[key]) {
                scope[key] = attrs[key];
              } else {
                scope[key] = ngQuickDateDefaults[key];
              }
            }
            if (!scope.labelFormat) {
              scope.labelFormat = scope.dateFormat;
              if (!scope.disableTimepicker) {
                scope.labelFormat += " " + scope.timeFormat;
              }
            }
            if (attrs.iconClass && attrs.iconClass.length) {
              return scope.buttonIconHtml = $sce.trustAsHtml("<i ng-show='iconClass' class='" + attrs.iconClass + "'></i>");
            }
          };
          datepickerClicked = false;
          window.document.addEventListener('click', function(event) {
            if (!datepickerClicked) {
              scope.toggleCalendar(false);
              scope.$apply();
            }
            return datepickerClicked = false;
          });
          angular.element(element[0])[0].addEventListener('click', function(event) {
            return datepickerClicked = true;
          });
          setInputDateFromModel = function() {
            if (scope.ngModel) {
              scope.inputDate = $filter('date')(scope.ngModel, ngQuickDateDefaults.dateFormat);
              return scope.inputTime = $filter('date')(scope.ngModel, ngQuickDateDefaults.timeFormat);
            } else {
              scope.inputDate = null;
              return scope.inputTime = null;
            }
          };
          setCalendarDateFromModel = function() {
            var d;
            d = scope.ngModel ? new Date(scope.ngModel) : new Date();
            if (d.toString() === "Invalid Date") {
              d = new Date();
            }
            d.setDate(1);
            return scope.calendarDate = new Date(d);
          };
          setCalendarRows = function() {
            var curDate, d, day, daysInMonth, numRows, offset, row, selected, today, weeks, _i, _j, _ref;
            offset = scope.calendarDate.getDay();
            daysInMonth = getDaysInMonth(scope.calendarDate.getFullYear(), scope.calendarDate.getMonth());
            numRows = Math.ceil((offset + daysInMonth) / 7);
            weeks = [];
            curDate = new Date(scope.calendarDate);
            curDate.setDate(curDate.getDate() + (offset * -1));
            for (row = _i = 0, _ref = numRows - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; row = 0 <= _ref ? ++_i : --_i) {
              weeks.push([]);
              for (day = _j = 0; _j <= 6; day = ++_j) {
                d = new Date(curDate);
                selected = scope.ngModel && d && datesAreEqual(d, scope.ngModel);
                today = datesAreEqual(d, new Date());
                weeks[row].push({
                  date: d,
                  selected: selected,
                  other: d.getMonth() !== scope.calendarDate.getMonth(),
                  today: today
                });
                curDate.setDate(curDate.getDate() + 1);
              }
            }
            return scope.weeks = weeks;
          };
          dateToString = function(date, format) {
            return $filter('date')(date, format);
          };
          parseDateString = ngQuickDateDefaults.parseDateFunction;
          datesAreEqual = function(d1, d2, compareTimes) {
            if (compareTimes == null) {
              compareTimes = false;
            }
            if (compareTimes) {
              return (d1 - d2) === 0;
            } else {
              return d1 && d2 && (d1.getYear() === d2.getYear()) && (d1.getMonth() === d2.getMonth()) && (d1.getDate() === d2.getDate());
            }
          };
          getDaysInMonth = function(year, month) {
            return [31, ((year % 4 === 0 && year % 100 !== 0) || year % 400 === 0 ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
          };
          scope.$watch('ngModel', function(newVal, oldVal) {
            if (newVal !== oldVal) {
              setInputDateFromModel();
              return setCalendarDateFromModel();
            }
          });
          scope.$watch('calendarDate', function(newVal, oldVal) {
            if (newVal !== oldVal) {
              return setCalendarRows();
            }
          });
          scope.$watch('calendarShown', function(newVal, oldVal) {
            var dateInput;
            dateInput = angular.element(element[0].querySelector(".quickdate-date-input"))[0];
            return dateInput.select();
          });
          scope.mainButtonStr = function() {
            if (scope.ngModel) {
              return $filter('date')(scope.ngModel, scope.labelFormat);
            } else {
              return scope.placeholder;
            }
          };
          scope.toggleCalendar = function(show) {
            if (isFinite(show)) {
              return scope.calendarShown = show;
            } else {
              return scope.calendarShown = !scope.calendarShown;
            }
          };
          scope.setDate = function(date, closeCalendar) {
            var changed;
            if (closeCalendar == null) {
              closeCalendar = true;
            }
            changed = (!scope.ngModel && date) || (scope.ngModel && !date) || (date.getTime() !== scope.ngModel.getTime());
            scope.ngModel = date;
            if (closeCalendar) {
              scope.toggleCalendar(false);
            }
            if (changed && scope.onChange) {
              return scope.onChange();
            }
          };
          scope.setDateFromInput = function(closeCalendar) {
            var err, tmpDate, tmpDateAndTime, tmpTime;
            if (closeCalendar == null) {
              closeCalendar = false;
            }
            try {
              tmpDate = parseDateString(scope.inputDate);
              if (!tmpDate) {
                throw 'Invalid Date';
              }
              if (!scope.disableTimepicker && scope.inputTime && scope.inputTime.length && tmpDate) {
                tmpTime = scope.disableTimepicker ? '00:00:00' : scope.inputTime;
                tmpDateAndTime = parseDateString("" + scope.inputDate + " " + tmpTime);
                if (!tmpDateAndTime) {
                  throw 'Invalid Time';
                }
                scope.setDate(tmpDateAndTime, false);
              } else {
                scope.setDate(tmpDate, false);
              }
              if (closeCalendar) {
                scope.toggleCalendar(false);
              }
              scope.inputDateErr = false;
              return scope.inputTimeErr = false;
            } catch (_error) {
              err = _error;
              if (err === 'Invalid Date') {
                return scope.inputDateErr = true;
              } else if (err === 'Invalid Time') {
                return scope.inputTimeErr = true;
              }
            }
          };
          scope.onDateInputTab = function(param) {
            if (scope.disableTimepicker) {
              scope.toggleCalendar(false);
            }
            return true;
          };
          scope.onTimeInputTab = function(param) {
            scope.toggleCalendar(false);
            return true;
          };
          scope.nextMonth = function() {
            return scope.calendarDate = new Date(new Date(scope.calendarDate).setMonth(scope.calendarDate.getMonth() + 1));
          };
          scope.prevMonth = function() {
            return scope.calendarDate = new Date(new Date(scope.calendarDate).setMonth(scope.calendarDate.getMonth() - 1));
          };
          scope.clear = function() {
            scope.ngModel = null;
            return scope.toggleCalendar(false);
          };
          initialize();
          setCalendarRows();
          if (debug) {
            return console.log("quick date scope:", scope);
          }
        },
        template: "<div class='quickdate'>\n  <a href='' ng-focus='toggleCalendar(true)' ng-click='toggleCalendar()' class='quickdate-button' title='{{hoverText}}'><div ng-hide='iconClass' ng-bind-html='buttonIconHtml'></div>{{mainButtonStr()}}</a>\n  <div class='quickdate-popup' ng-class='{open: calendarShown}'>\n    <a href='' tabindex='-1' class='quickdate-close' ng-click='toggleCalendar()'><div ng-bind-html='closeButtonHtml'></div></a>\n    <div class='quickdate-text-inputs'>\n      <div class='quickdate-input-wrapper'>\n        <label>Date</label>\n        <input class='quickdate-date-input' name='inputDate' type='text' ng-model='inputDate' placeholder='1/1/2013' ng-blur=\"setDateFromInput()\" ng-enter=\"setDateFromInput(true)\" ng-class=\"{'ng-quick-date-error': inputDateErr}\"  ng-tab='onDateInputTab()' />\n      </div>\n      <div class='quickdate-input-wrapper' ng-hide='disableTimepicker'>\n        <label>Time</label>\n        <input class='quickdate-time-input' name='inputTime' type='text' ng-model='inputTime' placeholder='12:00 PM' ng-blur=\"setDateFromInput(false)\" ng-enter=\"setDateFromInput(true)\" ng-class=\"{'quickdate-error': inputTimeErr}\" ng-tab='onTimeInputTab()'>\n      </div>\n    </div>\n    <div class='quickdate-calendar-header'>\n      <a href='' class='quickdate-prev-month quickdate-action-link' tabindex='-1' ng-click='prevMonth()'><div ng-bind-html='prevLinkHtml'></div></a>\n      <span class='quickdate-month'>{{calendarDate | date:'MMMM yyyy'}}</span>\n      <a href='' class='quickdate-next-month quickdate-action-link' ng-click='nextMonth()' tabindex='-1' ><div ng-bind-html='nextLinkHtml'></div></a>\n    </div>\n    <table class='quickdate-calendar'>\n      <thead>\n        <tr>\n          <th ng-repeat='day in dayAbbreviations'>{{day}}</th>\n        </tr>\n      </thead>\n      <tbody>\n        <tr ng-repeat='week in weeks'>\n          <td ng-mousedown='setDate(day.date)' ng-class='{\"other-month\": day.other, \"selected\": day.selected, \"is-today\": day.today}' ng-repeat='day in week'>{{day.date | date:'d'}}</td>\n        </tr>\n      </tbody>\n    </table>\n    <div class='quickdate-popup-footer'>\n      <a href='' class='quickdate-clear' tabindex='-1' ng-hide='disableClearButton' ng-click='clear()'>Clear</a>\n    </div>\n  </div>\n</div>"
      };
    }
  ]);

  app.directive('ngEnter', function() {
    return function(scope, element, attr) {
      return element.bind('keydown keypress', function(e) {
        if (e.which === 13) {
          scope.$apply(attr.ngEnter);
          return e.preventDefault();
        }
      });
    };
  });

  app.directive('ngTab', function() {
    return function(scope, element, attr) {
      return element.bind('keydown keypress', function(e) {
        if (e.which === 9) {
          return scope.$apply(attr.ngTab);
        }
      });
    };
  });

}).call(this);
