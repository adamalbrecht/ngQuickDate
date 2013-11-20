app = angular.module("ngQuickDate", [])

app.provider "ngQuickDateDefaults", ->
  @options = {
    dateFormat: 'M/d/yyyy'
    timeFormat: 'h:mm a'
    labelFormat: null
    placeholder: 'Click to Set Date'
    hoverText: null
    buttonIconHtml: null
    closeButtonHtml: 'X'
    nextLinkHtml: 'Next'
    prevLinkHtml: 'Prev'
    disableTimepicker: false
    dayAbbreviations: ["Su", "M", "Tu", "W", "Th", "F", "Sa"],
    parseDateFunction: (str) ->
      seconds = Date.parse(str)
      if isNaN(seconds)
        return null
      else
        new Date(seconds)
  }
  @$get = ->
    @options

  @set = (keyOrHash, value) ->
    if typeof(keyOrHash) == 'object'
      for k, v of keyOrHash
        @options[k] = v
    else
      @options[keyOrHash] = value

app.directive "datepicker", ['ngQuickDateDefaults', '$filter', (ngQuickDateDefaults, $filter) ->
  restrict: "E"
  require: "ngModel"
  scope:
    ngModel: "="

  replace: true
  link: (scope, element, attrs, ngModel) ->
    debug = attrs.debug && attrs.debug.length
    
    # INITIALIZE VARIABLES
    # ================================
    initialize = ->
      scope.calendarShown = false
      scope.weeks = []
      scope.inputDate = null

      if typeof(scope.ngModel) == 'string'
        scope.ngModel = parseDateString(scope.ngModel)

      setConfigOptions()
      setInputDateFromModel()
      setCalendarDateFromModel()

    setConfigOptions = ->
      for key, value of ngQuickDateDefaults
        if !key.match(/html/) && attrs[key] && attrs[key].length
          scope[key] = attrs[key]
        else
          scope[key] = ngQuickDateDefaults[key]
      if !ngQuickDateDefaults.labelFormat
        scope.labelFormat = "#{scope.dateFormat} #{scope.timeFormat}"
      if attrs.iconClass && attrs.iconClass.length
        scope.buttonIconHtml = "<i ng-show='iconClass' class='#{attrs.iconClass}'></i>"

    # VIEW SETUP
    # ================================
    window.document.addEventListener 'click', (event) ->
      scope.calendarShown = false
      scope.$apply()

    angular.element(element[0])[0].addEventListener 'click', (event) ->
      event.stopPropagation();

    # SCOPE MANIPULATION
    # ================================
    setInputDateFromModel = ->
      if scope.ngModel
        scope.inputDate = $filter('date')(scope.ngModel, ngQuickDateDefaults.dateFormat)
        scope.inputTime = $filter('date')(scope.ngModel, ngQuickDateDefaults.timeFormat)
      else
        scope.inputDate = null

    setCalendarDateFromModel = ->
      d = if scope.ngModel then new Date(scope.ngModel) else new Date()
      if (d.toString() == "Invalid Date")
        d = new Date()
      d.setDate(1)
      scope.calendarDate = parseDateString(d)

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
          selected = scope.ngModel && d && datesAreEqual(d, scope.ngModel)
          today = datesAreEqual(d, new Date())
          weeks[row].push({
            date: d
            selected: selected
            other: d.getMonth() != scope.calendarDate.getMonth()
            today: today
          })
          curDate.setDate(curDate.getDate() + 1)

      scope.weeks = weeks

    # HELPER METHODS
    # =================================
    dateToString = (date, format) ->
      $filter('date')(date, format)

    parseDateString = ngQuickDateDefaults.parseDateFunction

    datesAreEqual = (d1, d2, compareTimes=false) ->
      if compareTimes
        (d1 - d2) == 0
      else
        d1 && d2 && (d1.getYear() == d2.getYear()) && (d1.getMonth() == d2.getMonth()) && (d1.getDate() == d2.getDate())

    getDaysInMonth = (year, month) ->
      [31, (if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) then 29 else 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month]

    # DATA WATCHES
    # ==================================
    scope.$watch('ngModel', (newVal, oldVal) ->
      if newVal != oldVal
        setInputDateFromModel()
        setCalendarDateFromModel()
    )

    scope.$watch('calendarDate', (newVal, oldVal) ->
      if (newVal != oldVal)
        setCalendarRows()
    )

    scope.$watch('calendarShown', (newVal, oldVal) ->
        dateInput = angular.element(element[0].querySelector(".datepicker-date-input"))[0]
        dateInput.select()
    )

    initialize()
    setCalendarRows()

    # VIEW HELPERS
    # ==================================
    scope.mainButtonStr = ->
      if scope.ngModel then $filter('date')(scope.ngModel, scope.labelFormat) else scope.placeholder

    # VIEW ACTIONS
    # ==================================
    scope.toggleCalendar = (show) ->
      scope.calendarShown = not scope.calendarShown

    scope.setDate = (date, closeCalendar=true) ->
      scope.ngModel = date
      scope.calendarShown = false

    scope.setDateFromInput = (closeCalendar=false) ->
      try
        tmpDate = parseDateString(scope.inputDate)
        if !tmpDate
          throw 'Invalid Date'
        if scope.inputTime and scope.inputTime.length and tmpDate
          tmpTime = if scope.disableTimepicker then '00:00:00' else scope.inputTime
          tmpDateAndTime = parseDateString("#{scope.inputDate} #{tmpTime}")
          if !tmpDateAndTime
            throw 'Invalid Time'
          scope.ngModel = tmpDateAndTime
        else
          scope.ngModel = tmpDate
        if closeCalendar
          scope.calendarShown = false

        scope.inputDateErr = false
        scope.inputTimeErr = false
      catch err
        if err == 'Invalid Date'
          scope.inputDateErr = true
        else if err == 'Invalid Time'
          scope.inputTimeErr = true

    scope.onDateInputTab = (param) ->
      if scope.disableTimepicker
        scope.toggleCalendar(false)
        false
      else
        true

    scope.onTimeInputTab = (param) ->
      scope.toggleCalendar(false)

    scope.nextMonth = -> 
      scope.calendarDate = new Date(new Date(scope.calendarDate).setMonth(scope.calendarDate.getMonth() + 1))
    scope.prevMonth = ->
      scope.calendarDate = new Date(new Date(scope.calendarDate).setMonth(scope.calendarDate.getMonth() - 1))

    if debug
      console.log "quick date scope:", scope
 
  # TEMPLATE
  # ================================================================
  template: """
            <div class='datepicker'><a href='' ng-focus='toggleCalendar(true)' ng-click='toggleCalendar()' class='datepicker-button' title='{{hoverText}}'><div ng-hide='iconClass' ng-bind-html-unsafe='buttonIconHtml'></div>{{mainButtonStr()}}</a>
              <div class='datepicker-popup' ng-class='{open: calendarShown}'>
                <a href='' tabindex='-1' class='datepicker-close' ng-click='toggleCalendar()'><div ng-bind-html-unsafe='closeButtonHtml'></div></a>
                <div class='datepicker-text-inputs'>
                  <div class='datepicker-input-wrapper'>
                    <label>Date</label>
                    <input class='datepicker-date-input' name='inputDate' type='text' ng-model='inputDate' placeholder='1/1/2013' ng-blur='setDateFromInput()' ng-enter='setDateFromInput(true)' ng-class="{'ng-quick-date-error': inputDateErr}"  ng-tab='onDateInputTab()' />
                  </div>
                  <div class='datepicker-input-wrapper' ng-hide='disableTimepicker'>
                    <label>Time</label>
                    <input class='datepicker-time-input' name='inputTime' type='text' ng-model='inputTime' placeholder='12pm' ng-blur='setDateFromInput()' ng-enter='setDateFromInput(true)' ng-class="{'datepicker-error': inputTimeErr}" ng-tab='onTimeInputTab()'>
                  </div>
                </div>
                <div class='datepicker-calendar-header'>
                  <a href='' class='datepicker-prev-month datepicker-action-link' tabindex='-1' ng-click='prevMonth()'><div ng-bind-html-unsafe='prevLinkHtml'></div></a>
                  <span class='datepicker-month'>{{calendarDate | date:'MMMM yyyy'}}</span>
                  <a href='' class='datepicker-next-month datepicker-action-link' ng-click='nextMonth()' tabindex='-1' ><div ng-bind-html-unsafe='nextLinkHtml'></div></a>
                </div>
                <table class='datepicker-calendar'>
                  <thead>
                    <tr>
                      <th ng-repeat='day in dayAbbreviations'>{{day}}</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr ng-repeat='week in weeks'>
                      <td ng-mousedown='setDate(day.date)' ng-class='{"other-month": day.other, "selected": day.selected, "is-today": day.today}' ng-repeat='day in week'>{{day.date | date:'d'}}</td>
                    </tr>
                  </tbody>
                </table>
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

app.directive 'ngTab', ->
  (scope, element, attr) ->
    element.bind 'keydown keypress', (e) ->
      if (e.which == 9)
        scope.$apply(attr.ngTab)



# These directives are provided in angular 1.2+
if parseInt(angular.version.full) < 1.2
  app.directive "ngBlur", ["$parse", ($parse) ->
    (scope, element, attr) ->
      fn = $parse(attr["ngBlur"])
      element.bind "blur", (event) ->
        scope.$apply ->
          fn scope,
            $event: event
  ]
  app.directive "ngFocus", ["$parse", ($parse) ->
    (scope, element, attr) ->
      fn = $parse(attr["ngFocus"])
      element.bind "focus", (event) ->
        scope.$apply ->
          fn scope,
            $event: event
  ]
