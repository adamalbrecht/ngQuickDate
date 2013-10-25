app = angular.module("aaDatepickerLib", [])

app.directive "aaDatepicker", [->
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
      numberOfDays = Date.getDaysInMonth(scope.calendarDate.getFullYear(), scope.calendarDate.getMonth())
      rows = []
      for i in [0..(numberOfDays + offset - 1)]
        if i % 7 == 0
          rows.push([])
        if i >= offset
          rows[rows.length - 1].push({day: i - offset + 1})
        else
          rows[rows.length - 1].push({})

      for i in [rows[rows.length - 1].length..6]
        rows[rows.length - 1].push({})

      scope.weeks = rows

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

    initialize()
    setCalendarRows()

    # VIEW HELPERS
    # ==================================
    scope.mainButtonStr = ->
      if scope.ngModel then scope.ngModel.toString('M/d/yyyy') else scope.placeholder

    # VIEW ACTIONS
    # ==================================
    scope.toggleCalendar = ->
      scope.calendarShown = not scope.calendarShown

    scope.nextMonth = -> scope.calendarDate = scope.calendarDate.clone().addMonths(1)
    scope.prevMonth = -> scope.calendarDate = scope.calendarDate.clone().addMonths(-1)

  # <span ng-show='ngModel'>{{ngModel | date:'M/d/yyyy'}}</span><span ng-hide='ngModel'>{{placeholder}}</span> 
  # <div class='aa-input-wrapper'><label>Time</label><input type='text' ng-model='chosenTimeStr' placeholder='12:00pm' /></div>
  template: """
            <div class='aa-datepicker'><a href='' ng-click='toggleCalendar()' class='aa-datepicker-button' title='{{hoverText}}'><i class='{{iconClass}}' ng-show='iconClass'></i>{{mainButtonStr()}}</a>
              <div class='aa-calendar-wrapper' ng-class='{open: calendarShown}'>
                <a href='' class='close' ng-click='toggleCalendar()'>X</a>
                <div class='aa-input-wrapper'><label>Date</label><input class='aa-date-text-input' type='text' ng-model='inputDate' placeholder='1/1/2013' /></div>
                <a href='' class='aa-prev-month' ng-click='prevMonth()'>Prev</a>
                <span class='aa-month'>{{calendarDate | date:'MMMM yyyy'}}</span>
                <a href='' class='aa-next-month' ng-click='nextMonth()'>Next</a>
                <table class='aa-calendar'>
                  <thead>
                    <tr>
                      <th ng-repeat='day in dayCodes'>{{day}}</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr class='week' ng-repeat='week in weeks'>
                      <td class='day' ng-repeat='day in week'>{{day.day}}</td>
                    </tr>
                  </tbody>
                </table>
                <a class='aa-clear-button' href='' ng-click='clear()'>Clear</a>
              </div>
            </div>
            """
]
