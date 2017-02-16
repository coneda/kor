describe("w-modal", function() {
  var tag = null;

  beforeEach(spec.ensureTagElement);
  beforeEach(function() {
    riot.unregister('spec-sample')
  });

  it('should show a tag with options', function() {
    riot.tag('spec-sample', '<p>hello {opts.person}</p>');
    tag = spec.mount('w-modal');
    wApp.bus.trigger('modal', 'spec-sample', {person: 'John Doe'});
    expect($('context').text()).toMatch('hello John Doe');
  });

  it('should close', function() {
    riot.tag('spec-sample', '<p>hello</p>');
    tag = spec.mount('w-modal');
    wApp.bus.trigger('modal', 'spec-sample', {person: 'John Doe'});
    tag.trigger('close');
    expect($('context').text()).not.toMatch('hello John Doe');
  });

  it('should widen with the mounted content', function() {
    riot.tag('spec-sample', '<div>wide</div>', '[data-is=spec-sample] div {width: 850px}');
    tag = spec.mount('w-modal');
    wApp.bus.trigger('modal', 'spec-sample');
    expect($(tag.refs.receiver).width()).toBeGreaterThan(850 + 10);
    expect($(tag.refs.receiver).width()).toBeLessThan(850 + 20);
  });

  it('should use a scroll bar on vertical overflow', function() {
    riot.tag('spec-sample', '<div>tall</div>', '[data-is=spec-sample] div {height: 3200px}');
    tag = spec.mount('w-modal');
    wApp.bus.trigger('modal', 'spec-sample');
    var targetHeight = Math.floor($(window).height() * 0.8);
    expect($(tag.refs.receiver).height()).toBeLessThan(targetHeight + 5);
    expect($(tag.refs.receiver).height()).toBeGreaterThan(targetHeight - 5);
  });

});