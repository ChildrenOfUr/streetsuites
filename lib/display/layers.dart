part of streetstage;


var loadOptions = new BitmapDataLoadOptions()
	..corsEnabled = true;

class DecoLayer extends Layer {
  String name;
  Map data;
  DecoLayer(this.name, this.data) {
    this.layerWidth = data['w'];
    this.layerHeight = data['h'];
  }
}

class GradientLayer extends Layer {
  Map streetData;
  GradientLayer(num width, num height, String top, String bottom) {

    Shape shape = new Shape();
    shape.graphics.rect(0, 0, width, height);
    var gradient = new GraphicsGradient.linear(0, 0, 0, height);
    gradient.addColorStop(0, int.parse('0xFF$top'));
    gradient.addColorStop(1, int.parse('0xFF$bottom'));
    shape.graphics.fillGradient(gradient);
    shape.applyCache(0, 0, width, height);
    BitmapData bitmapData = new BitmapData.fromRenderTextureQuad(shape.cache);
    Bitmap layerBitmap = new Bitmap(bitmapData);
    addChild(layerBitmap);

    layerWidth = layerBitmap.width;
    layerHeight = layerBitmap.height;
  }
}

abstract class Layer extends Sprite {
  num layerWidth;
  num layerHeight;
  Layer();
}
