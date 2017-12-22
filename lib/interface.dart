library interface;
import 'dart:html';

abstract class DropDownManager {
  static List<DropDown> dropDownFields = [];
  static start() {
    document.querySelectorAll('.drop-down').forEach((element) {
      dropDownFields.add(new DropDown(element));
    });
    dropDownFields.first.open();
  }
}

class DropDown {
  Element element;
  bool opened = false;

  DropDown(this.element) {
    element.querySelector('.header').onClick.listen((_) {
      if (opened) close();
      else open();
    });
  }

  close() {
    if (opened == false) return;
    element.querySelector('.fa').className = 'fa fa-chevron-up';
    element.classes.toggle('open');
    opened = false;
  }

  open() {
    if (opened) return;
    for (DropDown dd in DropDownManager.dropDownFields) {
      dd.close();
    };
    element.querySelector('.fa').className = 'fa fa-chevron-down';
    element.classes.toggle('open');
    opened = true;
  }

}
