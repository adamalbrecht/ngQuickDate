"use strict"

describe "aaDatepickerLib", ->
  beforeEach angular.mock.module("aaDatepickerLib")
  describe "aaDatepicker", ->
    element = undefined
    scope = undefined
    describe 'Given a datepicker element with a placeholder', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        element = $compile("<aa-datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope)
      )

      it 'Should show the proper text in the button based on the value of the ng-model', ->
        scope.myDate = null
        scope.$digest()
        button = angular.element(element[0].querySelector(".aa-datepicker-button"))
        expect(button.text()).toEqual "Choose a Date"

        scope.myDate = ""
        scope.$digest()
        expect(button.text()).toEqual "Choose a Date"

        scope.myDate = new Date(2013, 9, 25)
        scope.$digest()
        expect(button.text()).toEqual "10/25/2013"

      it 'Should show the proper value in the date input based on the value of the ng-model', ->
        scope.myDate = null
        scope.$digest()
        dateTextInput = angular.element(element[0].querySelector(".aa-date-text-input"))
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
        scope.myDate = new Date(2013, 10, 1) # August 1 (months are 0-indexed)
        element = $compile("<aa-datepicker ng-model='myDate' />")(scope)
        scope.$digest()
      )

      it 'Should let me set the date from the calendar', ->
        element.scope().setDate(Date.parse('10/05/2013')) # click on TD for this date
        scope.$apply()
        expect(scope.myDate.getDate()).toEqual(5)

    describe 'Given a datepicker set to August 1, 2013', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date(2013, 7, 1) # August 1 (months are 0-indexed)
        element = $compile("<aa-datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope)
        scope.$digest()
      )

      it 'Should show the proper text in the button based on the value of the ng-model', ->
        monthSpan = angular.element(element[0].querySelector(".aa-month"))
        expect(monthSpan.html()).toEqual('August 2013')

      it 'Should have last-month classes on the first 4 boxes in the calendar (because the 1st is a Thursday)', ->
        firstRow = angular.element(element[0].querySelector(".aa-calendar .week"))
        for i in [0..3]
          box = angular.element(firstRow.children()[i])
          expect(box.hasClass('other-month')).toEqual(true)

        expect(angular.element(firstRow.children()[4]).text()).toEqual '1'

      it "Should add a 'selected' class to the Aug 1 box", ->
        secondBox = angular.element(element[0].querySelector(".aa-calendar tr.week:nth-child(1) td.day:nth-child(5)"))
        expect(secondBox.hasClass('selected')).toEqual(true)


      describe 'And I click the Next Month button', ->
        beforeEach ->
          element.scope().nextMonth()
          scope.$apply()

        it 'Should show September', ->
          monthSpan = angular.element(element[0].querySelector(".aa-month"))
          expect(monthSpan.html()).toEqual('September 2013')

        it 'Should show the 1st on the first Sunday', ->
          expect(angular.element(element[0].querySelector(".aa-calendar .day")).text()).toEqual '1'

      it 'should show the proper number of rows in the calendar', ->
        scope.myDate = Date.parse('6/1/2013')
        scope.$digest()
        expect($(element).find('.aa-calendar .week').length).toEqual(6)
        scope.myDate = Date.parse('11/1/2013')
        scope.$digest()
        expect($(element).find('.aa-calendar .week').length).toEqual(5)
        scope.myDate = Date.parse('2/1/2015')
        scope.$digest()
        expect($(element).find('.aa-calendar .week').length).toEqual(4)

    describe 'Given a datepicker set to today', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date()
        element = $compile("<aa-datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope)
        scope.$digest()
      )

      it "Should add a 'today' class to the today td", ->
        expect($(element).find('.today').length).toEqual(1)
        element.scope().nextMonth()
        scope.$apply()
        expect($(element).find('.today').length).toEqual(0)


