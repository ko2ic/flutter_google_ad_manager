
/// Banner Size of Google Ad Manger.
class DFPAdSize {
  final String _value;
  final double width;
  final double height;

  const DFPAdSize.custom({double width, double height}) : this._internal("CUSTOM", width: width, height: height);

  const DFPAdSize._internal(this._value, {this.width, this.height});

  toString() => _value;

  static const FULL_WIDTH = -1.0;
  static const AUTO_HEIGHT = -2.0;

  static const BANNER = const DFPAdSize._internal('BANNER', width: 320, height: 50);
  static const FULL_BANNER = const DFPAdSize._internal('FULL_BANNER', width: 468, height: 60);
  static const LARGE_BANNER = const DFPAdSize._internal('LARGE_BANNER', width: 320, height: 100);
  static const LEADERBOARD = const DFPAdSize._internal('LEADERBOARD', width: 720, height: 90);
  static const MEDIUM_RECTANGLE = const DFPAdSize._internal('MEDIUM_RECTANGLE', width: 300, height: 250);
  static const SMART_BANNER = const DFPAdSize._internal('SMART_BANNER', width: FULL_WIDTH, height: AUTO_HEIGHT);
}
