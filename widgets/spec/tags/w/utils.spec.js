describe('utils', function() {

  it('should group arrays', function() {
    var a = [1,2,3,4];
    expect(wApp.utils.inGroupsOf(3, a)).toEqual([[1,2,3],[4]]);

    a = [1,2,3,4,5,6];
    expect(wApp.utils.inGroupsOf(3, a)).toEqual([[1,2,3],[4,5,6]]);

    a = [1,2,3];
    expect(wApp.utils.inGroupsOf(3, a)).toEqual([[1,2,3]]);

    a = [1,2];
    expect(wApp.utils.inGroupsOf(3, a)).toEqual([[1,2]]);

    a = [1,2];
    expect(wApp.utils.inGroupsOf(3, a, null)).toEqual([[1,2, null]]);
  });
});