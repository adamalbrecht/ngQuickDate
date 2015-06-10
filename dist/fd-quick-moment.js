(function() {
  var app;

  app = angular.module("fdQuickMoment", []);
  app.provider("fdQuickMomentDefaults", function() {
    return {
      options: {
        dateFormat: 'M/D/YYYY',
        timeFormat: 'h:mm A',
        labelFormat: null,
        placeholder: 'Click to Set Date',
        hoverText: null,
        buttonIconHtml: null,
        closeButtonHtml: '&times;',
        nextLinkHtml: 'Next &rarr;',
        prevLinkHtml: '&larr; Prev',
        disableTimepicker: false,
        disableDateinput: false,
        disableClearButton: false,
        defaultTime: null,
        dayAbbreviations: ["Su", "M", "Tu", "W", "Th", "F", "Sa"],
        dateFilter: null,
        timezone: "America/Chicago",

        parseDateFunction: function(str) {
          var m;
          m = moment(str);
          if (!m.isValid()) {
            return null;
          } else {
            return m;
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

  app.directive("momentpicker", [
    'fdQuickMomentDefaults', '$filter', '$sce', function(fdQuickMomentDefaults, $filter, $sce) {
      return {
        restrict: "E",
        require: "ngModel",
        scope: {
          dateFilter: '=?',
          ngModel: "=",
          onChange: "&"
        },
        replace: true,
        link: function(scope, element, attrs, ngModel) {
          var dateToString, datepickerClicked, datesAreEqual, datesAreEqualToMinute, debug, initialize, parseDateString, setCalendarDateFromModel, setCalendarRows, setConfigOptions, setInputDateFromModel, stringToDate, setDayStyles;
          debug = attrs.debug && attrs.debug.length;
          initialize = function() {
            scope.toggleCalendar(false);
            scope.weeks = [];
            scope.inputDate = null;
            scope.timezone = attrs.timezone;
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
            for (key in fdQuickMomentDefaults) {
              value = fdQuickMomentDefaults[key];
              if (key.match(/[Hh]tml/)) {
                scope[key] = $sce.trustAsHtml(fdQuickMomentDefaults[key] || "");
              } else if (!scope[key] && attrs[key]) {
                scope[key] = attrs[key];
              } else if (!scope[key]) {
                scope[key] = fdQuickMomentDefaults[key];
              }
            }
            if (!scope.labelFormat) {
              scope.labelFormat = scope.dateFormat;
              if (!scope.disableTimepicker) {
                scope.labelFormat += " " + scope.timeFormat;
              }
            }
            if (attrs.iconClass && attrs.iconClass.length) {
              scope.buttonIconHtml = $sce.trustAsHtml("<i ng-show='iconClass' class='" + attrs.iconClass + "'></i>");
            }
            if (scope.timezone === void 0) {
              throw "timezone required";
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
              scope.inputDate = scope.ngModel.format(scope.dateFormat);
              return scope.inputTime = scope.ngModel.format(scope.timeFormat);
            } else {
              scope.inputDate = null;
              return scope.inputTime = null;
            }
          };
          setCalendarDateFromModel = function() {
            var d;
            d = scope.ngModel ? moment(scope.ngModel).tz(scope.timezone) : moment().tz(scope.timezone);
            if (d === void 0 || !d.isValid()) {
              d = moment().tz(scope.timezone);
            }
            return scope.calendarDate = d.startOf('month').tz(scope.timezone);
          };
          setCalendarRows = function() {
            var curDate, d, day, daysInMonth, numRows, offset, row, selected, time, today, weeks, _i, _j, _ref;
            offset = scope.calendarDate.day();
            daysInMonth = scope.calendarDate.daysInMonth();
            numRows = Math.ceil((offset + daysInMonth) / 7);
            weeks = [];
            curDate = moment(scope.calendarDate).tz(scope.timezone);
            curDate.add(offset * -1, 'd');
            for (row = _i = 0, _ref = numRows - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; row = 0 <= _ref ? ++_i : --_i) {
              weeks.push([]);
              for (day = _j = 0; _j <= 6; day = ++_j) {
                d = moment(curDate).tz(scope.timezone);
                if (scope.defaultTime) {
                  time = scope.defaultTime.split(':');
                  d.hours(time[0] || 0);
                  d.minutes(time[1] || 0);
                  d.seconds(time[2] || 0);
                }
                selected = scope.ngModel && d && datesAreEqual(d, scope.ngModel);
                today = datesAreEqual(d, moment().tz(scope.timezone));
                
                // Note: rkim - 2015.04.10
                // Pulled style calculation into setDayStyles since we'll want
                // to re-calculate them every time the calendar is shown.
                weeks[row].push({
                  date: d,
                  //selected: selected,
                  //disabled: typeof scope.dateFilter === 'function' ? !scope.dateFilter(d) : false,
                  //other: d.month() !== scope.calendarDate.month(),
                  //today: today
                });
                curDate.add(1, 'd');
              }
            }
            setDayStyles(weeks);
            return scope.weeks = weeks;
          };
          dateToString = function(date, format) {
            return date.format(format);
          };
          stringToDate = function(date) {
            if (typeof date === 'string') {
              return parseDateString(date);
            } else {
              return date;
            }
          };

          // Calculate styles for each day in scope.weeks
          setDayStyles = function(weeks) {
            if (!weeks || !weeks.length)
              return;

            for (var i = 0; i < weeks.length; i++) {
              var w = weeks[i];
              if (!w || !w.length)
                continue;

              for (var j = 0; j < w.length; j++) {
                var d = w[j];
                if (!d || !d.date)
                  continue;

                var date = d.date;
                d.selected = scope.ngModel && datesAreEqual(date, scope.ngModel);
                d.disabled = typeof scope.dateFilter === 'function' ? !scope.dateFilter(date) : false
                d.other = date.month() !== scope.calendarDate.month();
                d.today = datesAreEqual(date, moment().tz(scope.timezone));
              }
            }
          };

          parseDateString = fdQuickMomentDefaults.parseDateFunction;
          datesAreEqual = function(d1, d2, compareTimes) {
            if (compareTimes == null) {
              compareTimes = false;
            }
            if (compareTimes) {
              return d1.unix() === d2.unix();
            } else {
              d1 = stringToDate(d1);
              d2 = stringToDate(d2);
              return d1.year() === d2.year() && d1.month() === d2.month() && d1.date() === d2.date();
            }
          };
          datesAreEqualToMinute = function(d1, d2) {
            if (!(d1 && d2)) {
              return false;
            }
            return d1.year() === d2.year() && d1.month() === d2.month() && d1.date() === d2.date() && d1.hour() === d2.hour() && d1.minute() === d2.minute();
          };

          scope.$watch('ngModel', function(newVal, oldVal) {
            if (newVal !== oldVal) {
              setInputDateFromModel();
              setCalendarDateFromModel();
              if (scope.onChange && !datesAreEqualToMinute(newVal, oldVal)) {
                return scope.onChange();
              }
            }
          });
          scope.$watch('calendarDate', function(newVal, oldVal) {
            if (newVal !== oldVal) {
              return setCalendarRows();
            }
          });
          scope.$watch('calendarShown', function(newVal, oldVal) {
            // Note: rkim - 2014.04.10
            // Recalc day styles whenever the calendar is opened
            if (newVal)
              setDayStyles(scope.weeks);

            var dateInput;
            dateInput = angular.element(element[0].querySelector(".quickmoment-date-input"))[0];
            return dateInput.select();
          });
          scope.mainButtonStr = function() {
            if (scope.ngModel) {
              return scope.ngModel.format(scope.labelFormat);
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
            var changed, hours, minutes;
            if (closeCalendar == null) {
              closeCalendar = true;
            }
            changed = (!scope.ngModel && date) || (scope.ngModel && !date) || (date.unix() !== stringToDate(scope.ngModel).unix());
            if (typeof scope.dateFilter === 'function' && !scope.dateFilter(date)) {
              return false;
            }
            if (scope.disableTimepicker && scope.ngModel) {
              hours = scope.ngModel.hours();
              minutes = scope.ngModel.minutes();
              date = date.hours(hours).minutes(minutes);
            }
            scope.ngModel = date;
            if (closeCalendar) {
              scope.toggleCalendar(false);
            }
            return true;
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
                tmpDate = tmpDateAndTime;
              }
              if (!datesAreEqualToMinute(scope.ngModel, tmpDate)) {
                if (!scope.setDate(tmpDate, false)) {
                  throw 'Invalid Date';
                }
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
          scope.onDateInputTab = function() {
            if (scope.disableTimepicker) {
              scope.toggleCalendar(false);
            }
            return true;
          };
          scope.onTimeInputTab = function() {
            scope.toggleCalendar(false);
            return true;
          };
          scope.nextMonth = function() {
            return scope.calendarDate = moment(scope.calendarDate).tz(scope.timezone).add(1, 'M');
          };
          scope.prevMonth = function() {
            return scope.calendarDate = moment(scope.calendarDate).tz(scope.timezone).subtract(1, 'M');
          };
          scope.clear = function() {
            return scope.setDate(null, true);
          };
          initialize();
          setCalendarRows();
          if (debug) {
            return console.log("quick date scope:", scope);
          }
        },
        template: "<div class='quickmoment'>\n  <a href='' ng-click='toggleCalendar()' class='quickmoment-button' title='{{hoverText}}'><div ng-hide='iconClass' ng-bind-html='buttonIconHtml'></div>{{mainButtonStr()}}</a>\n  <div class='quickmoment-popup' ng-class='{open: calendarShown}'>\n    <a href='' tabindex='-1' class='quickmoment-close' ng-click='toggleCalendar()'><div ng-bind-html='closeButtonHtml'></div></a>\n    <div class='quickmoment-text-inputs'>\n      <div class='quickmoment-input-wrapper' ng-hide='disableDateinput'>\n        <label>Date</label>\n        <input class='quickmoment-date-input' name='inputDate' type='text' ng-model='inputDate' placeholder='1/1/2013' ng-blur=\"setDateFromInput()\" ng-enter=\"setDateFromInput(true)\" ng-class=\"{'quickmoment-error': inputDateErr}\" on-tab='onDateInputTab()'/>\n      </div>\n      <div class='quickmoment-input-wrapper' ng-hide='disableTimepicker'>\n        <label>Time</label>\n        <input class='quickmoment-time-input' name='inputTime' type='text' ng-model='inputTime' placeholder='12:00 PM' ng-blur=\"setDateFromInput(false)\" ng-enter=\"setDateFromInput(true)\" ng-class=\"{'quickmoment-error': inputTimeErr}\" on-tab='onTimeInputTab()'>\n      </div>\n    </div>\n    <div class='quickmoment-calendar-header'>\n      <a href='' class='quickmoment-prev-month quickmoment-action-link' tabindex='-1' ng-click='prevMonth()'><div ng-bind-html='prevLinkHtml'></div></a>\n      <span class='quickmoment-month'>{{calendarDate | moment:'MMMM YYYY'}}</span>\n      <a href='' class='quickmoment-next-month quickmoment-action-link' ng-click='nextMonth()' tabindex='-1' ><div ng-bind-html='nextLinkHtml'></div></a>\n    </div>\n    <table class='quickmoment-calendar'>\n      <thead>\n        <tr>\n          <th ng-repeat='day in dayAbbreviations'>{{day}}</th>\n        </tr>\n      </thead>\n      <tbody>\n        <tr ng-repeat='week in weeks'>\n          <td ng-mousedown='setDate(day.date)' ng-class='{\"other-month\": day.other, \"disabled-date\": day.disabled, \"selected\": day.selected, \"is-today\": day.today}' ng-repeat='day in week'>{{day.date | moment:'D'}}</td>\n        </tr>\n      </tbody>\n    </table>\n    <div class='quickmoment-popup-footer'>\n      <a href='' class='quickmoment-clear' tabindex='-1' ng-hide='disableClearButton' ng-click='clear()'>Clear</a>\n    </div>\n  </div>\n</div>"
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

  app.directive('onTab', function() {
    return {
      restrict: 'A',
      link: function(scope, element, attr) {
        return element.bind('keydown keypress', function(e) {
          if ((e.which === 9) && !e.shiftKey) {
            return scope.$apply(attr.onTab);
          }
        });
      }
    };
  });

  app.filter('moment', function() {
    return function(momentObj, formatStr) {
      return momentObj.format(formatStr);
    };
  });

}).call(this);
