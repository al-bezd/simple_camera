## Example
```dart
import 'package:camera_test/classes/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:simple_camera/simple_camera.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SimpleCamera.initialize(navigatorKey: navigatorKey); // initialize

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, home: const HomeScreen());
  }
}
```

## Use
```dart
final takePhotoBtnWidget = ElevatedButton.icon(
  onPressed: () => SimpleCamera.show((XFile file) {
    files.value = [file, ...files.value];
  }),
  icon: takePhotoIcon,
  label: Text('take photo'),
);
```