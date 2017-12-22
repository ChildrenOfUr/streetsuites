part of streetstage;

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
