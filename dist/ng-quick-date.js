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
        closeButtonHtml: '&times;',
        nextLinkHtml: 'Next &rarr;',
        prevLinkHtml: '&larr; Prev',
        disableTimepicker: false,
        disableClearButton: false,
        clearButtonText: 'Clear',
        defaultTime: null,
        dayAbbreviations: ["Su", "M", "Tu", "W", "Th", "F", "Sa"],
        dateFilter: null,
        parseDateFunction: function(str) {
          var getDateFromFormat, scope, seconds;
          getDateFromFormat = function(val, format) {
            var ampm, c, date, day_name, hh, i, i_format, i_val, mm, month, month_name, newdate, now, ss, token, token2, x, y, year, _getInt, _isInteger;
            _isInteger = function(val) {
              var digits, i;
              digits = "1234567890";
              i = 0;
              while (i < val.length) {
                if (digits.indexOf(val.charAt(i)) === -1) {
                  return false;
                }
                i++;
              }
              return true;
            };
            _getInt = function(str, i, minlength, maxlength) {
              var token, x;
              x = maxlength;
              while (x >= minlength) {
                token = str.substring(i, i + x);
                if (token.length < minlength) {
                  return null;
                }
                if (_isInteger(token)) {
                  return token;
                }
                x--;
              }
              return null;
            };
            val = val + "";
            format = format + "";
            i_val = 0;
            i_format = 0;
            c = "";
            token = "";
            token2 = "";
            x = void 0;
            y = void 0;
            now = new Date();
            year = now.getYear();
            month = now.getMonth() + 1;
            date = 1;
            hh = now.getHours();
            mm = now.getMinutes();
            ss = now.getSeconds();
            ampm = "";
            while (i_format < format.length) {
              c = format.charAt(i_format);
              token = "";
              while ((format.charAt(i_format) === c) && (i_format < format.length)) {
                token += format.charAt(i_format++);
              }
              if (token === "yyyy" || token === "yy" || token === "y") {
                if (token === "yyyy") {
                  x = 4;
                  y = 4;
                }
                if (token === "yy") {
                  x = 2;
                  y = 2;
                }
                if (token === "y") {
                  x = 2;
                  y = 4;
                }
                year = _getInt(val, i_val, x, y);
                if (year == null) {
                  return 0;
                }
                i_val += year.length;
                if (year.length === 2) {
                  if (year > 70) {
                    year = 1900 + (year - 0);
                  } else {
                    year = 2000 + (year - 0);
                  }
                }
              } else if (token === "MMM" || token === "NNN") {
                month = 0;
                i = 0;
                while (i < MONTH_NAMES.length) {
                  month_name = MONTH_NAMES[i];
                  if (val.substring(i_val, i_val + month_name.length).toLowerCase() === month_name.toLowerCase()) {
                    if (token === "MMM" || (token === "NNN" && i > 11)) {
                      month = i + 1;
                      if (month > 12) {
                        month -= 12;
                      }
                      i_val += month_name.length;
                      break;
                    }
                  }
                  i++;
                }
                if ((month < 1) || (month > 12)) {
                  return 0;
                }
              } else if (token === "EE" || token === "E") {
                i = 0;
                while (i < DAY_NAMES.length) {
                  day_name = DAY_NAMES[i];
                  if (val.substring(i_val, i_val + day_name.length).toLowerCase() === day_name.toLowerCase()) {
                    i_val += day_name.length;
                    break;
                  }
                  i++;
                }
              } else if (token === "MM" || token === "M") {
                month = _getInt(val, i_val, token.length, 2);
                if ((month == null) || (month < 1) || (month > 12)) {
                  return 0;
                }
                i_val += month.length;
              } else if (token === "dd" || token === "d") {
                date = _getInt(val, i_val, token.length, 2);
                if ((date == null) || (date < 1) || (date > 31)) {
                  return 0;
                }
                i_val += date.length;
              } else if (token === "hh" || token === "h") {
                hh = _getInt(val, i_val, token.length, 2);
                if ((hh == null) || (hh < 1) || (hh > 12)) {
                  return 0;
                }
                i_val += hh.length;
              } else if (token === "HH" || token === "H") {
                hh = _getInt(val, i_val, token.length, 2);
                if ((hh == null) || (hh < 0) || (hh > 23)) {
                  return 0;
                }
                i_val += hh.length;
              } else if (token === "KK" || token === "K") {
                hh = _getInt(val, i_val, token.length, 2);
                if ((hh == null) || (hh < 0) || (hh > 11)) {
                  return 0;
                }
                i_val += hh.length;
              } else if (token === "kk" || token === "k") {
                hh = _getInt(val, i_val, token.length, 2);
                if ((hh == null) || (hh < 1) || (hh > 24)) {
                  return 0;
                }
                i_val += hh.length;
                hh--;
              } else if (token === "mm" || token === "m") {
                mm = _getInt(val, i_val, token.length, 2);
                if ((mm == null) || (mm < 0) || (mm > 59)) {
                  return 0;
                }
                i_val += mm.length;
              } else if (token === "ss" || token === "s") {
                ss = _getInt(val, i_val, token.length, 2);
                if ((ss == null) || (ss < 0) || (ss > 59)) {
                  return 0;
                }
                i_val += ss.length;
              } else if (token === "a") {
                if (val.substring(i_val, i_val + 2).toLowerCase() === "am") {
                  ampm = "AM";
                } else if (val.substring(i_val, i_val + 2).toLowerCase() === "pm") {
                  ampm = "PM";
                } else {
                  return 0;
                }
                i_val += 2;
              } else {
                if (val.substring(i_val, i_val + token.length) !== token) {
                  return 0;
                } else {
                  i_val += token.length;
                }
              }
            }
            if (i_val !== val.length) {
              return 0;
            }
            if (month === 2) {
              if (((year % 4 === 0) && (year % 100 !== 0)) || (year % 400 === 0)) {
                if (date > 29) {
                  return 0;
                }
              } else {
                if (date > 28) {
                  return 0;
                }
              }
            }
            if ((month === 4) || (month === 6) || (month === 9) || (month === 11) ? date > 30 : void 0) {
              return 0;
            }
            if (hh < 12 && ampm === "PM") {
              hh = hh - 0 + 12;
            } else {
              if (hh > 11 && ampm === "AM") {
                hh -= 12;
              }
            }
            newdate = new Date(year, month - 1, date, hh, mm, ss);
            return newdate.getTime();
          };
          scope = this;
          seconds = getDateFromFormat(str, scope.labelFormat) || Date.parse(str);
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

  app.directive("quickDatepicker", [
    'ngQuickDateDefaults', '$filter', '$sce', function(ngQuickDateDefaults, $filter, $sce) {
      return {
        restrict: "E",
        require: "?ngModel",
        scope: {
          dateFilter: '=?',
          onChange: "&",
          required: '@'
        },
        replace: true,
        link: function(scope, element, attrs, ngModelCtrl) {
          var dateToString, datepickerClicked, datesAreEqual, datesAreEqualToMinute, getDaysInMonth, initialize, parseDateString, refreshView, setCalendarDate, setConfigOptions, setInputFieldValues, setupCalendarView, stringToDate;
          initialize = function() {
            setConfigOptions();
            scope.toggleCalendar(false);
            scope.weeks = [];
            scope.inputDate = null;
            scope.inputTime = null;
            scope.invalid = true;
            if (typeof attrs.initValue === 'string') {
              ngModelCtrl.$setViewValue(attrs.initValue);
            }
            setCalendarDate();
            return refreshView();
          };
          setConfigOptions = function() {
            var key, value;
            for (key in ngQuickDateDefaults) {
              value = ngQuickDateDefaults[key];
              if (key.match(/[Hh]tml/)) {
                scope[key] = $sce.trustAsHtml(ngQuickDateDefaults[key] || "");
              } else if (!scope[key] && attrs[key]) {
                scope[key] = attrs[key];
              } else if (!scope[key]) {
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
            if (scope.calendarShown && !datepickerClicked) {
              scope.toggleCalendar(false);
              scope.$apply();
            }
            return datepickerClicked = false;
          });
          angular.element(element[0])[0].addEventListener('click', function(event) {
            return datepickerClicked = true;
          });
          refreshView = function() {
            var date;
            date = ngModelCtrl.$modelValue ? parseDateString(ngModelCtrl.$modelValue) : null;
            setupCalendarView();
            setInputFieldValues(date);
            scope.mainButtonStr = date ? $filter('date')(date, scope.labelFormat) : scope.placeholder;
            return scope.invalid = ngModelCtrl.$invalid;
          };
          setInputFieldValues = function(val) {
            if (val != null) {
              scope.inputDate = $filter('date')(val, scope.dateFormat);
              return scope.inputTime = $filter('date')(val, scope.timeFormat);
            } else {
              scope.inputDate = null;
              return scope.inputTime = null;
            }
          };
          setCalendarDate = function(val) {
            var d;
            if (val == null) {
              val = null;
            }
            d = val != null ? new Date(val) : new Date();
            if (d.toString() === "Invalid Date") {
              d = new Date();
            }
            d.setDate(1);
            return scope.calendarDate = new Date(d);
          };
          setupCalendarView = function() {
            var curDate, d, day, daysInMonth, numRows, offset, row, selected, time, today, weeks, _i, _j, _ref;
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
                if (scope.defaultTime) {
                  time = scope.defaultTime.split(':');
                  d.setHours(time[0] || 0);
                  d.setMinutes(time[1] || 0);
                  d.setSeconds(time[2] || 0);
                }
                selected = ngModelCtrl.$modelValue && d && datesAreEqual(d, ngModelCtrl.$modelValue);
                today = datesAreEqual(d, new Date());
                weeks[row].push({
                  date: d,
                  selected: selected,
                  disabled: typeof scope.dateFilter === 'function' ? !scope.dateFilter(d) : false,
                  other: d.getMonth() !== scope.calendarDate.getMonth(),
                  today: today
                });
                curDate.setDate(curDate.getDate() + 1);
              }
            }
            return scope.weeks = weeks;
          };
          ngModelCtrl.$parsers.push(function(viewVal) {
            if (scope.required && (viewVal == null)) {
              ngModelCtrl.$setValidity('required', false);
              return null;
            } else if (angular.isDate(viewVal)) {
              ngModelCtrl.$setValidity('required', true);
              return viewVal;
            } else if (angular.isString(viewVal)) {
              ngModelCtrl.$setValidity('required', true);
              return scope.parseDateFunction(viewVal);
            } else {
              return null;
            }
          });
          ngModelCtrl.$formatters.push(function(modelVal) {
            if (angular.isDate(modelVal)) {
              return modelVal;
            } else if (angular.isString(modelVal)) {
              return scope.parseDateFunction(modelVal);
            } else {
              return void 0;
            }
          });
          dateToString = function(date, format) {
            return $filter('date')(date, format);
          };
          stringToDate = function(date) {
            if (typeof date === 'string') {
              return parseDateString(date);
            } else {
              return date;
            }
          };
          parseDateString = function() {
            return ngQuickDateDefaults.parseDateFunction.apply(scope, arguments);
          };
          datesAreEqual = function(d1, d2, compareTimes) {
            if (compareTimes == null) {
              compareTimes = false;
            }
            if (compareTimes) {
              return (d1 - d2) === 0;
            } else {
              d1 = stringToDate(d1);
              d2 = stringToDate(d2);
              return d1 && d2 && (d1.getYear() === d2.getYear()) && (d1.getMonth() === d2.getMonth()) && (d1.getDate() === d2.getDate());
            }
          };
          datesAreEqualToMinute = function(d1, d2) {
            if (!(d1 && d2)) {
              return false;
            }
            return parseInt(d1.getTime() / 60000) === parseInt(d2.getTime() / 60000);
          };
          getDaysInMonth = function(year, month) {
            return [31, ((year % 4 === 0 && year % 100 !== 0) || year % 400 === 0 ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
          };
          ngModelCtrl.$render = function() {
            setCalendarDate(ngModelCtrl.$viewValue);
            return refreshView();
          };
          ngModelCtrl.$viewChangeListeners.unshift(function() {
            setCalendarDate(ngModelCtrl.$viewValue);
            refreshView();
            if (scope.onChange) {
              return scope.onChange();
            }
          });
          scope.$watch('calendarShown', function(newVal, oldVal) {
            var dateInput;
            if (newVal) {
              dateInput = angular.element(element[0].querySelector(".quickdate-date-input"))[0];
              return dateInput.select();
            }
          });
          scope.toggleCalendar = function(show) {
            if (isFinite(show)) {
              return scope.calendarShown = show;
            } else {
              return scope.calendarShown = !scope.calendarShown;
            }
          };
          scope.selectDate = function(date, closeCalendar) {
            var changed;
            if (closeCalendar == null) {
              closeCalendar = true;
            }
            changed = (!ngModelCtrl.$viewValue && date) || (ngModelCtrl.$viewValue && !date) || ((date && ngModelCtrl.$viewValue) && (date.getTime() !== ngModelCtrl.$viewValue.getTime()));
            if (typeof scope.dateFilter === 'function' && !scope.dateFilter(date)) {
              return false;
            }
            ngModelCtrl.$setViewValue(date);
            if (closeCalendar) {
              scope.toggleCalendar(false);
            }
            return true;
          };
          scope.selectDateFromInput = function(closeCalendar) {
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
              if (!datesAreEqualToMinute(ngModelCtrl.$viewValue, tmpDate)) {
                if (!scope.selectDate(tmpDate, false)) {
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
            setCalendarDate(new Date(new Date(scope.calendarDate).setMonth(scope.calendarDate.getMonth() + 1)));
            return refreshView();
          };
          scope.prevMonth = function() {
            setCalendarDate(new Date(new Date(scope.calendarDate).setMonth(scope.calendarDate.getMonth() - 1)));
            return refreshView();
          };
          scope.clear = function() {
            return scope.selectDate(null, true);
          };
          return initialize();
        },
        template: "<div class='quickdate'>\n  <a href='' ng-click='toggleCalendar()' class='quickdate-button' title='{{hoverText}}'><div ng-hide='iconClass' ng-bind-html='buttonIconHtml'></div>{{mainButtonStr}}</a>\n  <div class='quickdate-popup' ng-class='{open: calendarShown}'>\n    <a href='' tabindex='-1' class='quickdate-close' ng-click='toggleCalendar()'><div ng-bind-html='closeButtonHtml'></div></a>\n    <div class='quickdate-text-inputs'>\n      <div class='quickdate-input-wrapper'>\n        <label>Date</label>\n        <input class='quickdate-date-input' ng-class=\"{'ng-invalid': inputDateErr}\" name='inputDate' type='text' ng-model='inputDate' placeholder='1/1/2013' ng-enter=\"selectDateFromInput(true)\" ng-blur=\"selectDateFromInput(false)\" on-tab='onDateInputTab()' />\n      </div>\n      <div class='quickdate-input-wrapper' ng-hide='disableTimepicker'>\n        <label>Time</label>\n        <input class='quickdate-time-input' ng-class=\"{'ng-invalid': inputTimeErr}\" name='inputTime' type='text' ng-model='inputTime' placeholder='12:00 PM' ng-enter=\"selectDateFromInput(true)\" ng-blur=\"selectDateFromInput(false)\" on-tab='onTimeInputTab()'>\n      </div>\n    </div>\n    <div class='quickdate-calendar-header'>\n      <a href='' class='quickdate-prev-month quickdate-action-link' tabindex='-1' ng-click='prevMonth()'><div ng-bind-html='prevLinkHtml'></div></a>\n      <span class='quickdate-month'>{{calendarDate | date:'MMMM yyyy'}}</span>\n      <a href='' class='quickdate-next-month quickdate-action-link' ng-click='nextMonth()' tabindex='-1' ><div ng-bind-html='nextLinkHtml'></div></a>\n    </div>\n    <table class='quickdate-calendar'>\n      <thead>\n        <tr>\n          <th ng-repeat='day in dayAbbreviations'>{{day}}</th>\n        </tr>\n      </thead>\n      <tbody>\n        <tr ng-repeat='week in weeks'>\n          <td ng-mousedown='selectDate(day.date, true, true)' ng-click='$event.preventDefault()' ng-class='{\"other-month\": day.other, \"disabled-date\": day.disabled, \"selected\": day.selected, \"is-today\": day.today}' ng-repeat='day in week'>{{day.date | date:'d'}}</td>\n        </tr>\n      </tbody>\n    </table>\n    <div class='quickdate-popup-footer'>\n      <a href='' class='quickdate-clear' tabindex='-1' ng-hide='disableClearButton' ng-click='clear()'>{{ clearButtonText }}</a>\n    </div>\n  </div>\n</div>"
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

}).call(this);
