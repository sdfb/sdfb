'use strict';

describe('Controller: ModalinstanceCtrl', function () {

  // load the controller's module
  beforeEach(module('redesign2017App'));

  var ModalinstanceCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ModalinstanceCtrl = $controller('ModalinstanceCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ModalinstanceCtrl.awesomeThings.length).toBe(3);
  });
});
