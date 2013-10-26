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
      numRows = if (offset > 4) then 6 else 5
      weeks = []
      curDate = scope.calendarDate.clone().addDays(offset * -1)
      for row in [0..(numRows-1)]
        weeks.push([])
        for day in [0..6]
          weeks[row].push({date: curDate.clone()})
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
                <div class='aa-inputs'>
                  <div class='aa-input-wrapper'>
                    <label>Date</label>
                    <input class='aa-date-text-input' type='text' ng-model='inputDate' placeholder='1/1/2013' />
                  </div>
                  <div class='aa-input-wrapper'>
                    <label>Time</label>
                    <select class='aa-time-select'>
                      <option>12pm</option>
                    </select>
                  </div>
                </div>
                <div class='aa-calendar-header'>
                  <a href='' class='aa-prev-month aa-action-link' ng-click='prevMonth()'>Prev</a>
                  <span class='aa-month'>{{calendarDate | date:'MMMM yyyy'}}</span>
                  <a href='' class='aa-next-month aa-action-link' ng-click='nextMonth()'>Next</a>
                </div>
                <table class='aa-calendar'>
                  <thead>
                    <tr>
                      <th ng-repeat='day in dayCodes'>{{day}}</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr class='week' ng-repeat='week in weeks'>
                      <td class='day' ng-class='{"other-month": (day.date.getMonth() != calendarDate.getMonth())}' ng-repeat='day in week'>{{day.date | date:'d'}}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            """
]
