import 'dart:io';

main() {
  Directory scenery = new Directory('web/scenery');
  File sceneryCatalog = new File('web/scenery.txt');

  if (sceneryCatalog.existsSync()) {
    sceneryCatalog.deleteSync();
  }

  String fileText = '';
  for (FileSystemEntity fse in scenery.listSync()) {
    fileText = fileText + fse.path.split('/').last + '\n';
  };


  sceneryCatalog.createSync();
  sceneryCatalog.writeAsStringSync(fileText);
}
