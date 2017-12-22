import 'dart:html';
import 'dart:convert';
import 'package:streetsuites/interface.dart';
import 'package:streetsuites/display/keyboard.dart';
import 'package:streetsuites/display/streetstage.dart';


StreetStage stage = new StreetStage();

main() async {
  DropDownManager.start();
  StreetStage.init();

  resources.addTextFile('forest.json', 'forest.json');
  await resources.load();
  Map def = JSON.decode(resources.getTextFile('forest.json'));

  Street street = new Street(def);
  await street.load();
  stage.setStreet(street);

  await Keyboard.init();
  loop();
}

loop() async {
  int newX = stage.camera.x;
  int newY = stage.camera.y;

  if (Keyboard.pressed(37)) {
    newX -= 20;
  }
  if (Keyboard.pressed(38)) {
    newY -= 20;
  }
  if (Keyboard.pressed(39)) {
    newX += 20;
  }
  if (Keyboard.pressed(40)) {
    newY += 20;
  }

  if (newX != stage.camera.x || newY != stage.camera.y) {
    stage.camera.x = newX;
    stage.camera.y = newY;
  }
  await window.animationFrame;
  loop();
}
