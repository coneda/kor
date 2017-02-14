describe("w-modal", function() {
  var $ = Zepto;
  var tag = null;

  beforeEach(spec.ensureTagElement);
  beforeEach(function() {
    // spec.unmount(tag);
    riot.unregister('spec-sample')
  });
  // afterEach(function(){spec.unmount(tag)});

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
    expect($(tag.refs.receiver).width()).toEqual(850 + 16);
  });

  it('should use a scroll bar on vertical overflow', function() {
    riot.tag('spec-sample', '<div>tall</div>', '[data-is=spec-sample] div {height: 3200px}');
    tag = spec.mount('w-modal');
    wApp.bus.trigger('modal', 'spec-sample');
    expect($(tag.refs.receiver).height()).toEqual($(window).height() * 0.8);
  });

});