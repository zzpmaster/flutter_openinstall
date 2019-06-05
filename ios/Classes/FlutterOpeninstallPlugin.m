#import "FlutterOpeninstallPlugin.h"
#import "OpenInstallSDK.h"

static NSObject <FlutterPluginRegistrar> *_registrar;

@implementation FlutterOpeninstallPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  _registrar = registrar;
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_openinstall"
            binaryMessenger:[registrar messenger]];
  FlutterOpeninstallPlugin* instance = [[FlutterOpeninstallPlugin alloc] init];
  instance.channel = channel;
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"setup" isEqualToString:call.method]) {
    [self setup:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)setup:(FlutterMethodCall*)call result:(FlutterResult)result {
    
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [OpenInstallSDK initWithDelegate: self];
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    //判断是否通过OpenInstall Universal Link 唤起App
    if ([OpenInstallSDK continueUserActivity:userActivity]){//如果使用了Universal link ，此方法必写
        return YES;
    }
    //其他第三方回调；
    return YES;
}

-(void)getWakeUpParams:(OpeninstallData *)appData{
    NSString *getData;
    if (appData.data) {
        //如果有中文，转换一下方便展示
        getData = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:appData.data options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    NSString *parameter = [NSString stringWithFormat:@"如果没有任何参数返回，请确认：\n"
                           @"是否通过含有动态参数的分享链接(或二维码)安装的app\n\n动态参数：\n%@\n渠道编号：%@",
                           getData,appData.channelCode];
    NSLog(@"%@", getData);
    [_channel invokeMethod:@"onWakeupNotification" arguments:appData.data];
}

@end
