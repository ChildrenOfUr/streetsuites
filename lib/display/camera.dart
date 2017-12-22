part of streetstage;

class Camera extends TweenObject2D {
  StreetStage stage;
  Camera(this.stage);

  num _x = 0;
  num _y = 0;

  num get x {
    if (Street.current != null) {
      if (_x >= Street.current.bounds.width - viewport.width/2)
        return Street.current.bounds.width - viewport.width/2;
      if (_x <= viewport.width/2)
        return viewport.width/2;
    }
    return _x;
  }

  num get y {
    if (Street.current != null) {
      if (_y <= viewport.height/2)
        return viewport.height/2;
      if (_y >= Street.current.bounds.height - viewport.height/2)
        return Street.current.bounds.height - viewport.height/2;
    }
    return _y;
  }
  set x(num x) => _x = x;
  set y(num y) => _y = y;

  Rectangle get viewport =>
    new Rectangle(_x, _y,
      stage.stageWidth,
      stage.stageHeight);

  @override
  toString() => 'x:$x y:$y';
}
