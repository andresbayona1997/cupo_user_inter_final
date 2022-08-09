import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel* flavorChannel = [FlutterMethodChannel methodChannelWithName:@"flavor" binaryMessenger:controller];
    [flavorChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    NSString* flavor = (NSString*)[[NSBundle mainBundle].infoDictionary valueForKey:@"Flavor"];
    result(flavor);
    }];
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
