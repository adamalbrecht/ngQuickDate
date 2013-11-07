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
    showTimePicker: true
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
      scope.dayCodes = ["Su", "M", "Tu", "W", "Th", "F", "Sa"]
      scope.weeks = []
      scope.inputDate = null

      if typeof(scope.ngModel) == 'string'
        scope.ngModel = Date.parse(scope.ngModel)

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
      d = if scope.ngModel then scope.ngModel.clone() else Date.today()
      d.setDate(1)
      scope.calendarDate = Date.parse(d)

    setCalendarRows = ->
      offset = scope.calendarDate.getDay()
      daysInMonth = Date.getDaysInMonth(scope.calendarDate.getFullYear(), scope.calendarDate.getMonth())
      numRows = Math.ceil((offset + daysInMonth) / 7)
      weeks = []
      curDate = scope.calendarDate.clone().addDays(offset * -1)
      for row in [0..(numRows-1)]
        weeks.push([])
        for day in [0..6]
          d = curDate.clone()
          selected = scope.ngModel && d && (d.toString('Mdyyyy') == scope.ngModel.toString('Mdyyyy'))
          today = d.toString('Mdyyyy') == (new Date()).toString('Mdyyyy')
          weeks[row].push({
            date: d
            selected: selected
            today: today
          })
          curDate.addDays(1)

      scope.weeks = weeks

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
        dateInput = angular.element(element[0].querySelector(".ng-qd-date-input"))[0]
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
        tmpDate = Date.parse(scope.inputDate)
        if !tmpDate
          throw 'Invalid Date'
        if scope.inputTime and scope.inputTime.length and tmpDate
          tmpDateAndTime = Date.parse("#{scope.inputDate} #{scope.inputTime}")
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

    scope.nextMonth = -> scope.calendarDate = scope.calendarDate.clone().addMonths(1)
    scope.prevMonth = -> scope.calendarDate = scope.calendarDate.clone().addMonths(-1)

    if debug
      console.log "quick date scope:", scope
 
  # TEMPLATE
  # ================================================================
  template: """
            <div class='ng-quick-date'><a href='' ng-click='toggleCalendar()' class='ng-quick-date-button' title='{{hoverText}}'><div ng-hide='iconClass' ng-bind-html-unsafe='buttonIconHtml'></div>{{mainButtonStr()}}</a>
              <div class='ng-quick-date-calendar-wrapper' ng-class='{open: calendarShown}'>
                <a href='' class='ng-qd-close' ng-click='toggleCalendar()'><div ng-bind-html-unsafe='closeButtonHtml'></div></a>
                <div class='ng-quick-date-inputs'>
                  <div class='ng-quick-date-input-wrapper'>
                    <label>Date</label>
                    <input class='ng-qd-date-input' name='inputDate' type='text' ng-model='inputDate' placeholder='1/1/2013' ng-blur='setDateFromInput()' ng-enter='setDateFromInput(true)' ng-class="{'ng-quick-date-error': inputDateErr}" />
                  </div>
                  <div class='ng-quick-date-input-wrapper'>
                    <label>Time</label>
                    <input class='ng-qd-time-input' name='inputTime' type='text' ng-model='inputTime' placeholder='12pm' ng-blur='setDateFromInput()' ng-enter='setDateFromInput(true)' ng-class="{'ng-quick-date-error': inputTimeErr}">
                  </div>
                </div>
                <div class='ng-quick-date-calendar-header'>
                  <a href='' class='ng-quick-date-prev-month ng-quick-date-action-link' ng-click='prevMonth()'><div ng-bind-html-unsafe='prevLinkHtml'></div></a>
                  <span class='ng-quick-date-month'>{{calendarDate | date:'MMMM yyyy'}}</span>
                  <a href='' class='ng-quick-date-next-month ng-quick-date-action-link' ng-click='nextMonth()'><div ng-bind-html-unsafe='nextLinkHtml'></div></a>
                </div>
                <table class='ng-quick-date-calendar'>
                  <thead>
                    <tr>
                      <th ng-repeat='day in dayCodes'>{{day}}</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr class='week' ng-repeat='week in weeks'>
                      <td class='day' ng-mousedown='setDate(day.date)' ng-class='{"other-month": (day.date.getMonth() != calendarDate.getMonth()), "selected": day.selected, "today": day.today}' ng-repeat='day in week'>{{day.date | date:'d'}}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            """
]
app.directive "ngBlur", ["$parse", ($parse) ->
  (scope, element, attr) ->
    fn = $parse(attr["ngBlur"])
    element.bind "blur", (event) ->
      scope.$apply ->
        fn scope,
          $event: event
]
app.directive 'ngEnter', ->
  (scope, element, attr) ->
    element.bind 'keydown keypress', (e) ->
      if (e.which == 13)
        console.log 'enter pressed'
        scope.$apply(attr.ngEnter)
        e.preventDefault();
