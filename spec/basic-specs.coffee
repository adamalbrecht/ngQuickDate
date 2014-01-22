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
        button = angular.element(element[0].querySelector(".quickdate-button"))
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
        dateTextInput = angular.element(element[0].querySelector(".quickdate-date-input"))
        expect(dateTextInput.val()).toEqual ""

        scope.myDate = ""
        scope.$digest()
        expect(dateTextInput.val()).toEqual ""

        scope.myDate = new Date(2013, 9, 25)
        scope.$digest()
        expect(dateTextInput.val()).toEqual "10/25/2013"

    describe 'Given a datepicker with a string model', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = '2013-09-01'
        element = $compile("<datepicker ng-model='myDate' disable-timepicker='true'/>")(scope)
        scope.$digest()
      )

      it 'allows the date to be updated', ->
        $textInput = $(element).find(".quickdate-date-input")
        $textInput.val('2013-11-15')
        browserTrigger($textInput, 'input')
        expect(element.scope().myDate).toEqual(new Date(Date.parse('2013-09-01')))
        browserTrigger($textInput, 'blur')
        expect(element.scope().myDate).toEqual(new Date(Date.parse('2013-11-15')))

    describe 'Given a basic datepicker', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date(2013, 8, 1) # September 1 (months are 0-indexed)
        element = $compile("<datepicker ng-model='myDate' />")(scope)
        scope.$digest()
      )

      xit 'lets me set the date from the calendar', ->
        console.log 'hello'
        $td = $(element).find('.quickdate-calendar tbody tr:nth-child(1) td:nth-child(5)') # Click the 5th
        console.log("$td.text()", $td.text())
        browserTrigger($td, 'click')
        scope.$apply()
        expect(scope.myDate.getDate()).toEqual(5)

      describe 'After typing a valid date into the date input field', ->
        $textInput = undefined
        beforeEach ->
          $textInput = $(element).find(".quickdate-date-input")
          $textInput.val('11/15/2013')
          browserTrigger($textInput, 'input')

        it 'does not change the ngModel just yet', ->
          expect(element.scope().myDate).toEqual(new Date(2013, 8, 1))

        describe 'and leaving the field (blur event)', ->
          beforeEach ->
            browserTrigger($textInput, 'blur')

          it 'updates ngModel properly', ->
            expect(element.scope().myDate).toEqual(new Date(2013, 10, 15))

          it 'changes the calendar to the proper month', ->
            $monthSpan = $(element).find(".quickdate-month")
            expect($monthSpan.html()).toEqual('November 2013')

          it 'highlights the selected date', ->
            selectedTd = $(element).find('.selected')
            expect(selectedTd.text()).toEqual('15')

        # TODO: Spec not working. 'Enter' keypress not recognized. Seems to be working in demo.
        xdescribe 'and types Enter', ->
          beforeEach ->
            $textInput.trigger($.Event('keypress', { which: 13 }));

          it 'updates ngModel properly', ->
            expect(element.scope().myDate).toEqual(new Date(2013, 10, 15))

      describe 'After typing an invalid date into the date input field', ->
        $textInput = undefined
        beforeEach ->
          $textInput = $(element).find(".quickdate-date-input")
          $textInput.val('1/a/2013')
          browserTrigger($textInput, 'input')
          browserTrigger($textInput, 'blur')

        it 'adds an error class to the input', ->
          expect($textInput.hasClass('ng-quick-date-error')).toBe(true)

        it 'does not change the ngModel', ->
          expect(element.scope().myDate).toEqual(new Date(2013, 8, 1))

        it 'does not change the calendar month', ->
          $monthSpan = $(element).find(".quickdate-month")
          expect($monthSpan.html()).toEqual('September 2013')

    describe 'Given a datepicker set to August 1, 2013', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date(2013, 7, 1) # August 1 (months are 0-indexed)
        element = $compile("<datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope)
        scope.$digest()
      )

      it 'shows the proper text in the button based on the value of the ng-model', ->
        $monthSpan = $(element).find(".quickdate-month")
        expect($monthSpan.html()).toEqual('August 2013')

      it 'has last-month classes on the first 4 boxes in the calendar (because the 1st is a Thursday)', ->
        firstRow = angular.element(element[0].querySelector(".quickdate-calendar tbody tr"))
        for i in [0..3]
          box = angular.element(firstRow.children()[i])
          expect(box.hasClass('other-month')).toEqual(true)

        expect(angular.element(firstRow.children()[4]).text()).toEqual '1'

      it "adds a 'selected' class to the Aug 1 box", ->
        $fifthBoxOfFirstRow = $(element).find(".quickdate-calendar tbody tr:nth-child(1) td:nth-child(5)")
        expect($fifthBoxOfFirstRow.hasClass('selected')).toEqual(true)

      describe 'And I click the Next Month button', ->
        beforeEach ->
          nextButton = $(element).find('.quickdate-next-month')
          browserTrigger(nextButton, 'click');
          scope.$apply()

        it 'shows September', ->
          $monthSpan = $(element).find(".quickdate-month")
          expect($monthSpan.html()).toEqual('September 2013')

        it 'shows the 1st on the first Sunday', ->
          expect($(element).find('.quickdate-calendar tbody tr:first td:first').text()).toEqual '1'

      it 'shows the proper number of rows in the calendar', ->
        scope.myDate = new Date(2013, 5, 1)
        scope.$digest()
        expect($(element).find('.quickdate-calendar tbody tr').length).toEqual(6)
        scope.myDate = new Date(2013, 10, 1)
        scope.$digest()
        expect($(element).find('.quickdate-calendar tbody tr').length).toEqual(5)
        scope.myDate = new Date(2015, 1, 1)
        scope.$digest()
        expect($(element).find('.quickdate-calendar tbody tr').length).toEqual(4)

    describe 'Given a datepicker set to today', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date()
        element = $compile("<datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope)
        scope.$apply()
      )

      it "adds a 'today' class to the today td", ->
        expect($(element).find('.is-today').length).toEqual(1)
        nextButton = $(element).find('.quickdate-next-month')
        browserTrigger(nextButton, 'click')
        browserTrigger(nextButton, 'click') # 2 months later, since today's date could still be shown next month
        scope.$apply()
        expect($(element).find('.is-today').length).toEqual(0)


    describe 'Given a datepicker set to November 1st, 2013 at 1:00pm', ->
      $timeInput = undefined
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date(Date.parse('11/1/2013 1:00 PM'))
        element = $compile("<datepicker ng-model='myDate' />")(scope)
        scope.$apply()
        $timeInput = $(element).find('.quickdate-time-input')
      )
      it 'shows the proper time in the Time input box', ->
        expect($timeInput.val()).toEqual('1:00 PM')

      describe 'and I type in a new valid time', ->
        beforeEach ->
          $timeInput.val('3:00 pm')
          browserTrigger($timeInput, 'input')
          browserTrigger($timeInput, 'blur')
          scope.$apply()

        it 'updates ngModel to reflect this time', ->
          expect(element.scope().myDate).toEqual(new Date(Date.parse('11/1/2013 3:00 PM')))

        it 'updates the input to use the proper time format', ->
          expect($timeInput.val()).toEqual('3:00 PM')

    describe 'Given a basic datepicker set to today', ->
      beforeEach(inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date(Date.parse('11/1/2013 1:00 PM'))
        element = $compile("<datepicker ng-model='myDate' />")(scope)
        scope.$apply()
      ))

      describe 'when you click the clear button', ->
        beforeEach ->
          browserTrigger($(element).find('.quickdate-clear'), 'click')
          scope.$apply()

        it 'should set the model back to null', ->
          expect(element.scope().myDate).toEqual(null)

    describe "Given a datepicker with a valid init-value attribute", ->
      beforeEach(inject(($compile, $rootScope) ->
        scope = $rootScope
        element = $compile("<datepicker ng-model='someDate' init-value='2/1/2014 2:00 PM' />")(scope)
        scope.$apply()
      ))

      it 'should set the model to the specified initial value', ->
        expect(Date.parse(element.scope().someDate)).toEqual(Date.parse('2/1/2014 2:00 PM'))


    describe "Given a datepicker with an 'on-change' method to call", ->
      mySpy = undefined
      beforeEach(inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myVariable = 1
        scope.myOtherVariable = null
        scope.myMethod = (param) ->
          scope.myVariable += 1
          scope.myOtherVariable = param

        scope.myDate = new Date(2013, 5, 10)
        element = $compile("<datepicker ng-model='myDate' on-change='myMethod(\"hello!\")' />")(scope)
        scope.$apply()
      ))

      it 'should not be called initially', ->
        expect(scope.myVariable).toEqual(1)

      # Can't get this spec to work
      describe 'When the date input is changed', ->
        beforeEach ->
          $input = $(element).find('.quickdate-date-input')
          scope.$apply ->
            $input.val('1/5/2013')
            $input.trigger('input')
            $input.trigger('blur')
          browserTrigger($input, 'input')
          browserTrigger($input, 'change')
          browserTrigger($input, 'blur')

        it 'should call the method once', ->
          expect(scope.myVariable).toEqual(2)
          expect(scope.myOtherVariable).toEqual('hello!')

      describe 'When the date input is blurred but not changed', ->
        beforeEach ->
          $input = $(element).find('.quickdate-date-input')
          browserTrigger($input, 'change')
          browserTrigger($input, 'blur')

        it 'should not call the method', ->
          expect(scope.myVariable).toEqual(1)
