part of streetstage;

/// A model of a street that can be generated from a json file, or created new.
class StreetModel  {
  int width = 1920;
  int height = 1080;
  String uuid;
  String label = 'Untitled Street';
  GradientModel gradient = new GradientModel();
  List<LayerModel> decoLayers = [];

  Map _internalUse = {};

  StreetModel() {
    new LayerModel(this)
      ..name = 'middleground';
  }

  StreetModel.fromJSON(String json) {
    bool legacyMode = false;
    Map streetMap = JSON.decode(json);
    // legacy streets have tsid instead of uuid
    if (streetMap.keys.contains('tsid')) legacyMode = true;
    if (legacyMode) {
      width = (streetMap['dynamic']['l']).abs() + (streetMap['dynamic']['r']).abs();
      height = (streetMap['dynamic']['t']).abs() + (streetMap['dynamic']['b']).abs();
      _internalUse['legacyL'] = streetMap['dynamic']['l'];
      _internalUse['legacyT'] = streetMap['dynamic']['t'];
      _internalUse['legacyGroundY'] = streetMap['dynamic']['ground_y'];
      uuid = streetMap['tsid'];
    } else {
      width = streetMap['w'];
      height = streetMap['h'];
      uuid = streetMap['uuid'];
    }

    label = streetMap['label'];

    gradient
      ..top = streetMap['gradient']['top']
      ..bottom = streetMap['gradient']['bottom'];

    List layerMaps;
    if (legacyMode) {
      layerMaps = new List.from(streetMap['layers'].values);
      layerMaps.sort((Map A, Map B) => A['z'].compareTo(B['z']));
    } else {
      // non-legacy streets have their layer's z values based on list order
      layerMaps = streetMap['layers'];
    }
    for (Map layerMap in layerMaps) {
      LayerModel layer = new LayerModel(this)
        ..name = layerMap['name']
        ..width = layerMap['w']
        ..height = layerMap['h'];

      for (Map decoMap in layerMap['decos']) {
        DecoModel deco = new DecoModel()
          ..filename = decoMap['filename']
          ..position.x = decoMap['x']
          ..position.y = decoMap['y']
          ..position.z = decoMap['z']
          ..width = decoMap['w']
          ..height = decoMap['h'];

        // legacy decos have flipping
        if (legacyMode) {
          if (decoMap['h_flip'] == true)
            deco.width = -deco.width;
          if (decoMap['v_flip'] == true)
            deco.height = -deco.height;
        }

        // add to the layer
        layer.decos.add(deco);
      }
    }


  }
}

class GradientModel {
  String top = 'CCCCCC';
  String bottom = 'FFFFFF';
}

class LayerModel {
  String name = 'new layer';
  int width;
  int height;
  List<FilterModel> filters = [];
  List<DecoModel> decos = [];

  LayerModel(StreetModel parent) {
    width = parent.width;
    height = parent.height;
    parent.decoLayers.add(this);
  }
}

class FilterModel {
  String filter;
  int value;
}

class DecoModel {
  String filename;
  int width;
  int height;
  int rotation;
  DecoPosition position = new DecoPosition();
}

class DecoPosition {
  int x;
  int y;
  int z;
}


class Street extends DisplayObjectContainer with Animatable {
  StreetStage stage;
  static Street current;
  Map streetData;

  bool legacyMode = true;

  Rectangle _bounds;
  @override
  Rectangle get bounds => _bounds;

  String get tsid => streetData['tsid'];
  num get groundY => -(streetData['dynamic']['ground_y'] as num).abs();

  // Constructor
  Street(this.streetData) {
    _bounds = new Rectangle(
        streetData['dynamic']['l'],
        streetData['dynamic']['t'],
        (streetData['dynamic']['l'].abs() + streetData['dynamic']['r'].abs())
            .toInt(),
        (streetData['dynamic']['t'].abs() + streetData['dynamic']['b'].abs())
            .toInt());
  }

  load() async {
    // Create gradient layer
    String top = streetData['gradient']['top'];
    String bottom = streetData['gradient']['bottom'];
    addChild(new GradientLayer(_bounds.width, _bounds.height, top, bottom));

    List<DecoLayer> layers = [];
    // Generate empty layer sprites
    for (String layerName in streetData['dynamic']['layers'].keys) {
      Map decoMap = streetData['dynamic']['layers'][layerName];
      DecoLayer decoLayer = new DecoLayer(layerName, decoMap);
      layers.add(decoLayer);
    }

    // sort them by starting z value
    layers
        .sort((DecoLayer A, DecoLayer B) => A.data['z'].compareTo(B.data['z']));

    // load present Decos into memory.
    for (DecoLayer layer in layers) {
      List decoList = new List.from(layer.data['decos'])
        ..sort((Map A, Map B) => A['z'].compareTo(B['z']));

      for (Map decoMap in decoList) {
        if (!resources.containsBitmapData(decoMap['filename'])) {
          resources.addBitmapData(
              decoMap['filename'], 'scenery/' + decoMap['filename'] + '.png');
        }
        await resources.load();
      }

      for (Map decoMap in decoList) {
        Bitmap deco = new Bitmap(resources.getBitmapData(decoMap['filename']));
        deco.pivotX = deco.width / 2;
        deco.pivotY = deco.height;
        deco.x = decoMap['x'];
        deco.y = decoMap['y'];

        // Set width
        if (decoMap['h_flip'] == true)
          deco.width = -decoMap['w'];
        else
          deco.width = decoMap['w'];
        // Set height
        if (decoMap['v_flip'] == true)
          deco.height = -decoMap['h'];
        else
          deco.height = decoMap['h'];

        if (decoMap['r'] != null) {
          deco.rotation = decoMap['r'] * Math.PI / 180;
        }
        layer.addChild(deco);
      }
      addChild(layer);
    }
  }

  advanceTime(_) async {
    if (stage != null) {
      await html.window.animationFrame;
      for (Layer layer in children) {
        num currentPercentX =
            (stage.camera.x - stage.camera.viewport.width / 2) /
                (_bounds.width - stage.camera.viewport.width);
        num currentPercentY =
            (stage.camera.y - stage.camera.viewport.height / 2) /
                (_bounds.height - stage.camera.viewport.height);
        num offsetX =
            (layer.layerWidth - stage.camera.viewport.width) * currentPercentX;
        num offsetY = (layer.layerHeight - stage.camera.viewport.height) *
            currentPercentY;
        layer.x = -offsetX;
        layer.y = -offsetY;

        if (layer is DecoLayer && layer.name == 'middleground') {
          layer.x = -offsetX - _bounds.left;
          layer.y = -offsetY - _bounds.top;
        } else {
          layer.x = -offsetX;
          layer.y = -offsetY;
        }
      }
    }
  }
}
