/// In the case of the test mode, the class that holds the test device id for display on the real device.
abstract class TestDevices {

  /// Return Test Devices ID.
  /// Implement as follows.
  ///
  ///    class MyTestDevices extends TestDevices {
  ///      static MyTestDevices _instance;
  ///
  ///      factory MyTestDevices() {
  ///        if (_instance == null) _instance = new MyTestDevices._internal();
  ///          return _instance;
  ///      }
  ///
  ///      MyTestDevices._internal();
  ///
  ///      @override
  ///      List<String> get values => List()..add("33BE2250B43518CCDA7DE426D04EE231");
  ///    }
  List<String> get values;
}
