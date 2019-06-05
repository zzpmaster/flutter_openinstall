#import <Flutter/Flutter.h>
#import "OpenInstallSDK.h"

@interface FlutterOpeninstallPlugin : NSObject<FlutterPlugin, OpenInstallDelegate>
@property FlutterMethodChannel *channel;
@end
