import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

main() {
  FlutterDriver driver;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });
  tearDownAll(() {
    driver?.close();
  });

  final SerializableFinder _textField = find.byType('TextField');
  final SerializableFinder _circularProgressIndicator =
      find.byType('CircularProgressIndicator');
  final SerializableFinder _closeIcon = find.byValueKey('_closeIcon');
  final SerializableFinder _refreshIcon = find.byValueKey('_refreshIcon');
  final SerializableFinder _listView = find.byValueKey('_listView');
  final SerializableFinder _errorSnackBar = find.byValueKey('_errorSnackBar');

  test('testing app functionality', () async {
    await driver.tap(_textField);
    await driver.enterText('Молоко');
    await driver.waitFor(_circularProgressIndicator);
    await driver.waitFor(_listView);

    await driver.tap(_textField);
    await driver.tap(_closeIcon);

    await driver.tap(_textField);
    await driver.enterText('Конфеты');
    await driver.waitFor(_circularProgressIndicator);
    await driver.waitFor(_listView);

    await driver.tap(_textField);
    await driver.tap(_closeIcon);

    await driver.tap(_textField);
    await driver.enterText('   ');
    await driver.waitFor(_circularProgressIndicator);
    await driver.waitFor(_errorSnackBar);

    await driver.tap(_textField);
    await driver.tap(_refreshIcon);
    await driver.waitFor(_circularProgressIndicator);
    await driver.waitFor(_errorSnackBar);
  });
}
