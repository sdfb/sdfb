'use strict';

describe('Controller: ModalHandlerCtrl', function () {

  // load the controller's module
  beforeEach(module('redesign2017App'));

  var ModalHandlerCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ModalHandlerCtrl = $controller('ModalHandlerCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ModalHandlerCtrl.awesomeThings.length).toBe(3);
  });
});
