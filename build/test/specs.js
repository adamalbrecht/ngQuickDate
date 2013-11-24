(function() {
  "use strict";
  describe("ngQuickDate", function() {
    beforeEach(angular.mock.module("ngQuickDate"));
    return describe("datepicker", function() {
      var element, scope;
      element = void 0;
      scope = void 0;
      describe('Given a datepicker element with a placeholder', function() {
        beforeEach(angular.mock.inject(function($compile, $rootScope) {
          scope = $rootScope;
          return element = $compile("<datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope);
        }));
        it('shows the proper text in the button based on the value of the ng-model', function() {
          var button;
          scope.myDate = null;
          scope.$digest();
          button = angular.element(element[0].querySelector(".quickdate-button"));
          expect(button.text()).toEqual("Choose a Date");
          scope.myDate = "";
          scope.$digest();
          expect(button.text()).toEqual("Choose a Date");
          scope.myDate = new Date(2013, 9, 25);
          scope.$digest();
          return expect(button.text()).toEqual("10/25/2013 12:00 AM");
        });
        return it('shows the proper value in the date input based on the value of the ng-model', function() {
          var dateTextInput;
          scope.myDate = null;
          scope.$digest();
          dateTextInput = angular.element(element[0].querySelector(".quickdate-date-input"));
          expect(dateTextInput.val()).toEqual("");
          scope.myDate = "";
          scope.$digest();
          expect(dateTextInput.val()).toEqual("");
          scope.myDate = new Date(2013, 9, 25);
          scope.$digest();
          return expect(dateTextInput.val()).toEqual("10/25/2013");
        });
      });
      describe('Given a basic datepicker', function() {
        beforeEach(angular.mock.inject(function($compile, $rootScope) {
          scope = $rootScope;
          scope.myDate = new Date(2013, 8, 1);
          element = $compile("<datepicker ng-model='myDate' />")(scope);
          return scope.$digest();
        }));
        it('lets me set the date from the calendar', function() {
          element.scope().setDate(new Date(2013, 9, 5));
          scope.$apply();
          return expect(scope.myDate.getDate()).toEqual(5);
        });
        describe('After typing a valid date into the date input field', function() {
          var $textInput;
          $textInput = void 0;
          beforeEach(function() {
            $textInput = $(element).find(".quickdate-date-input");
            $textInput.val('11/15/2013');
            return browserTrigger($textInput, 'input');
          });
          it('does not change the ngModel just yet', function() {
            return expect(element.scope().ngModel).toEqual(new Date(2013, 8, 1));
          });
          describe('and leaving the field (blur event)', function() {
            beforeEach(function() {
              return browserTrigger($textInput, 'blur');
            });
            it('updates ngModel properly', function() {
              return expect(element.scope().ngModel).toEqual(new Date(2013, 10, 15));
            });
            it('changes the calendar to the proper month', function() {
              var $monthSpan;
              $monthSpan = $(element).find(".quickdate-month");
              return expect($monthSpan.html()).toEqual('November 2013');
            });
            return it('highlights the selected date', function() {
              var selectedTd;
              selectedTd = $(element).find('.selected');
              return expect(selectedTd.text()).toEqual('15');
            });
          });
          return xdescribe('and types Enter', function() {
            beforeEach(function() {
              return $textInput.trigger($.Event('keypress', {
                which: 13
              }));
            });
            return it('updates ngModel properly', function() {
              return expect(element.scope().ngModel).toEqual(new Date(2013, 10, 15));
            });
          });
        });
        return describe('After typing an invalid date into the date input field', function() {
          var $textInput;
          $textInput = void 0;
          beforeEach(function() {
            $textInput = $(element).find(".quickdate-date-input");
            $textInput.val('1/a/2013');
            browserTrigger($textInput, 'input');
            return browserTrigger($textInput, 'blur');
          });
          it('adds an error class to the input', function() {
            return expect($textInput.hasClass('ng-quick-date-error')).toBe(true);
          });
          it('does not change the ngModel', function() {
            return expect(element.scope().ngModel).toEqual(new Date(2013, 8, 1));
          });
          return it('does not change the calendar month', function() {
            var $monthSpan;
            $monthSpan = $(element).find(".quickdate-month");
            return expect($monthSpan.html()).toEqual('September 2013');
          });
        });
      });
      describe('Given a datepicker set to August 1, 2013', function() {
        beforeEach(angular.mock.inject(function($compile, $rootScope) {
          scope = $rootScope;
          scope.myDate = new Date(2013, 7, 1);
          element = $compile("<datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope);
          return scope.$digest();
        }));
        it('shows the proper text in the button based on the value of the ng-model', function() {
          var $monthSpan;
          $monthSpan = $(element).find(".quickdate-month");
          return expect($monthSpan.html()).toEqual('August 2013');
        });
        it('has last-month classes on the first 4 boxes in the calendar (because the 1st is a Thursday)', function() {
          var box, firstRow, i, _i;
          firstRow = angular.element(element[0].querySelector(".quickdate-calendar tbody tr"));
          for (i = _i = 0; _i <= 3; i = ++_i) {
            box = angular.element(firstRow.children()[i]);
            expect(box.hasClass('other-month')).toEqual(true);
          }
          return expect(angular.element(firstRow.children()[4]).text()).toEqual('1');
        });
        it("adds a 'selected' class to the Aug 1 box", function() {
          var $fifthBoxOfFirstRow;
          $fifthBoxOfFirstRow = $(element).find(".quickdate-calendar tbody tr:nth-child(1) td:nth-child(5)");
          return expect($fifthBoxOfFirstRow.hasClass('selected')).toEqual(true);
        });
        describe('And I click the Next Month button', function() {
          beforeEach(function() {
            var nextButton;
            nextButton = $(element).find('.quickdate-next-month');
            browserTrigger(nextButton, 'click');
            return scope.$apply();
          });
          it('shows September', function() {
            var $monthSpan;
            $monthSpan = $(element).find(".quickdate-month");
            return expect($monthSpan.html()).toEqual('September 2013');
          });
          return it('shows the 1st on the first Sunday', function() {
            return expect($(element).find('.quickdate-calendar tbody tr:first td:first').text()).toEqual('1');
          });
        });
        return it('shows the proper number of rows in the calendar', function() {
          scope.myDate = new Date(2013, 5, 1);
          scope.$digest();
          expect($(element).find('.quickdate-calendar tbody tr').length).toEqual(6);
          scope.myDate = new Date(2013, 10, 1);
          scope.$digest();
          expect($(element).find('.quickdate-calendar tbody tr').length).toEqual(5);
          scope.myDate = new Date(2015, 1, 1);
          scope.$digest();
          return expect($(element).find('.quickdate-calendar tbody tr').length).toEqual(4);
        });
      });
      describe('Given a datepicker set to today', function() {
        beforeEach(angular.mock.inject(function($compile, $rootScope) {
          scope = $rootScope;
          scope.myDate = new Date();
          element = $compile("<datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope);
          return scope.$apply();
        }));
        return it("adds a 'today' class to the today td", function() {
          var nextButton;
          expect($(element).find('.is-today').length).toEqual(1);
          nextButton = $(element).find('.quickdate-next-month');
          browserTrigger(nextButton, 'click');
          browserTrigger(nextButton, 'click');
          scope.$apply();
          return expect($(element).find('.is-today').length).toEqual(0);
        });
      });
      describe('Given a datepicker set to November 1st, 2013 at 1:00pm', function() {
        var $timeInput;
        $timeInput = void 0;
        beforeEach(angular.mock.inject(function($compile, $rootScope) {
          scope = $rootScope;
          scope.myDate = new Date(Date.parse('11/1/2013 1:00 PM'));
          element = $compile("<datepicker ng-model='myDate' />")(scope);
          scope.$apply();
          return $timeInput = $(element).find('.quickdate-time-input');
        }));
        it('shows the proper time in the Time input box', function() {
          return expect($timeInput.val()).toEqual('1:00 PM');
        });
        return describe('and I type in a new valid time', function() {
          beforeEach(function() {
            $timeInput.val('3:00 pm');
            browserTrigger($timeInput, 'input');
            browserTrigger($timeInput, 'blur');
            return scope.$apply();
          });
          it('updates ngModel to reflect this time', function() {
            return expect(element.scope().ngModel).toEqual(new Date(Date.parse('11/1/2013 3:00 PM')));
          });
          return it('updates the input to use the proper time format', function() {
            return expect($timeInput.val()).toEqual('3:00 PM');
          });
        });
      });
      return describe('Given a basic datepicker set to today', function() {
        beforeEach(inject(function($compile, $rootScope) {
          scope = $rootScope;
          return element = buildBasicDatepicker($compile, scope, new Date());
        }));
        return describe('when you click the clear button', function() {
          beforeEach(function() {
            browserTrigger($(element).find('.quickdate-clear'), 'click');
            return scope.$apply();
          });
          return it('should set the model back to null', function() {
            return expect(element.scope().ngModel).toEqual(null);
          });
        });
      });
    });
  });

}).call(this);

(function() {
  "use strict";
  var buildBasicDatepicker;

  describe("ngQuickDate", function() {
    beforeEach(angular.mock.module("ngQuickDate"));
    return describe("datepicker", function() {
      var element, scope;
      element = void 0;
      scope = void 0;
      describe('Given that a non-default label format is configured', function() {
        beforeEach(module('ngQuickDate', function(ngQuickDateDefaultsProvider) {
          ngQuickDateDefaultsProvider.set('labelFormat', 'yyyy-MM-d');
          return null;
        }));
        return describe('and given a basic datepicker', function() {
          beforeEach(angular.mock.inject(function($compile, $rootScope) {
            scope = $rootScope;
            scope.myDate = new Date(2013, 7, 1);
            element = $compile("<datepicker ng-model='myDate' />")(scope);
            return scope.$digest();
          }));
          return it('should be labeled in the same format as it was configured', function() {
            return expect($(element).find('.quickdate-button').text()).toEqual('2013-08-1');
          });
        });
      });
      describe('Given that a non-default date format is configured', function() {
        beforeEach(module('ngQuickDate', function(ngQuickDateDefaultsProvider) {
          ngQuickDateDefaultsProvider.set('dateFormat', 'yy-M-d');
          return null;
        }));
        return describe('and given a basic datepicker', function() {
          beforeEach(angular.mock.inject(function($compile, $rootScope) {
            return element = buildBasicDatepicker($compile, $rootScope, new Date(Date.parse('1/1/2013 1:00 PM')));
          }));
          it('should use the proper format in the date input', function() {
            return expect($(element).find('.quickdate-date-input').val()).toEqual('13-1-1');
          });
          return it('should be use this date format in the label, but with time included', function() {
            return expect($(element).find('.quickdate-button').text()).toEqual('13-1-1 1:00 PM');
          });
        });
      });
      describe('Given that a non-default close button is configured', function() {
        beforeEach(module('ngQuickDate', function(ngQuickDateDefaultsProvider) {
          ngQuickDateDefaultsProvider.set('closeButtonHtml', "<i class='icon-remove'></i>");
          return null;
        }));
        return describe('and given a basic datepicker', function() {
          beforeEach(angular.mock.inject(function($compile, $rootScope) {
            return element = buildBasicDatepicker($compile, $rootScope, new Date(2013, 10, 1));
          }));
          return it('should inject the given html into the close button spot', function() {
            return expect($(element).find('.quickdate-close').html()).toMatch('icon-remove');
          });
        });
      });
      describe('Given that non-default next and previous links are configured', function() {
        beforeEach(module('ngQuickDate', function(ngQuickDateDefaultsProvider) {
          ngQuickDateDefaultsProvider.set({
            nextLinkHtml: "<i class='icon-arrow-right'></i>",
            prevLinkHtml: "<i class='icon-arrow-left'></i>"
          });
          return null;
        }));
        return describe('and given a basic datepicker', function() {
          beforeEach(angular.mock.inject(function($compile, $rootScope) {
            return element = buildBasicDatepicker($compile, $rootScope, new Date(2013, 10, 1));
          }));
          return it('should inject the given html into the close button spot', function() {
            expect($(element).find('.quickdate-next-month').html()).toMatch('icon-arrow-right');
            return expect($(element).find('.quickdate-prev-month').html()).toMatch('icon-arrow-left');
          });
        });
      });
      describe('Given that the button icon html is configured', function() {
        beforeEach(module('ngQuickDate', function(ngQuickDateDefaultsProvider) {
          ngQuickDateDefaultsProvider.set('buttonIconHtml', "<i class='icon-time'></i>");
          return null;
        }));
        describe('and given a basic datepicker', function() {
          beforeEach(angular.mock.inject(function($compile, $rootScope) {
            return element = buildBasicDatepicker($compile, $rootScope, new Date(2013, 10, 1));
          }));
          return it('should inject the given html into the button', function() {
            return expect($(element).find('.quickdate-button').html()).toMatch('icon-time');
          });
        });
        return describe('and given a datepicker where icon-class is set inline', function() {
          beforeEach(angular.mock.inject(function($compile, $rootScope) {
            scope = $rootScope;
            scope.myDate = new Date();
            element = $compile("<datepicker icon-class='icon-calendar' ng-model='myDate' />")($rootScope);
            return scope.$digest();
          }));
          return it('does not display the inline class and not the configured default html in the button', function() {
            expect($(element).find('.quickdate-button').html()).toNotMatch('icon-time');
            return expect($(element).find('.quickdate-button').html()).toMatch('icon-calendar');
          });
        });
      });
      describe('Given a default-configured datepicker', function() {
        beforeEach(angular.mock.inject(function($compile, $rootScope) {
          element = buildBasicDatepicker($compile, $rootScope);
          return null;
        }));
        return it('should display the time picker', function() {
          return expect($(element).find('.ng-quick-date-input-wrapper:last').css('display')).toNotEqual('none');
        });
      });
      describe('Given that it is configured without the timepicker', function() {
        beforeEach(module('ngQuickDate', function(ngQuickDateDefaultsProvider) {
          ngQuickDateDefaultsProvider.set('disableTimepicker', true);
          return null;
        }));
        describe('and given a basic datepicker', function() {
          beforeEach(angular.mock.inject(function($compile, $rootScope) {
            return element = buildBasicDatepicker($compile, $rootScope, new Date(Date.parse('11/1/2013 3:59 pm')));
          }));
          it('does not show the timepicker input', function() {
            return expect($(element).find('.quickdate-input-wrapper:last').css('display')).toEqual('none');
          });
          return it('sets the time to 0:00 on change', function() {
            var $textInput;
            $textInput = $(element).find(".quickdate-date-input");
            $textInput.val('11/15/2013');
            browserTrigger($textInput, 'input');
            browserTrigger($textInput, 'blur');
            return expect(element.scope().ngModel).toMatch(/00:00:00/);
          });
        });
        return describe('and given a datepicker with timepicker re-enabled', function() {
          beforeEach(angular.mock.inject(function($compile, $rootScope) {
            $rootScope.myDate = new Date(2013, 10, 1);
            element = $compile("<datepicker ng-model='myDate' disable-timepicker='false' />")(scope);
            return $rootScope.$digest();
          }));
          return it('shows the timepicker input', function() {
            return expect($(element).find('.quickdate-input-wrapper:last').css('display')).toNotEqual('none');
          });
        });
      });
      describe('Given that it is configured with a custom date/time parser function that always returns July 1, 2013', function() {
        beforeEach(module('ngQuickDate', function(ngQuickDateDefaultsProvider) {
          var alwaysReturnsJulyFirst2013;
          alwaysReturnsJulyFirst2013 = function(str) {
            return new Date(2013, 6, 1);
          };
          ngQuickDateDefaultsProvider.set('parseDateFunction', alwaysReturnsJulyFirst2013);
          return null;
        }));
        return describe('and a basic datepicker', function() {
          beforeEach(angular.mock.inject(function($compile, $rootScope) {
            return element = buildBasicDatepicker($compile, $rootScope);
          }));
          return describe('When the date input is changed to 1/1/2014', function() {
            beforeEach(function() {
              var $dateInput;
              $dateInput = $(element).find('.quickdate-date-input');
              $dateInput.val('1/1/2014');
              browserTrigger($dateInput, 'input');
              return browserTrigger($dateInput, 'blur');
            });
            return it('Changes the model date to July 1, 2013', function() {
              return expect(element.scope().ngModel).toMatch(/Jul 01 2013/);
            });
          });
        });
      });
      describe('Given that it is configured with a default placeholder', function() {
        beforeEach(module('ngQuickDate', function(ngQuickDateDefaultsProvider) {
          ngQuickDateDefaultsProvider.set('placeholder', 'No Date Chosen');
          return null;
        }));
        return describe('and a basic datepicker set to nothing', function() {
          beforeEach(inject(function($compile, $rootScope) {
            return element = buildBasicDatepicker($compile, $rootScope, '');
          }));
          return it('should show the configured placeholder', function() {
            return expect($(element).find('.quickdate-button').html()).toMatch('No Date Chosen');
          });
        });
      });
      return describe('Given that it is configured without a clear button', function() {
        beforeEach(module('ngQuickDate', function(ngQuickDateDefaultsProvider) {
          ngQuickDateDefaultsProvider.set('disableClearButton', true);
          return null;
        }));
        describe('and given a basic datepicker', function() {
          beforeEach(inject(function($compile, $rootScope) {
            return element = buildBasicDatepicker($compile, $rootScope, new Date());
          }));
          return it('should not have clear button', function() {
            return expect($(element).find('.quickdate-clear').css('display')).toEqual('none');
          });
        });
        return describe('and given a datepicker with the clear button re-enabled', function() {
          beforeEach(inject(function($compile, $rootScope) {
            scope = $rootScope;
            scope.myDate = new Date();
            element = $compile("<datepicker ng-model='myDate' disable-clear-button='false' />")(scope);
            return scope.$digest();
          }));
          return it('should have a clear button', function() {
            return expect($(element).find('.quickdate-clear').css('display')).toNotEqual('none');
          });
        });
      });
    });
  });

  buildBasicDatepicker = function($compile, scope, date, debug) {
    var element;
    if (date == null) {
      date = new Date();
    }
    if (debug == null) {
      debug = false;
    }
    scope.myDate = date;
    if (debug) {
      element = $compile("<datepicker debug='true' ng-model='myDate' />")(scope);
    } else {
      element = $compile("<datepicker ng-model='myDate' />")(scope);
    }
    scope.$digest();
    return element;
  };

}).call(this);
