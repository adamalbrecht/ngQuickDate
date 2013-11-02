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


    # SCOPE MANIPULATION
    # ================================
    setInputDateFromModel = ->
      if scope.ngModel
        scope.inputDate = scope.ngModel.toString('M/d/yyyy')
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
      if scope.ngModel then scope.ngModel.toString('M/d/yyyy') else scope.placeholder

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
        scope.inputDateErr = false
        scope.ngModel = tmpDate
        if closeCalendar
          scope.calendarShown = false
      catch err
        scope.inputDateErr = true

    scope.nextMonth = -> scope.calendarDate = scope.calendarDate.clone().addMonths(1)
    scope.prevMonth = -> scope.calendarDate = scope.calendarDate.clone().addMonths(-1)

  # <span ng-show='ngModel'>{{ngModel | date:'M/d/yyyy'}}</span><span ng-hide='ngModel'>{{placeholder}}</span> 
  # <div class='ng-quick-date-input-wrapper'><label>Time</label><input type='text' ng-model='chosenTimeStr' placeholder='12:00pm' /></div>
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
                      <select class='ng-qd-time-select'>
                      <option>12pm</option>
                    </select>
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
                      <td class='day' ng-click='setDate(day.date)' ng-class='{"other-month": (day.date.getMonth() != calendarDate.getMonth()), "selected": day.selected, "today": day.today}' ng-repeat='day in week'>{{day.date | date:'d'}}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            """
]

app.directive 'ngBlur', ->
  (scope, elem, attrs) ->
    elem.bind 'blur', ->
      scope.$apply(attrs.ngBlur)

app.directive 'ngEnter', ->
  (scope, elem, attrs) ->
    elem.bind 'keydown keypress', (e) ->
      if (e.which == 13)
        console.log 'enter pressed'
        scope.$apply(attrs.ngEnter)
        e.preventDefault();
