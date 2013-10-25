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

    setInputDateFromModel = ->
      if scope.ngModel
        scope.inputDate = scope.ngModel.toString('M/d/yyyy')
      else
        scope.inputDate = null

    setCalendarDateFromModel = ->
      scope.calendarDate = scope.ngModel || Date.today()

    # DATA WATCHES
    # ==================================
    scope.$watch('ngModel', (newVal, oldVal) ->
      if newVal != oldVal
        setInputDateFromModel()
        setCalendarDateFromModel()
    )

    initialize()

    # VIEW ACTIONS
    # ==================================
    scope.toggleCalendar = ->
      scope.calendarShown = not scope.calendarShown

    scope.mainButtonStr = ->
      if scope.ngModel then scope.ngModel.toString('M/d/yyyy') else scope.placeholder

  # <span ng-show='ngModel'>{{ngModel | date:'M/d/yyyy'}}</span><span ng-hide='ngModel'>{{placeholder}}</span> 
  # <div class='aa-input-wrapper'><label>Time</label><input type='text' ng-model='chosenTimeStr' placeholder='12:00pm' /></div>
  template: """
            <div class='aa-datepicker'><a href='' ng-click='toggleCalendar()' class='aa-datepicker-button' title='{{hoverText}}'><i class='{{iconClass}}' ng-show='iconClass'></i>{{mainButtonStr()}}</a>
              <div class='aa-calendar-wrapper' ng-class='{open: calendarShown}'>
                <a href='' class='close' ng-click='toggleCalendar()'>X</a>
                <div class='aa-input-wrapper'><label>Date</label><input class='aa-date-text-input' type='text' ng-model='inputDate' placeholder='1/1/2013' /></div>
                <span class='aa-month'>{{calendarDate | date:'MMMM'}}</span>
                <table class='aa-calendar'>
                  <thead>
                    <tr>
                      <th ng-repeat='day in dayCodes'>{{day}}</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr ng-repeat='week in weeks'>
                      <td ng-repeat='day in week.days'>{{day}}</td>
                    </tr>
                  </tbody>
                </table>
                <a class='aa-clear-button' href='' ng-click='clear()'>Clear</a>
              </div>
            </div>
            """
]
