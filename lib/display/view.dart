library street.view;

import 'package:streetsuites/model/model.dart';
import 'package:stagexl/stagexl.dart';
import 'dart:html' as html;


ResourceManager resources = new ResourceManager();

class StreetView extends Stage {
  static html.CanvasElement _stageCanvas = html.querySelector('#world');
  static RenderLoop _renderloop = new RenderLoop();

  StreetModel model;
  Sprite view = new Sprite();

  GradientView gradient = new GradientView();

  StreetView() : super(_stageCanvas) {
    StageXL.stageOptions
      ..antialias = true
      ..transparent = true
      ..backgroundColor = 0x00000000
      ..stageScaleMode = StageScaleMode.NO_SCALE
      ..stageAlign = StageAlign.TOP_LEFT;
    StageXL.bitmapDataLoadOptions.corsEnabled = true;
    children.add(view);
    _renderloop.addStage(this);

    view.addChild(gradient);
  }

  attach(StreetModel streetModel) {
    model = streetModel;
    gradient.set(model.width, model.height, model.gradient.top, model.gradient.bottom);
  }
}

class GradientView extends Sprite {
  Bitmap bitmap = new Bitmap();

  GradientView() {
    addChild(bitmap);
  }
  set(num width, num height,String top, String bottom) {
    if (bitmap.bitmapData != null) bitmap.bitmapData.renderTexture.dispose();
    Shape shape = new Shape();
    shape.graphics.rect(0, 0, width, height);
    var gradient = new GraphicsGradient.linear(0, 0, 0, height);
    gradient.addColorStop(0, int.parse('0xFF$top'));
    gradient.addColorStop(1, int.parse('0xFF$bottom'));
    shape.graphics.fillGradient(gradient);
    shape.applyCache(0, 0, width, height);
    bitmap.bitmapData = new BitmapData.fromRenderTextureQuad(shape.cache);
  }
}
