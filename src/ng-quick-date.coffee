#
# ngQuickDate
# by Adam Albrecht
# http://adamalbrecht.com
#
# Source Code: https://github.com/adamalbrecht/ngQuickDate
#
# Compatible with Angular 1.2.0+
#

app = angular.module("ngQuickDate", [])

app.provider "ngQuickDateDefaults", ->
  {
    options: {
      dateFormat: 'M/d/yyyy'
      timeFormat: 'h:mm a'
      labelFormat: null
      placeholder: 'Click to Set Date'
      hoverText: null
      buttonIconHtml: null
      closeButtonHtml: '&times;'
      nextLinkHtml: 'Next &rarr;'
      prevLinkHtml: '&larr; Prev'
      disableTimepicker: false
      disableClearButton: false
      defaultTime: null
      dayAbbreviations: ["Su", "M", "Tu", "W", "Th", "F", "Sa"],
      dateFilter: null
      parseDateFunction: (str) ->
        seconds = Date.parse(str)
        if isNaN(seconds)
          return null
        else
          new Date(seconds)
    }
    $get: ->
      @options

    set: (keyOrHash, value) ->
      if typeof(keyOrHash) == 'object'
        for k, v of keyOrHash
          @options[k] = v
      else
        @options[keyOrHash] = value
  }

