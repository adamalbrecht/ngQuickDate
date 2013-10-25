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

    describe 'Given a datepicker set to August 1, 2013', ->
      beforeEach angular.mock.inject(($compile, $rootScope) ->
        scope = $rootScope
        scope.myDate = new Date(2013, 7, 1) # August 1 (months are 0-indexed)
        element = $compile("<aa-datepicker placeholder='Choose a Date' ng-model='myDate' />")(scope)
        scope.$digest()
      )

      it 'Should show the proper text in the button based on the value of the ng-model', ->
        monthSpan = angular.element(element[0].querySelector(".aa-month"))
        expect(monthSpan.html()).toEqual('August')

      it 'Should have blank entries for the first 4 boxes in the calendar (because the 1st is a Thursday)', ->
        firstRow = angular.element(element[0].querySelector(".aa-calendar .week"))
        for i in [0..3]
          expect(angular.element(firstRow.children()[i]).text()).toEqual ''

        expect(angular.element(firstRow.children()[4]).text()).toEqual '1'

