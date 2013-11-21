# NgQuickDate

NgQuickDate is an [Angular.js](http://angularjs.org/) Date/Time picker directive. It stresses speed of data entry and simplicity while being highly configurable and easy to re-style.

## Download

* [Version 1.0](https://github.com/adamalbrecht/ngQuickDate/releases/download/v1.0/ng-quick-date-1.0.zip) - Coming soon. Compatible with Angular 1.0
* Version 1.2 - Coming soon. Compatible with Angular 1.2. Not backwards compatible.

## Install with Bower

Coming Soon

## Demo

Coming Soon

## The Basics

To use the library, include the JS file, main CSS file, and (optionally, but recommended) the theme CSS file. Then include the module in your app:

```javascript
app = angular.module("myApp", ["ngQuickDate"])
```

The directive itself is simply called *datepicker*. The only required attribute is ngModel, which should be a date object.

```html
<datepicker ng-model='myDate' />
```

## Inline Options

There are a number of options that be configured inline with attributes. Here are a few:

| Option              | Default             | Description                                                                                 |
| ------------------- | ------------------- | ------------------------------------------------------------------------------------------- |
| date-format         | "M/d/yyyy"          | Date Format used in the date input box.                                                     |
| time-format         | "h:mm a"            | Time Format used in the time input box.                                                     |
| label-format        | null                | Date/Time format used on button. If null, will use combination of date and time formats.    |
| placeholder         | 'Click to Set Date' | Text that is shown on button when the model variable is null.                               |
| hover-text          | null                | Hover text for button.                                                                      |
| icon-class          | null                | If set, `<i class='some-class'></i>` will be prepended inside the button                    |
| disable-time-picker | false               | If set, the timepicker will be disabled and the default label format will be just the date |

**Example:**

```html
<datepicker ng-model='myDate' date-format='EEEE, MMMM d, yyyy' placeholder='Pick a Date' disable-time-picker />
```

## Configuration Options

If you want to use a different default for any of the inline options, you can do so by configuring the datepicker during your app's configuration phase. There are also several options that may only be configured in this way.

```javascript
app.config(function(ngQuickDateDefaultsProvider) {
  ngQuickDateDefaultsProvider.set('option', 'value');
  // Or with a hash
  ngQuickDateDefaultsProvider.set({option: 'value', option2: 'value2'});
})
```

| Option              | Default          | Description                                                                                         |
| ------------------- | ---------------- | --------------------------------------------------------------------------------------------------- |
| all inline options  | see above table  | Note that they must be in camelCase form.                                                           |
| buttonIconHtml      | null             | If you want to set a default button icon, set it to something like `<i class='icon-calendar'></i>`  |
| closeButtonHtml     | 'X'              | By default, the close button is just an X character. You may set it to an icon similar to `buttonIconHtml` |
| nextLinkHtml        | 'Next'           | By default, the next month link is just text. You may set it to an icon or image.                   |
| prevLinkHtml        | 'Prev'           | By default, the previous month link is just text. You may set it to an icon or image.               |
| dayAbbreviations    | (see below)      | The day abbreviations used in the top row of the calendar.                                          |
| parseDateFunction   | (see below)      | The function used to convert strings to date objects.                                               |

**Default Day Abbreviations:** `["Su", "M", "Tu", "W", "Th", "F", "Sa"]`

**Default Parse Date Function:**

```javascript
function(str) {
  var seconds = Date.parse(str);
  return isNaN(seconds) ? null : new Date(seconds);
}
```

## Smarter Date/Time Parsing

By default, dates and times entered into the 2 input boxes are parsed using javascript's built-in `Date.parse()` function. This function does not support many formats and can be inconsistent across platforms. I recommend using either the [Moment.js](http://momentjs.com) or [Date.js](http://www.datejs.com/) libraries instead. With Date.js, the parse method on the Date object is overwritten, so you don't need configure anything. With Moment.js, it is simple to configure:

    app.config(function(ngQuickDateDefaultsProvider) {
      ngQuickDateDefaultsProvider.set('parseDateFunction', function(str) {
        return moment(str).toDate();
      });
    })

While I don't like the fact that Date.js modifies the native Date object, it will allow you to parse relative dates ('Tomorrow', for example), less formal formats ('1pm'), and more. The parsing enhancements in Moment.js are more modest, but still much better than the built-in capabilities.

## Date Formatting

Note that when displaying dates in a well-formatted manner, Angular's [Date filter](http://docs.angularjs.org/api/ng.filter:date) is used. So if you want to customize these formats, please reference that link to see the formatting syntax. Date.js and Moment.js have their own formatting syntax that are different from Angular's.

## Styling

There is a very light set of styles that allow the datepicker to function, but isn't particularly pretty. From there you can either use the default theme that's included or you can easily write your own theme.

## Browser Support

So far, it has only been tested in Chrome. That will change soon.

## Contributions

Contributions are welcome. Whenever possible, please include test coverage with your contribution.

To get the project running, you'll need [NPM](https://npmjs.org/) and [Bower](http://bower.io/). Run `npm install` and `bower install` to install all dependencies. Then run `grunt` in the project directory to watch and compile changes. And you can run `karma start` to watch for changes and auto-execute unit tests.

## Potential Features down the road

* Optimize for Mobile (It works fine now, but it could be slightly improved)