app.directive "quickDatepicker", ['ngQuickDateDefaults', '$filter', '$sce', (ngQuickDateDefaults, $filter, $sce) ->
  restrict: "E"
  require: "?ngModel"
  scope:
    dateFilter: '=?'
    onChange: "&"
    required: '@'

  replace: true
  link: (scope, element, attrs, ngModelCtrl) ->
    # INITIALIZE VARIABLES AND CONFIGURATION
    # ================================
    initialize = ->
      setConfigOptions() # Setup configuration variables
      scope.toggleCalendar(false) # Make sure it is closed initially
      scope.weeks = [] # Nested Array of visible weeks / days in the popup
      scope.inputDate = null # Date inputted into the date text input field
      scope.inputTime = null # Time inputted into the time text input field
      scope.invalid = true
      if typeof(attrs.initValue) == 'string'
        ngModelCtrl.$setViewValue(attrs.initValue)
      setCalendarDate()
      refreshView()

    # Copy various configuration options from the default configuration to scope
    setConfigOptions = ->
      for key, value of ngQuickDateDefaults
        if key.match(/[Hh]tml/)
          scope[key] = $sce.trustAsHtml(ngQuickDateDefaults[key] || "")
        else if !scope[key] && attrs[key]
          scope[key] = attrs[key]
        else if !scope[key]
          scope[key] = ngQuickDateDefaults[key]
      if !scope.labelFormat
        scope.labelFormat = scope.dateFormat
        unless scope.disableTimepicker
          scope.labelFormat += " " + scope.timeFormat
      if attrs.iconClass && attrs.iconClass.length
        scope.buttonIconHtml = $sce.trustAsHtml("<i ng-show='iconClass' class='#{attrs.iconClass}'></i>")

    # VIEW SETUP
    # ================================

    # This code listens for clicks both on the entire document and the popup.
    # If a click on the document is received but not on the popup, the popup
    # should be closed
    datepickerClicked = false
    window.document.addEventListener 'click', (event) ->
      if scope.calendarShown && ! datepickerClicked
        scope.toggleCalendar(false)
        scope.$apply()
      datepickerClicked = false

    angular.element(element[0])[0].addEventListener 'click', (event) ->
      datepickerClicked = true

    # SCOPE MANIPULATION Methods
    # ================================

    # Refresh the calendar, the input dates, and the button date
    refreshView = ->
      date = if ngModelCtrl.$modelValue then new Date(ngModelCtrl.$modelValue) else null
      setupCalendarView()
      setInputFieldValues(date)
      scope.mainButtonStr = if date then $filter('date')(date, scope.labelFormat) else scope.placeholder
      scope.invalid = ngModelCtrl.$invalid


    # Set the values used in the 2 input fields
    setInputFieldValues = (val) ->
      if val?
        scope.inputDate = $filter('date')(val, scope.dateFormat)
        scope.inputTime = $filter('date')(val, scope.timeFormat)
      else
        scope.inputDate = null
        scope.inputTime = null

    # Set the date that is used by the calendar to determine which month to show
    # Defaults to the current month
    setCalendarDate = (val=null) ->
      d = if val? then new Date(val) else new Date()
      if (d.toString() == "Invalid Date")
        d = new Date()
      d.setDate(1)
      scope.calendarDate = new Date(d)

    # Setup the data needed by the table that makes up the calendar in the popup
    # Uses scope.calendarDate to decide which month to show
    setupCalendarView = ->
      offset = scope.calendarDate.getDay()
      daysInMonth = getDaysInMonth(scope.calendarDate.getFullYear(), scope.calendarDate.getMonth())
      numRows = Math.ceil((offset + daysInMonth) / 7)
      weeks = []
      curDate = new Date(scope.calendarDate)
      curDate.setDate(curDate.getDate() + (offset * -1))
      for row in [0..(numRows-1)]
        weeks.push([])
        for day in [0..6]
          d = new Date(curDate)
          if scope.defaultTime
            time = scope.defaultTime.split(':')
            d.setHours(time[0] || 0)
            d.setMinutes(time[1] || 0)
            d.setSeconds(time[2] || 0)
          selected = ngModelCtrl.$modelValue && d && datesAreEqual(d, ngModelCtrl.$modelValue)
          today = datesAreEqual(d, new Date())
          weeks[row].push({
            date: d
            selected: selected
            disabled: if (typeof(scope.dateFilter) == 'function') then !scope.dateFilter(d) else false
            other: d.getMonth() != scope.calendarDate.getMonth()
            today: today
          })
          curDate.setDate(curDate.getDate() + 1)

      scope.weeks = weeks

    # PARSERS AND FORMATTERS
    # =================================
    # When the model is set from within the datepicker, this will be run
    # before passing it to the model.
    ngModelCtrl.$parsers.push((viewVal) ->
      if scope.required && !viewVal?
        ngModelCtrl.$setValidity('required', false);
        null
      else if angular.isDate(viewVal)
        ngModelCtrl.$setValidity('required', true);
        viewVal
      else if angular.isString(viewVal)
        ngModelCtrl.$setValidity('required', true);
        scope.parseDateFunction(viewVal)
      else
        null
    )

    # When the model is set from outside the datepicker, this will be run
    # before passing it to the datepicker
    ngModelCtrl.$formatters.push((modelVal) ->
      if angular.isDate(modelVal)
        modelVal
      else if angular.isString(modelVal)
        scope.parseDateFunction(modelVal)
      else
        undefined
    )

    # HELPER METHODS
    # =================================
    dateToString = (date, format) ->
      $filter('date')(date, format)

    stringToDate = (date) ->
      if typeof date == 'string'
        parseDateString(date)
      else
        date

    parseDateString = ngQuickDateDefaults.parseDateFunction

    datesAreEqual = (d1, d2, compareTimes=false) ->
      if compareTimes
        (d1 - d2) == 0
      else
        d1 = stringToDate(d1);
        d2 = stringToDate(d2);
        d1 && d2 && (d1.getYear() == d2.getYear()) && (d1.getMonth() == d2.getMonth()) && (d1.getDate() == d2.getDate())

    datesAreEqualToMinute = (d1, d2) ->
      return false unless d1 && d2
      parseInt(d1.getTime() / 60000) == parseInt(d2.getTime() / 60000)

    getDaysInMonth = (year, month) ->
      [31, (if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) then 29 else 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month]

    # DATA WATCHES
    # ==================================
    
    # Called when the model is updated from outside the datepicker
    ngModelCtrl.$render = ->
      setCalendarDate(ngModelCtrl.$viewValue)
      refreshView()

    # Called when the model is updated from inside the datepicker,
    # either by clicking a calendar date, setting an input, etc
    ngModelCtrl.$viewChangeListeners.unshift ->
      setCalendarDate(ngModelCtrl.$viewValue)
      refreshView()
      if scope.onChange
        scope.onChange()

    # When the popup is toggled open, select the date input
    scope.$watch 'calendarShown', (newVal, oldVal) ->
      if newVal
        dateInput = angular.element(element[0].querySelector(".quickdate-date-input"))[0]
        dateInput.select()


    # VIEW ACTIONS
    # ==================================
    scope.toggleCalendar = (show) ->
      if isFinite(show)
        scope.calendarShown = show
      else
        scope.calendarShown = not scope.calendarShown

    # Select a new model date. This is called in 3 situations:
    #   * Clicking a day on the calendar or from the `selectDateFromInput`
    #   * Changing the date or time inputs, which call the `selectDateFromInput` method, which calls this method.
    #   * The clear button is clicked
    scope.selectDate = (date, closeCalendar=true) ->
      changed = (!ngModelCtrl.$viewValue && date) || (ngModelCtrl.$viewValue && !date) || ((date && ngModelCtrl.$viewValue) && (date.getTime() != ngModelCtrl.$viewValue.getTime()))
      if typeof(scope.dateFilter) == 'function' && !scope.dateFilter(date)
        return false
      ngModelCtrl.$setViewValue(date)
      if closeCalendar
        scope.toggleCalendar(false)
      true

    # This is triggered when the date or time inputs have a blur or enter event.
    scope.selectDateFromInput = (closeCalendar=false) ->
      try
        tmpDate = parseDateString(scope.inputDate)
        if !tmpDate
          throw 'Invalid Date'
        if !scope.disableTimepicker && scope.inputTime and scope.inputTime.length and tmpDate
          tmpTime = if scope.disableTimepicker then '00:00:00' else scope.inputTime
          tmpDateAndTime = parseDateString("#{scope.inputDate} #{tmpTime}")
          if !tmpDateAndTime
            throw 'Invalid Time'
          tmpDate = tmpDateAndTime
        unless datesAreEqualToMinute(ngModelCtrl.$viewValue, tmpDate)
          if !scope.selectDate(tmpDate, false)
            throw 'Invalid Date'

        if closeCalendar
          scope.toggleCalendar(false)

        scope.inputDateErr = false
        scope.inputTimeErr = false

      catch err
        if err == 'Invalid Date'
          scope.inputDateErr = true
        else if err == 'Invalid Time'
          scope.inputTimeErr = true

    # When tab is pressed from the date input and the timepicker
    # is disabled, close the popup
    scope.onDateInputTab = ->
      if scope.disableTimepicker
        scope.toggleCalendar(false)
      true

    # When tab is pressed from the time input, close the popup
    scope.onTimeInputTab = ->
      scope.toggleCalendar(false)
      true

    # View the next and previous months in the calendar popup
    scope.nextMonth = ->
      setCalendarDate(new Date(new Date(scope.calendarDate).setMonth(scope.calendarDate.getMonth() + 1)))
      refreshView()
    scope.prevMonth = ->
      setCalendarDate(new Date(new Date(scope.calendarDate).setMonth(scope.calendarDate.getMonth() - 1)))
      refreshView()

    # Set the date model to null
    scope.clear = ->
      scope.selectDate(null, true)

    initialize()

  # TEMPLATE
  # ================================================================
  template: """
            <div class='quickdate'>
              <a href='' ng-focus='toggleCalendar()' ng-click='toggleCalendar()' class='quickdate-button' title='{{hoverText}}'><div ng-hide='iconClass' ng-bind-html='buttonIconHtml'></div>{{mainButtonStr}}</a>
              <div class='quickdate-popup' ng-class='{open: calendarShown}'>
                <a href='' tabindex='-1' class='quickdate-close' ng-click='toggleCalendar()'><div ng-bind-html='closeButtonHtml'></div></a>
                <div class='quickdate-text-inputs'>
                  <div class='quickdate-input-wrapper'>
                    <label>Date</label>
                    <input class='quickdate-date-input' ng-class="{'ng-invalid': inputDateErr}" name='inputDate' type='text' ng-model='inputDate' placeholder='1/1/2013' ng-enter="selectDateFromInput(true)" ng-blur="selectDateFromInput(false)" on-tab='onDateInputTab()' />
                  </div>
                  <div class='quickdate-input-wrapper' ng-hide='disableTimepicker'>
                    <label>Time</label>
                    <input class='quickdate-time-input' ng-class="{'ng-invalid': inputTimeErr}" name='inputTime' type='text' ng-model='inputTime' placeholder='12:00 PM' ng-enter="selectDateFromInput(true)" ng-blur="selectDateFromInput(false)" on-tab='onTimeInputTab()'>
                  </div>
                </div>
                <div class='quickdate-calendar-header'>
                  <a href='' class='quickdate-prev-month quickdate-action-link' tabindex='-1' ng-click='prevMonth()'><div ng-bind-html='prevLinkHtml'></div></a>
                  <span class='quickdate-month'>{{calendarDate | date:'MMMM yyyy'}}</span>
                  <a href='' class='quickdate-next-month quickdate-action-link' ng-click='nextMonth()' tabindex='-1' ><div ng-bind-html='nextLinkHtml'></div></a>
                </div>
                <table class='quickdate-calendar'>
                  <thead>
                    <tr>
                      <th ng-repeat='day in dayAbbreviations'>{{day}}</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr ng-repeat='week in weeks'>
                      <td ng-mousedown='selectDate(day.date, true, true)' ng-click='$event.preventDefault()' ng-class='{"other-month": day.other, "disabled-date": day.disabled, "selected": day.selected, "is-today": day.today}' ng-repeat='day in week'>{{day.date | date:'d'}}</td>
                    </tr>
                  </tbody>
                </table>
                <div class='quickdate-popup-footer'>
                  <a href='' class='quickdate-clear' tabindex='-1' ng-hide='disableClearButton' ng-click='clear()'>Clear</a>
                </div>
              </div>
            </div>
            """
]

app.directive 'ngEnter', ->
  (scope, element, attr) ->
    element.bind 'keydown keypress', (e) ->
      if (e.which == 13)
        scope.$apply(attr.ngEnter)
        e.preventDefault()

app.directive 'onTab', ->
  restrict: 'A',
  link: (scope, element, attr) ->
    element.bind 'keydown keypress', (e) ->
      if (e.which == 9) && !e.shiftKey
        scope.$apply(attr.onTab)
