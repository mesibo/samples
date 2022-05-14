flutter pub run pigeon \
  --input pigeons/MesiboPlugin.dart \
  --dart_out lib/MesiboPlugin.dart \
  --objc_header_out ios/Classes/MesiboPlugin.h \
  --objc_source_out ios/Classes/MesiboPlugin.m \
  --objc_prefix MesiboPlugin \
  --java_out android/app/src/main/java/com/mesibo/firstapp/MesiboPlugin.java \
  --java_package "com.mesibo.firstapp"
