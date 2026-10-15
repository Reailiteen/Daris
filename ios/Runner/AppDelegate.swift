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

    let isBlocking = store.shield.applications != nil ||
                     store.shield.applicationCategories != nil ||
                     store.shield.webDomains != nil

    guard isBlocking else { return }

    // Never auto-unblock if a screen time credit session is active —
    // the user intentionally kept apps blocked.
    let screenTimeActive = UserDefaults(suiteName: "group.com.focusflow.shared")?
        .bool(forKey: "screenTimeSessionActive") ?? false
    if screenTimeActive {
      print("AppDelegate: Screen time session active — keeping blocks.")
      return
    }

    // Only auto-unblock if we're NOT in a focus session
    // (focus session state is managed by ScheduleManager / DeviceActivityMonitor).
    let focusActive = UserDefaults(suiteName: "group.com.focusflow.shared")?
        .bool(forKey: "isBlockingActive") ?? false
    if focusActive {
      print("AppDelegate: Focus session active — keeping blocks.")
      return
    }

    // Blocking is on but no session is active — stale state, clear it.
    print("AppDelegate: Stale blocking state detected — clearing shields.")
    BlockingEngine.shared.unblockAll()
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    // Mark when app enters background (properly backgrounded, not force-quit)
    UserDefaults.standard.set(Date(), forKey: "lastAppBackgroundTime")
    super.applicationDidEnterBackground(application)
  }
}
