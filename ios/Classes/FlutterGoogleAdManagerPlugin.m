#import "FlutterGoogleAdManagerPlugin.h"
#import <flutter_google_ad_manager/flutter_google_ad_manager-Swift.h>

@implementation FlutterGoogleAdManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterGoogleAdManagerPlugin registerWithRegistrar:registrar];
}
@end
