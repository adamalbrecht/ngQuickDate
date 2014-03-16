"use strict"

describe "ngQuickDate", ->
  beforeEach angular.mock.module("ngQuickDate")
  describe "datepicker", ->
    element = undefined
    scope = undefined
    describe 'Given that a non-default label format is configured', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('labelFormat', 'yyyy-MM-d')
        null
      ))
      
      describe 'and given a basic datepicker', ->
        beforeEach(angular.mock.inject(($compile, $rootScope) ->
          scope = $rootScope
          scope.myDate = new Date(2013, 7, 1) # August 1 (months are 0-indexed)
          element = $compile("<quick-datepicker ng-model='myDate' />")(scope)
          scope.$digest()
        ))
        it 'should be labeled in the same format as it was configured', ->
          expect($(element).find('.quickdate-button').text()).toEqual('2013-08-1')

    describe 'Given that a non-default date format is configured', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('dateFormat', 'yy-M-d')
        null
      ))
        
      describe 'and given a basic datepicker', ->
        beforeEach angular.mock.inject ($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope, new Date(Date.parse('1/1/2013 1:00 PM')))

        it 'should use the proper format in the date input', ->
          expect($(element).find('.quickdate-date-input').val()).toEqual('13-1-1')
        it 'should be use this date format in the label, but with time included', ->
          expect($(element).find('.quickdate-button').text()).toEqual('13-1-1 1:00 PM')

    describe 'Given that a non-default close button is configured', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('closeButtonHtml', "<i class='icon-remove'></i>")
        null
      ))
      describe 'and given a basic datepicker', ->
        beforeEach angular.mock.inject ($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope, new Date(2013, 10, 1))

        it 'should inject the given html into the close button spot', ->
          expect($(element).find('.quickdate-close').html()).toMatch('icon-remove')

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
          element = buildBasicDatepicker($compile, $rootScope, new Date(2013, 10, 1))

        it 'should inject the given html into the close button spot', ->
          expect($(element).find('.quickdate-next-month').html()).toMatch('icon-arrow-right')
          expect($(element).find('.quickdate-prev-month').html()).toMatch('icon-arrow-left')

    describe 'Given that the button icon html is configured', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('buttonIconHtml', "<i class='icon-time'></i>")
        null
      ))
      describe 'and given a basic datepicker', ->
        beforeEach angular.mock.inject ($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope, new Date(2013, 10, 1))

        it 'should inject the given html into the button', ->
          expect($(element).find('.quickdate-button').html()).toMatch('icon-time')

      describe 'and given a datepicker where icon-class is set inline', ->
        beforeEach angular.mock.inject ($compile, $rootScope) ->
          scope = $rootScope
          scope.myDate = new Date()
          element = $compile("<quick-datepicker icon-class='icon-calendar' ng-model='myDate' />")($rootScope)
          scope.$digest()

        it 'does not display the inline class and not the configured default html in the button', ->
          expect($(element).find('.quickdate-button').html()).toNotMatch('icon-time')
          expect($(element).find('.quickdate-button').html()).toMatch('icon-calendar')

    describe 'Given a default-configured datepicker', ->
      beforeEach(angular.mock.inject(($compile, $rootScope) ->
        element = buildBasicDatepicker($compile, $rootScope)
        null
      ))
      it 'should display the time picker', ->
        expect($(element).find('.ng-quick-date-input-wrapper:last').hasClass('ng-hide')).toEqual(false)

    describe 'Given that it is configured without the timepicker', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('disableTimepicker', true)
        null
      ))
      describe 'and given a basic datepicker', ->
        beforeEach(angular.mock.inject(($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope, new Date(Date.parse('11/1/2013 3:59 pm')))
        ))
        it 'does not show the timepicker input', ->
          expect($(element).find('.quickdate-input-wrapper:last').hasClass('ng-hide')).toEqual(true)
        it 'sets the time to 0:00 on change', ->
          $textInput = $(element).find(".quickdate-date-input")
          $textInput.val('11/15/2013')
          browserTrigger($textInput, 'input')
          browserTrigger($textInput, 'blur')
          expect(element.scope().myDate).toMatch(/00:00:00/)

      describe 'and given a datepicker with timepicker re-enabled', ->
        beforeEach(angular.mock.inject(($compile, $rootScope) ->
          $rootScope.myDate = new Date(2013, 10, 1)
          element = $compile("<quick-datepicker ng-model='myDate' disable-timepicker='false' />")(scope)
          $rootScope.$digest()
        ))
        it 'shows the timepicker input', ->
          expect($(element).find('.quickdate-input-wrapper:last').hasClass('ng-hide')).toNotEqual(true)


    describe 'Given that it is configured with a custom date/time parser function that always returns July 1, 2013', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        alwaysReturnsJulyFirst2013 = (str) -> new Date(2013, 6, 1)
        ngQuickDateDefaultsProvider.set('parseDateFunction', alwaysReturnsJulyFirst2013)
        null
      ))
      describe 'and a basic datepicker', ->
        beforeEach(angular.mock.inject(($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope)
        ))

        describe 'When the date input is changed to 1/1/2014', ->
          beforeEach ->
            $dateInput = $(element).find('.quickdate-date-input')
            $dateInput.val('1/1/2014')
            browserTrigger($dateInput, 'input')
            browserTrigger($dateInput, 'blur')

          it 'Changes the model date to July 1, 2013', ->
            expect(element.scope().myDate).toMatch(/Jul 01 2013/)

    describe 'Given that it is configured with a default placeholder', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('placeholder', 'No Date Chosen')
        null
      ))
      describe 'and a basic datepicker set to nothing', ->
        beforeEach(inject(($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope, '')
        ))

        it 'should show the configured placeholder', ->
          expect($(element).find('.quickdate-button').html()).toMatch('No Date Chosen')

    describe 'Given that it is configured without a clear button', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('disableClearButton', true)
        null
      ))
      describe 'and given a basic datepicker', ->
        beforeEach(inject(($compile, $rootScope) ->
          element = buildBasicDatepicker($compile, $rootScope, new Date())
        ))

        it 'should not have clear button', ->
          expect($(element).find('.quickdate-clear').hasClass('ng-hide')).toEqual(true)

      describe 'and given a datepicker with the clear button re-enabled', ->
        beforeEach(inject(($compile, $rootScope) ->
          scope = $rootScope
          scope.myDate = new Date()
          element = $compile("<quick-datepicker ng-model='myDate' disable-clear-button='false' />")(scope)
          scope.$digest()
        ))

        it 'should have a clear button', ->
          expect($(element).find('.quickdate-clear').hasClass('ng-hide')).toEqual(false)

    xdescribe 'Given that a default time of 1:52 am is configured', ->
      beforeEach(module('ngQuickDate', (ngQuickDateDefaultsProvider) ->
        ngQuickDateDefaultsProvider.set('defaultTime', '01:52')
        null
      ))
      describe 'and given a basic datepicker with a null model', ->
        beforeEach(inject(($compile, $rootScope) ->
          scope.myDate = null
          element = $compile("<quick-datepicker ng-model='myDate' />")(scope)
          scope.$digest()
        ))

        describe 'and the last day of the first week of this month is clicked', ->
          beforeEach ->
            $td = $(element).find('.quickdate-calendar tbody tr:nth-child(1) td:last-child') # Click the 5th
            browserTrigger($td, 'click')
            scope.$apply()
          it 'should set the time input to 1:52 AM', ->
            expect($(element).find('.quickdate-time-input').val()).toEqual('1:52 AM')




buildBasicDatepicker = ($compile, scope, date=new Date(), debug=false) ->
  scope.myDate = date
  if debug
    element = $compile("<quick-datepicker debug='true' ng-model='myDate' />")(scope)
  else
    element = $compile("<quick-datepicker ng-model='myDate' />")(scope)
  scope.$digest()
  element
