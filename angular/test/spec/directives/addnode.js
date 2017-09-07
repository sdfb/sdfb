'use strict';

describe('Directive: addNode', function () {

  // load the directive's module
  beforeEach(module('redesign2017App'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<add-node></add-node>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the addNode directive');
  }));
});
