"use strict"

describe "ngQuickDate", ->
  beforeEach angular.mock.module("ngQuickDate")
  describe "datepicker", ->
    element = undefined
    scope = undefined
    describe 'Given a datepicker element with a placeholder', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        element = $compile("<datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope)
      )

      it 'shows the proper text in the button based on the value of the ng-model', ->
        scope.myDate = null
        scope.$digest()
        button = angular.element(element[0].querySelector(".ng-quick-date-button"))
        expect(button.text()).toEqual "Choose a Date"

        scope.myDate = ""
        scope.$digest()
        expect(button.text()).toEqual "Choose a Date"

        scope.myDate = new Date(2013, 9, 25)
        scope.$digest()
        expect(button.text()).toEqual "10/25/2013 12:00 AM"

      it 'shows the proper value in the date input based on the value of the ng-model', ->
        scope.myDate = null
        scope.$digest()
        dateTextInput = angular.element(element[0].querySelector(".ng-qd-date-input"))
        expect(dateTextInput.val()).toEqual ""

        scope.myDate = ""
        scope.$digest()
        expect(dateTextInput.val()).toEqual ""

        scope.myDate = new Date(2013, 9, 25)
        scope.$digest()
        expect(dateTextInput.val()).toEqual "10/25/2013"

    describe 'Given a basic datepicker', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date(2013, 8, 1) # September 1 (months are 0-indexed)
        element = $compile("<datepicker ng-model='myDate' />")(scope)
        scope.$digest()
      )

      it 'lets me set the date from the calendar', ->
        element.scope().setDate(Date.parse('10/05/2013')) # click on TD for this date
        scope.$apply()
        expect(scope.myDate.getDate()).toEqual(5)

      describe 'After typing a valid date into the date input field', ->
        $textInput = undefined
        beforeEach ->
          $textInput = $(element).find(".ng-qd-date-input")
          $textInput.val('11/15/2013')
          browserTrigger($textInput, 'input')

        it 'does not change the ngModel just yet', ->
          expect(element.scope().ngModel).toEqual(Date.parse('09/1/2013'))

        describe 'and leaving the field (blur event)', ->
          beforeEach ->
            browserTrigger($textInput, 'blur')

          it 'updates ngModel properly', ->
            expect(element.scope().ngModel).toEqual(Date.parse('11/15/2013'))

          it 'changes the calendar to the proper month', ->
            $monthSpan = $(element).find(".ng-quick-date-month")
            expect($monthSpan.html()).toEqual('November 2013')

          it 'highlights the selected date', ->
            selectedTd = $(element).find('.selected')
            expect(selectedTd.text()).toEqual('15')

        # TODO: Spec not working. 'Enter' keypress not recognized. Seems to be working in demo.
        xdescribe 'and types Enter', ->
          beforeEach ->
            $textInput.trigger($.Event('keypress', { which: 13 }));
         
          it 'updates ngModel properly', ->
            expect(element.scope().ngModel).toEqual(Date.parse('11/15/2013'))

      describe 'After typing an invalid date into the date input field', ->
        $textInput = undefined
        beforeEach ->
          $textInput = $(element).find(".ng-qd-date-input")
          $textInput.val('1/a/2013')
          browserTrigger($textInput, 'input')
          browserTrigger($textInput, 'blur')

        it 'adds an error class to the input', ->
          expect($textInput.hasClass('ng-quick-date-error')).toBe(true)

        it 'does not change the ngModel', ->
          expect(element.scope().ngModel).toEqual(Date.parse('9/1/2013'))

        it 'does not change the calendar month', ->
          $monthSpan = $(element).find(".ng-quick-date-month")
          expect($monthSpan.html()).toEqual('September 2013')

    describe 'Given a datepicker set to August 1, 2013', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date(2013, 7, 1) # August 1 (months are 0-indexed)
        element = $compile("<datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope)
        scope.$digest()
      )

      it 'shows the proper text in the button based on the value of the ng-model', ->
        $monthSpan = $(element).find(".ng-quick-date-month")
        expect($monthSpan.html()).toEqual('August 2013')

      it 'has last-month classes on the first 4 boxes in the calendar (because the 1st is a Thursday)', ->
        firstRow = angular.element(element[0].querySelector(".ng-quick-date-calendar .week"))
        for i in [0..3]
          box = angular.element(firstRow.children()[i])
          expect(box.hasClass('other-month')).toEqual(true)

        expect(angular.element(firstRow.children()[4]).text()).toEqual '1'

      it "adds a 'selected' class to the Aug 1 box", ->
        $fifthBoxOfFirstRow = $(element).find(".ng-quick-date-calendar tr.week:nth-child(1) td.day:nth-child(5)")
        expect($fifthBoxOfFirstRow.hasClass('selected')).toEqual(true)

      describe 'And I click the Next Month button', ->
        beforeEach ->
          nextButton = $(element).find('.ng-quick-date-next-month')
          browserTrigger(nextButton, 'click');
          scope.$apply()

        it 'shows September', ->
          $monthSpan = $(element).find(".ng-quick-date-month")
          expect($monthSpan.html()).toEqual('September 2013')

        it 'shows the 1st on the first Sunday', ->
          expect(angular.element(element[0].querySelector(".ng-quick-date-calendar .day")).text()).toEqual '1'

      it 'shows the proper number of rows in the calendar', ->
        scope.myDate = Date.parse('6/1/2013')
        scope.$digest()
        expect($(element).find('.ng-quick-date-calendar .week').length).toEqual(6)
        scope.myDate = Date.parse('11/1/2013')
        scope.$digest()
        expect($(element).find('.ng-quick-date-calendar .week').length).toEqual(5)
        scope.myDate = Date.parse('2/1/2015')
        scope.$digest()
        expect($(element).find('.ng-quick-date-calendar .week').length).toEqual(4)

    describe 'Given a datepicker set to today', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date()
        element = $compile("<datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope)
        scope.$apply()
      )

      it "adds a 'today' class to the today td", ->
        expect($(element).find('.today').length).toEqual(1)
        nextButton = $(element).find('.ng-quick-date-next-month')
        browserTrigger(nextButton, 'click')
        browserTrigger(nextButton, 'click') # 2 months later, since today's date could still be shown next month
        scope.$apply()
        expect($(element).find('.today').length).toEqual(0)


    describe 'Given a datepicker set to November 1st, 2013 at 1:00pm', ->
      $timeInput = undefined
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = Date.parse('11/1/2013 1:00pm')
        element = $compile("<datepicker ng-model='myDate' />")(scope)
        scope.$apply()
        $timeInput = $(element).find('.ng-qd-time-input')
      )
      it 'shows the proper time in the Time input box', ->
        expect($timeInput.val()).toEqual('1:00 PM')

      describe 'and I type in a new valid time', ->
        beforeEach ->
          $timeInput.val('3pm')
          browserTrigger($timeInput, 'input')
          browserTrigger($timeInput, 'blur')
          scope.$apply()

        it 'updates ngModel to reflect this time', ->
          expect(element.scope().ngModel).toEqual(Date.parse('11/1/2013 3:00PM'))

        it 'updates the input to use the proper time format', ->
          expect($timeInput.val()).toEqual('3:00 PM')


    describe 'Given that a non-default label format is configured', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('labelFormat', 'yyyy-MM-d')
        null
      ))
      
      describe 'and given a basic datepicker', ->
        beforeEach(angular.mock.inject(($compile, $rootScope) ->
          scope = $rootScope
          scope.myDate = new Date(2013, 7, 1) # August 1 (months are 0-indexed)
          element = $compile("<datepicker ng-model='myDate' />")(scope)
          scope.$digest()
        ))
        it 'should be labeled in the same format as it was configured', ->
          expect($(element).find('.ng-quick-date-button').text()).toEqual('2013-08-1')

    describe 'Given that a non-default date format is configured', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('dateFormat', 'yy-M-d')
        null
      ))
        
      describe 'and given a basic datepicker', ->
        beforeEach angular.mock.inject ($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope, Date.parse('1/1/2013 1:00pm'))

        it 'should use the proper format in the date input', ->
          expect($(element).find('.ng-qd-date-input').val()).toEqual('13-1-1')
        it 'should be use this date format in the label, but with time included', ->
          expect($(element).find('.ng-quick-date-button').text()).toEqual('13-1-1 1:00 PM')

    describe 'Given that a non-default close button is configured', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('closeButtonHtml', "<i class='icon-remove'></i>")
        null
      ))
      describe 'and given a basic datepicker', ->
        beforeEach angular.mock.inject ($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope, Date.parse('11/1/2013'))

        it 'should inject the given html into the close button spot', ->
          expect($(element).find('.ng-qd-close').html()).toMatch('icon-remove')

    describe 'Given that non-default next and previous links are configured', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set({
          nextLinkHtml: "<i class='icon-arrow-right'></i>",
          prevLinkHtml: "<i class='icon-arrow-left'></i>"
        })
        null
      ))
      describe 'and given a basic datepicker', ->
        beforeEach angular.mock.inject ($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope, Date.parse('11/1/2013'))

        it 'should inject the given html into the close button spot', ->
          expect($(element).find('.ng-quick-date-next-month').html()).toMatch('icon-arrow-right')
          expect($(element).find('.ng-quick-date-prev-month').html()).toMatch('icon-arrow-left')

    describe 'Given that the button icon html is configured', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('buttonIconHtml', "<i class='icon-time'></i>")
        null
      ))
      describe 'and given a basic datepicker', ->
        beforeEach angular.mock.inject ($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope, Date.parse('11/1/2013'))

        it 'should inject the given html into the button', ->
          expect($(element).find('.ng-quick-date-button').html()).toMatch('icon-time')

      describe 'and given a datepicker where icon-class is set inline', ->
        beforeEach angular.mock.inject ($compile, $rootScope) ->
          scope = $rootScope
          scope.myDate = new Date()
          element = $compile("<datepicker icon-class='icon-calendar' ng-model='myDate' />")($rootScope)
          scope.$digest()

        it 'should display the inline class and not the configured default html in the button', ->
          expect($(element).find('.ng-quick-date-button').html()).toNotMatch('icon-time')
          expect($(element).find('.ng-quick-date-button').html()).toMatch('icon-calendar')



buildBasicDatepicker = ($compile, scope, date, debug=false) ->
  scope.myDate = date
  if debug
    element = $compile("<datepicker debug='true' ng-model='myDate' />")(scope)
  else
    element = $compile("<datepicker ng-model='myDate' />")(scope)
  scope.$digest()
  element
