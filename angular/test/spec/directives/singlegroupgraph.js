'use strict';

describe('Directive: singleGroupGraph', function () {

  // load the directive's module
  beforeEach(module('redesign2017App'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<single-group-graph></single-group-graph>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the singleGroupGraph directive');
  }));
});
