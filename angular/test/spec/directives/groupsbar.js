'use strict';

describe('Directive: groupsBar', function () {

  // load the directive's module
  beforeEach(module('redesign2017App'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<groups-bar></groups-bar>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the groupsBar directive');
  }));
});
