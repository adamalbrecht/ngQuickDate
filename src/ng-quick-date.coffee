#
# ngQuickDate
# by Adam Albrecht
# http://adamalbrecht.com
#
# Source Code: https://github.com/adamalbrecht/ngQuickDate
#
# Compatible with Angular 1.0.8
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

app.directive "datepicker", ['ngQuickDateDefaults', '$filter', '$sce', (ngQuickDateDefaults, $filter, $sce) ->
  restrict: "E"
  require: "ngModel"
  scope:
    dateFilter: '=?'
    ngModel: "="
    onChange: "&"

  replace: true
  link: (scope, element, attrs, ngModel) ->
    debug = attrs.debug && attrs.debug.length

    # INITIALIZE VARIABLES
    # ================================
    initialize = ->
      scope.toggleCalendar(false)
      scope.weeks = []
      scope.inputDate = null

      if typeof(scope.ngModel) == 'string'
        scope.ngModel = parseDateString(scope.ngModel)

      if typeof(attrs.initValue) == 'string'
        scope.ngModel = parseDateString(attrs.initValue)

      setConfigOptions()
      setInputDateFromModel()
      setCalendarDateFromModel()

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
    datepickerClicked = false
    window.document.addEventListener 'click', (event) ->
      unless datepickerClicked
        scope.toggleCalendar(false)
        scope.$apply()
      datepickerClicked = false

    angular.element(element[0])[0].addEventListener 'click', (event) ->
      datepickerClicked = true

    # SCOPE MANIPULATION
    # ================================
    setInputDateFromModel = ->
      if scope.ngModel
        scope.inputDate = $filter('date')(scope.ngModel, ngQuickDateDefaults.dateFormat)
        scope.inputTime = $filter('date')(scope.ngModel, ngQuickDateDefaults.timeFormat)
      else
        scope.inputDate = null
        scope.inputTime = null

    setCalendarDateFromModel = ->
      d = if scope.ngModel then new Date(scope.ngModel) else new Date()
      if (d.toString() == "Invalid Date")
        d = new Date()
      d.setDate(1)
      scope.calendarDate = new Date(d)

    setCalendarRows = ->
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
          selected = scope.ngModel && d && datesAreEqual(d, scope.ngModel)
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
    scope.$watch('ngModel', (newVal, oldVal) ->
      if newVal != oldVal
        setInputDateFromModel()
        setCalendarDateFromModel()
        if scope.onChange and !datesAreEqualToMinute(newVal, oldVal)
          scope.onChange()
    )

    scope.$watch('calendarDate', (newVal, oldVal) ->
      if (newVal != oldVal)
        setCalendarRows()
    )

    scope.$watch('calendarShown', (newVal, oldVal) ->
        dateInput = angular.element(element[0].querySelector(".quickdate-date-input"))[0]
        dateInput.select()
    )


    # VIEW HELPERS
    # ==================================
    scope.mainButtonStr = ->
      if scope.ngModel then $filter('date')(scope.ngModel, scope.labelFormat) else scope.placeholder

    # VIEW ACTIONS
    # ==================================
    scope.toggleCalendar = (show) ->
      if isFinite(show)
        scope.calendarShown = show
      else
        scope.calendarShown = not scope.calendarShown

    scope.setDate = (date, closeCalendar=true) ->
      changed = (!scope.ngModel && date) || (scope.ngModel && !date) || (date.getTime() != stringToDate(scope.ngModel).getTime())
      if typeof(scope.dateFilter) == 'function' && !scope.dateFilter(date)
        return false
      scope.ngModel = date
      if closeCalendar
        scope.toggleCalendar(false)
      true

    scope.setDateFromInput = (closeCalendar=false) ->
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
        unless datesAreEqualToMinute(scope.ngModel, tmpDate)
          if !scope.setDate(tmpDate, false)
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

    scope.onDateInputTab = ->
      if scope.disableTimepicker
        scope.toggleCalendar(false)
      true

    scope.onTimeInputTab = ->
      scope.toggleCalendar(false)
      true

    scope.nextMonth = ->
      scope.calendarDate = new Date(new Date(scope.calendarDate).setMonth(scope.calendarDate.getMonth() + 1))
    scope.prevMonth = ->
      scope.calendarDate = new Date(new Date(scope.calendarDate).setMonth(scope.calendarDate.getMonth() - 1))

    scope.clear = ->
      scope.setDate(null, true)


    initialize()
    setCalendarRows()

    if debug
      console.log "quick date scope:", scope

  # TEMPLATE
  # ================================================================
  template: """
            <div class='quickdate'>
              <a href='' ng-focus='toggleCalendar()' ng-click='toggleCalendar()' class='quickdate-button' title='{{hoverText}}'><div ng-hide='iconClass' ng-bind-html='buttonIconHtml'></div>{{mainButtonStr()}}</a>
              <div class='quickdate-popup' ng-class='{open: calendarShown}'>
                <a href='' tabindex='-1' class='quickdate-close' ng-click='toggleCalendar()'><div ng-bind-html='closeButtonHtml'></div></a>
                <div class='quickdate-text-inputs'>
                  <div class='quickdate-input-wrapper'>
                    <label>Date</label>
                    <input class='quickdate-date-input' name='inputDate' type='text' ng-model='inputDate' placeholder='1/1/2013' ng-blur="setDateFromInput()" ng-enter="setDateFromInput(true)" ng-class="{'quickdate-error': inputDateErr}" on-tab='onDateInputTab()' />
                  </div>
                  <div class='quickdate-input-wrapper' ng-hide='disableTimepicker'>
                    <label>Time</label>
                    <input class='quickdate-time-input' name='inputTime' type='text' ng-model='inputTime' placeholder='12:00 PM' ng-blur="setDateFromInput(false)" ng-enter="setDateFromInput(true)" ng-class="{'quickdate-error': inputTimeErr}" on-tab='onTimeInputTab()'>
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
                      <td ng-mousedown='setDate(day.date)' ng-class='{"other-month": day.other, "disabled-date": day.disabled, "selected": day.selected, "is-today": day.today}' ng-repeat='day in week'>{{day.date | date:'d'}}</td>
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
