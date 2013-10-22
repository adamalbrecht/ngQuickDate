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
    scope.calendarShown = false
    scope.dayCodes = ["Su", "M", "Tu", "W", "Th", "F", "Sa"]
    scope.weeks = []

    setDateStr = ->
      scope.dateStr = if scope.ngModel then Date.parse(scope.ngModel).toString('M/d/yyyy') else null

    # DATA BINDING / WATCHING
    scope.$watch "ngModel", (newVal, oldVal) ->
      if newVal != oldVal
        setDateStr()

    scope.$watch "dateStr", (newVal, oldVal) ->
      if newVal != oldVal
        try
          console.log "New Val:", newVal
          newDate = Date.parse(newVal)
          console.log "New Date:", newDate
          throw "Date can't be parsed" if !newDate
          scope.ngModel = newDate
          console.log "Copied into ngModel"
        catch error
          console.log "Error parsing date", error

    setDateStr()

    # VIEW ACTIONS
    # ================================
    scope.finalDateStr = ->
      try
        if ngModel
          scope.ngModel.toString('M/d/yyyy')
        else
          throw "ngModel is null"
      catch
        attrs.placeholder

    scope.toggleCalendar = ->
      scope.calendarShown = not scope.calendarShown

  
  # <div class='aa-input-wrapper'><label>Time</label><input type='text' ng-model='chosenTimeStr' placeholder='12:00pm' /></div>
  template: """
            <div class='aa-datepicker'><a href='' ng-click='toggleCalendar()' class='aa-datepicker-button' title='{{hoverText}}'><i class='{{iconClass}}' ng-show='iconClass'></i>{{finalDateStr()}}</a>
              <div class='aa-calendar-wrapper' ng-class='{open: calendarShown}'>
                <a href='' class='close' ng-click='toggleCalendar()'>X</a>
                <div class='aa-input-wrapper'><label>Date</label><input class='aa-date-text-input' type='text' ng-model='dateStr' placeholder='1/1/2013' /></div>
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
