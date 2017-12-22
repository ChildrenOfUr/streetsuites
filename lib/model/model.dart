library street.model;

import 'dart:convert';

/// A model of a street that can be generated from a json file, or created new.
class StreetModel {
  int width = 1920;
  int height = 1080;
  String uuid;
  String label = 'Untitled Street';
  GradientModel gradient = new GradientModel();
  List<LayerModel> decoLayers = [];

  Map _internalUse = {};

  StreetModel() {
    new LayerModel(this)..name = 'middleground';
  }

  StreetModel.fromJSON(String json) {
    bool legacyMode = false;
    Map streetMap = JSON.decode(json);
    // legacy streets have tsid instead of uuid
    if (streetMap.keys.contains('tsid')) legacyMode = true;
    if (legacyMode) {
      width =
          (streetMap['dynamic']['l']).abs() + (streetMap['dynamic']['r']).abs();
      height =
          (streetMap['dynamic']['t']).abs() + (streetMap['dynamic']['b']).abs();
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
      layerMaps = new List.from(streetMap['dynamic']['layers'].values);
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
          if (decoMap['h_flip'] == true) deco.width = -deco.width;
          if (decoMap['v_flip'] == true) deco.height = -deco.height;
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
