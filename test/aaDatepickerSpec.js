'use strict';

describe('aaDatepickerLib', function() {
  beforeEach(angular.mock.module('aaDatepickerLib'));

  describe('aaDatepicker', function() {
    it('should show the placeholder text in the button if the model is null', angular.mock.inject(function($compile, $rootScope) {
      $rootScope.date1 = null;
      var element = $compile("<aa-datepicker placeholder='Choose a Date' ng-model='date1' />")($rootScope);
      $rootScope.$digest();
      expect(angular.element(element.children()[0]).text()).toEqual('Choose a Date');
    }));
    it('should show the date string in MM/DD/YYYY format if the model is a date', angular.mock.inject(function($compile, $rootScope) {
      $rootScope.date1 = new Date(2013, 9, 25); // October 25, 2013
      var element = $compile("<aa-datepicker placeholder='Choose a Date' ng-model='date1' />")($rootScope);
      $rootScope.$digest();
      expect(angular.element(element.children()[0]).text()).toEqual('10/25/2013');
    }));
  });
});
