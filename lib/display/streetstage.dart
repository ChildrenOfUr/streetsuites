library streetstage;
import 'package:stagexl/stagexl.dart';
import 'dart:html' as html;
import 'dart:math' as Math;
import 'dart:convert';

part 'camera.dart';
part 'layers.dart';
part 'street.dart';

ResourceManager resources = new ResourceManager();

class StreetStage extends Stage {
  static html.CanvasElement _stageCanvas = html.querySelector('#world');
  static RenderLoop _renderloop = new RenderLoop();


  Camera camera;

  static init() {
    StageXL.stageOptions
      ..antialias = true
      ..transparent = true
      ..backgroundColor = 0x00000000
      ..stageScaleMode = StageScaleMode.NO_SCALE
      ..stageAlign = StageAlign.TOP_LEFT;
    StageXL.bitmapDataLoadOptions.corsEnabled = true;
  }


  StreetStage(): super(_stageCanvas) {
    camera = new Camera(this);
    _renderloop.addStage(this);
  }

  setStreet(Street street) {
    if (Street.current != null) {
      stage
        ..removeChild(Street.current)
        ..juggler.remove(Street.current);
      Street.current.stage = null;
    }

    Street.current = street;

    stage
      ..addChild(Street.current)
      ..juggler.add(Street.current);

    street.stage = this;
  }

  String snap([BitmapFilter filter]) {
      if (filter != null) {
        filters.add(filter);
      }
      children.first.applyCache(
          0,
          0,
          camera.viewport.width,
          camera.viewport.height);
      String dataUrl = new BitmapData.fromRenderTextureQuad(
          children.first.cache).toDataUrl();
      if (filter != null) {
        children.first.filters.remove(filter);
      }
      children.first.removeCache();

      html.window.open(dataUrl, "_blank");
      return dataUrl;
    }

}
