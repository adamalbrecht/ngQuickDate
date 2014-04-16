#
# fdQuickMoment
# by Adam Albrecht and Andrew Coldham
# http://adamalbrecht.com + http://www.frontdeskhq.com
#
# Source Code: https://github.com/frontdesk/fdQuickMoment
#
# Compatible with Angular 1.0.8
#

app = angular.module("fdQuickMoment", [])

app.provider "fdQuickMomentDefaults", ->
  {
    options: {
      dateFormat: 'M/D/YYYY'
      timeFormat: 'h:mm A'
      labelFormat: null
      placeholder: 'Click to Set Date'
      hoverText: null
      buttonIconHtml: null
      closeButtonHtml: '&times;'
      nextLinkHtml: 'Next &rarr;'
      prevLinkHtml: '&larr; Prev'
      disableTimepicker: false
      disableDateinput: false
      disableClearButton: false
      defaultTime: null
      dayAbbreviations: ["Su", "M", "Tu", "W", "Th", "F", "Sa"],
      dateFilter: null
      timezone: "America/Chicago"
      parseDateFunction: (str) ->
        m = moment(str)
        if !m.isValid()
          return null
        else
          m

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

app.directive "momentpicker", ['fdQuickMomentDefaults', '$filter', '$sce', (fdQuickMomentDefaults, $filter, $sce) ->
  restrict: "E"
  require: "ngModel"
  scope:
    dateFilter: '=?'
    # timezone: '@'
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
      scope.timezone = attrs.timezone

      if typeof(scope.ngModel) == 'string'
        scope.ngModel = parseDateString(scope.ngModel)

      if typeof(attrs.initValue) == 'string'
        scope.ngModel = parseDateString(attrs.initValue)

      setConfigOptions()
      setInputDateFromModel()
      setCalendarDateFromModel()

    setConfigOptions = ->
      for key, value of fdQuickMomentDefaults
        if key.match(/[Hh]tml/)
          scope[key] = $sce.trustAsHtml(fdQuickMomentDefaults[key] || "")
        else if !scope[key] && attrs[key]
          scope[key] = attrs[key]
        else if !scope[key]
          scope[key] = fdQuickMomentDefaults[key]
      if !scope.labelFormat
        scope.labelFormat = scope.dateFormat
        unless scope.disableTimepicker
          scope.labelFormat += " " + scope.timeFormat
      if attrs.iconClass && attrs.iconClass.length
        scope.buttonIconHtml = $sce.trustAsHtml("<i ng-show='iconClass' class='#{attrs.iconClass}'></i>")
      if scope.timezone == undefined
        throw "timezone required"

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
        scope.inputDate = scope.ngModel.format(scope.dateFormat)
        scope.inputTime = scope.ngModel.format(scope.timeFormat)
      else
        scope.inputDate = null
        scope.inputTime = null

    setCalendarDateFromModel = ->
      d = if scope.ngModel then moment(scope.ngModel).tz(scope.timezone) else moment().tz(scope.timezone)
      if (d == undefined || !d.isValid())
        d = moment().tz(scope.timezone)
      scope.calendarDate = d.startOf('month').tz(scope.timezone)

    setCalendarRows = ->
      offset = scope.calendarDate.day()
      daysInMonth = scope.calendarDate.daysInMonth()
      numRows = Math.ceil((offset + daysInMonth) / 7)
      weeks = []
      curDate = moment(scope.calendarDate).tz(scope.timezone)
      curDate.add('d', offset * -1)
      for row in [0..(numRows-1)]
        weeks.push([])
        for day in [0..6]
          d = moment(curDate).tz(scope.timezone)
          if scope.defaultTime
            time = scope.defaultTime.split(':')
            d.hours(time[0] || 0)
            d.minutes(time[1] || 0)
            d.seconds(time[2] || 0)
          selected = scope.ngModel && d && datesAreEqual(d, scope.ngModel)
          today = datesAreEqual(d, moment().tz(scope.timezone))
          weeks[row].push({
            date: d
            selected: selected
            disabled: if (typeof(scope.dateFilter) == 'function') then !scope.dateFilter(d) else false
            other: d.month() != scope.calendarDate.month()
            today: today
          })
          curDate.add('d',1)

      scope.weeks = weeks

    # HELPER METHODS
    # =================================
    dateToString = (date, format) ->
      date.format(format)

    stringToDate = (date) ->
      if typeof date == 'string'
        parseDateString(date)
      else
        date

    parseDateString = fdQuickMomentDefaults.parseDateFunction

    datesAreEqual = (d1, d2, compareTimes=false) ->
      if compareTimes
        (d1.unix() == d2.unix())
      else
        d1 = stringToDate(d1);
        d2 = stringToDate(d2);
        d1.year() == d2.year() && d1.month() == d2.month() && d1.date() == d2.date()

    datesAreEqualToMinute = (d1, d2) ->
      return false unless d1 && d2
      d1.year() == d2.year() && d1.month() == d2.month() && d1.date() == d2.date() && d1.hour() == d2.hour() && d1.minute() == d2.minute()


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
        dateInput = angular.element(element[0].querySelector(".quickmoment-date-input"))[0]
        dateInput.select()
    )


    # VIEW HELPERS
    # ==================================
    scope.mainButtonStr = ->
      if scope.ngModel then scope.ngModel.format(scope.labelFormat) else scope.placeholder

    # VIEW ACTIONS
    # ==================================
    scope.toggleCalendar = (show) ->
      if isFinite(show)
        scope.calendarShown = show
      else
        scope.calendarShown = not scope.calendarShown

    scope.setDate = (date, closeCalendar=true) ->
      changed = (!scope.ngModel && date) || (scope.ngModel && !date) || (date.unix() != stringToDate(scope.ngModel).unix())
      if typeof(scope.dateFilter) == 'function' && !scope.dateFilter(date)
        return false
      if scope.disableTimepicker &&  scope.ngModel
        hours = scope.ngModel.hours()
        minutes = scope.ngModel.minutes()
        date = date.hours(hours).minutes(minutes)
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
      scope.calendarDate = moment(scope.calendarDate).tz(scope.timezone).add('M', 1)
    scope.prevMonth = ->
      scope.calendarDate = moment(scope.calendarDate).tz(scope.timezone).subtract('M', 1)

    scope.clear = ->
      scope.setDate(null, true)


    initialize()
    setCalendarRows()

    if debug
      console.log "quick date scope:", scope

  # TEMPLATE
  # ================================================================
  template: """
            <div class='quickmoment'>
              <a href='' ng-focus='toggleCalendar()' ng-click='toggleCalendar()' class='quickmoment-button' title='{{hoverText}}'><div ng-hide='iconClass' ng-bind-html='buttonIconHtml'></div>{{mainButtonStr()}}</a>
              <div class='quickmoment-popup' ng-class='{open: calendarShown}'>
                <a href='' tabindex='-1' class='quickmoment-close' ng-click='toggleCalendar()'><div ng-bind-html='closeButtonHtml'></div></a>
                <div class='quickmoment-text-inputs'>
                  <div class='quickmoment-input-wrapper' ng-hide='disableDateinput'>
                    <label>Date</label>
                    <input class='quickmoment-date-input' name='inputDate' type='text' ng-model='inputDate' placeholder='1/1/2013' ng-blur="setDateFromInput()" ng-enter="setDateFromInput(true)" ng-class="{'quickmoment-error': inputDateErr}" on-tab='onDateInputTab()'/>
                  </div>
                  <div class='quickmoment-input-wrapper' ng-hide='disableTimepicker'>
                    <label>Time</label>
                    <input class='quickmoment-time-input' name='inputTime' type='text' ng-model='inputTime' placeholder='12:00 PM' ng-blur="setDateFromInput(false)" ng-enter="setDateFromInput(true)" ng-class="{'quickmoment-error': inputTimeErr}" on-tab='onTimeInputTab()'>
                  </div>
                </div>
                <div class='quickmoment-calendar-header'>
                  <a href='' class='quickmoment-prev-month quickmoment-action-link' tabindex='-1' ng-click='prevMonth()'><div ng-bind-html='prevLinkHtml'></div></a>
                  <span class='quickmoment-month'>{{calendarDate | moment:'MMMM YYYY'}}</span>
                  <a href='' class='quickmoment-next-month quickmoment-action-link' ng-click='nextMonth()' tabindex='-1' ><div ng-bind-html='nextLinkHtml'></div></a>
                </div>
                <table class='quickmoment-calendar'>
                  <thead>
                    <tr>
                      <th ng-repeat='day in dayAbbreviations'>{{day}}</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr ng-repeat='week in weeks'>
                      <td ng-mousedown='setDate(day.date)' ng-class='{"other-month": day.other, "disabled-date": day.disabled, "selected": day.selected, "is-today": day.today}' ng-repeat='day in week'>{{day.date | moment:'D'}}</td>
                    </tr>
                  </tbody>
                </table>
                <div class='quickmoment-popup-footer'>
                  <a href='' class='quickmoment-clear' tabindex='-1' ng-hide='disableClearButton' ng-click='clear()'>Clear</a>
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

app.filter 'moment', ->
  return (momentObj, formatStr) ->
    return momentObj.format(formatStr)
