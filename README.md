## ng-quick-date

### Features Need Before Release

* <s>Click on date to open popup</s>
* <s>Display calendar in popup</s>
* <s>Set date by clicking on calendar</s>
* <s>Highlight today's date</s>
* <s>Highlight selected date</s>
* <s>Change months</s>
* <s>Text input for changing the date</s>
* <s>Text input for changing the time</s>
* Close popup on click outside
* Work when ngModel is set to a string rather than a date object
* Configuration Options
    - Enable / disable timepicker
    - Use alternate date formats
    - Default placeholder text
    - Replace close X with an icon
    - Replace Next and Prev links with icons
    - Set icon in link
* Better class names
* Nest all theme styles under a `default-theme` class that is applied to the root
* Separate basic styling from default theme
    - Make it at least usable without a theme
    - Move colors and widths into variables (in both files)
* Make it responsive
* Tabbing from previous form fields should open the popup and focus properly
* Extract all usage of Date.js to a wrapper class so that another library (or no library) could be swapped in
* Finish README
    - build instructions
    - contribution instructions
* Finish Demo site
    - 4 or so basic examples
    - List of inline options
    - List of configuration options


### Potential Features down the road

* Option to remove date input field and instead use arrows on calendar
* Option ro replace the time text field with a select box 
    - Also configure increment in select box (15 min, 1 hour, etc)
