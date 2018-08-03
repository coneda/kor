describe('w-app', function() {

  beforeEach(function() {
    jasmine.Ajax.install();
    spec.ensureTagElement();
  });

  afterEach(function() {
    jasmine.Ajax.uninstall();
  });

  // it('should mount', function() {
  //   spec.mount('w-app');
  //   expect($('target').attr('data-is')).toEqual('w-app');
  // });

  // it('should make an ajax request to get session', function() {
  //   spec.mount('w-app');
  //   expect(jasmine.Ajax.requests.mostRecent().url).toBe('/session');
  // });

  // it('should show the login page when not authenticated', function() {
  //   spec.stubRequest('get', '/session', {});
  //   spec.mount('w-app');
  //   expect($('html').text()).toMatch(/Username/);
  //   expect($('html').text()).toMatch(/Password/);
  // });

  // it('should show search page when a guest user exists', function() {
  //   spec.stubRequest('get', '/session', {user: {guest: true}});
  //   spec.mount('w-app');
  //   expect($('html').text()).toMatch(/Search/);
  // });

});