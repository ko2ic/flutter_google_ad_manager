import Foundation

class BannerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger!

    init(messenger: FlutterBinaryMessenger) {
        super.init()
        self.messenger = messenger
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments _: Any?) -> FlutterPlatformView {
        return BannerView(frame: frame, viewIdentifier: viewId, messenger: messenger)
    }
}
