'use strict';

describe('Controller: VisualizationCtrl', function () {

  // load the controller's module
  beforeEach(module('redesign2017App'));

  var VisualizationCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    VisualizationCtrl = $controller('VisualizationCtrl', {
      $scope: scope
      // place here mocked dependencies
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(VisualizationCtrl.awesomeThings.length).toBe(3);
  });
});
