app = angular.module("ngQuickDate", [])

app.directive "datepicker", [->
  restrict: "E"
  require: "ngModel"
  scope:
    label: "@"
    hoverText: "@"
    placeholder: "@"
    iconClass: "@"
    ngModel: "="

  replace: true
  link: (scope, element, attrs, ngModel) ->
    
    # INITIALIZE VARIABLES
    # ================================
    initialize = ->
      scope.calendarShown = false
      scope.dayCodes = ["Su", "M", "Tu", "W", "Th", "F", "Sa"]
      scope.weeks = []
      scope.inputDate = null

      if typeof(scope.ngModel) == 'string'
        scope.ngModel = Date.parse(scope.ngModel)

      setInputDateFromModel()
      setCalendarDateFromModel()

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
        scope.inputDate = scope.ngModel.toString('M/d/yyyy')
        scope.inputTime = scope.ngModel.toString('h:mm tt')
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
      if scope.ngModel then scope.ngModel.toString('M/d/yyyy h:mm tt') else scope.placeholder

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

 
  # TEMPLATE
  # ================================================================
  template: """
            <div class='ng-quick-date'><a href='' ng-click='toggleCalendar()' class='ng-quick-date-button' title='{{hoverText}}'><i class='{{iconClass}}' ng-show='iconClass'></i>{{mainButtonStr()}}</a>
              <div class='ng-quick-date-calendar-wrapper' ng-class='{open: calendarShown}'>
                <a href='' class='close' ng-click='toggleCalendar()'>X</a>
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
                  <a href='' class='ng-quick-date-prev-month ng-quick-date-action-link' ng-click='prevMonth()'>Prev</a>
                  <span class='ng-quick-date-month'>{{calendarDate | date:'MMMM yyyy'}}</span>
                  <a href='' class='ng-quick-date-next-month ng-quick-date-action-link' ng-click='nextMonth()'>Next</a>
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
