import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
        
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let passwordManagerData = FlutterMethodChannel(name: "myPasswordManagerData",
                                                       binaryMessenger: controller.binaryMessenger)
        
        passwordManagerData.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard call.method == "storePasswordData" else {
                result(FlutterMethodNotImplemented)
                return
            }
            if let dataFound = call.arguments as? NSDictionary {
                if let stringFound = dataFound.value(forKey: "password") as? String {
                    do {
                        let passwordData = try JSONDecoder().decode([PasswordManagerData].self, from: stringFound.data(using: .utf8)!)
                        do {
                            let encoder = JSONEncoder()
                            let data = try encoder.encode(passwordData)
                            let defaults = UserDefaults(suiteName: "group.com.pcryptApp")
                            defaults?.set(data, forKey: "passwordData")
                        } catch {
                            print("Unable to Encode Array of Notes (\(error))")
                        }
                    } catch {
                        let defaults = UserDefaults(suiteName: "group.com.pcryptApp")
                        defaults?.removeObject(forKey: "passwordData")
                        print(error)
                    }
                } else if let logoutData = dataFound.value(forKey: "password") as? [Any] {
                    let defaults = UserDefaults(suiteName: "group.com.pcryptApp")
                    defaults?.removeObject(forKey: "passwordData")
                }
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        //window.resignKey()
         //window.isHidden = true
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        //window.makeKeyAndVisible()
        //window.isHidden = false
    }
    
}

extension FlutterViewController {
    open override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
    }
    
    open override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
    }
    
    open override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesCancelled(presses, with: event)
    }
}
