import Flutter
import UIKit
import ManagedSettings

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FocusFlowPlugin.register(with: self.registrar(forPlugin: "FocusFlowPlugin")!)
    
    // SAFETY: Check if FocusFlow blocked itself and unblock if needed
    // This ensures the app can always recover from self-blocking
    checkAndUnblockIfNeeded()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  /// CRITICAL SAFETY: Prevent FocusFlow from permanently blocking itself
  /// This checks if the app was force-quit while blocking and unblocks if needed
  private func checkAndUnblockIfNeeded() {
    let store = ManagedSettingsStore()
    let defaults = UserDefaults.standard
    
    // Check if blocking is currently active
    let isBlocking = store.shield.applications != nil || 
                     store.shield.applicationCategories != nil || 
                     store.shield.webDomains != nil
    
    if isBlocking {
      // Check if app was properly backgrounded (has recent background time)
      // vs. force-quit (no recent background time)
      let lastBackgroundTime = defaults.object(forKey: "lastAppBackgroundTime") as? Date
      let now = Date()
      
      // If there's no recent background time, the app was likely force-quit
      // In this case, unblock everything to prevent permanent self-lock
      if lastBackgroundTime == nil || now.timeIntervalSince(lastBackgroundTime!) > 60.0 {
        print("AppDelegate: ⚠️ SAFETY CHECK - App may have been force-quit while blocking.")
        print("AppDelegate: Unblocking all apps to prevent FocusFlow from being permanently locked.")
        BlockingEngine.shared.unblockAll()
      } else {
        // App was properly backgrounded, don't unblock (focus session is still active)
        print("AppDelegate: Blocking active, but app was properly backgrounded. Keeping blocks.")
      }
    }
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    // Mark when app enters background (properly backgrounded, not force-quit)
    UserDefaults.standard.set(Date(), forKey: "lastAppBackgroundTime")
    super.applicationDidEnterBackground(application)
  }
}
