'use strict';

describe('Controller: ModalhandlerCtrl', function () {

  // load the controller's module
  beforeEach(module('redesign2017App'));

  var ModalhandlerCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ModalhandlerCtrl = $controller('ModalhandlerCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(ModalhandlerCtrl.awesomeThings.length).toBe(3);
  });
});
