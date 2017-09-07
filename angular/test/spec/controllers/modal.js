'use strict';

describe('Controller: ModalCtrl', function () {

  // load the controller's module
  beforeEach(module('redesign2017App'));

  var ModalCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ModalCtrl = $controller('ModalCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ModalCtrl.awesomeThings.length).toBe(3);
  });
});
