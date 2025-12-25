import Flutter
import UIKit
import FamilyControls
import ManagedSettings
import DeviceActivity

public class FocusFlowPlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel
  private let blockingEngine = BlockingEngine.shared
  private let scheduleManager = ScheduleManager.shared
  private let websiteService = WebsiteBlockingService.shared
  private let notificationService = NotificationService.shared
  
  // App Selection logic from ViewModels/AppSelectionViewModel.swift
  private var activitySelection = FamilyActivitySelection()
  
  init(channel: FlutterMethodChannel) {
    self.channel = channel
    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.focusflow/channel", binaryMessenger: registrar.messenger())
    let instance = FocusFlowPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkAuthorizationStatus":
      let status = AuthorizationCenter.shared.authorizationStatus
      result(status == .approved)
      
    case "requestAuthorization":
      Task {
        do {
          // Check current status first
          let currentStatus = AuthorizationCenter.shared.authorizationStatus
          if currentStatus == .approved {
            result(nil)
            return
          }
          
          try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
          
          // Verify authorization was granted
          let newStatus = AuthorizationCenter.shared.authorizationStatus
          if newStatus == .approved {
            result(nil)
          } else {
            result(FlutterError(
              code: "AUTH_NOT_APPROVED",
              message: "Authorization was not approved. Status: \(newStatus)",
              details: nil
            ))
          }
        } catch {
          // Provide more helpful error messages
          let errorMessage: String
          if error.localizedDescription.contains("helper application") {
            errorMessage = "DeviceActivityMonitorExtension may not be properly configured. Please ensure the extension is added to your Xcode project and built."
          } else {
            errorMessage = error.localizedDescription
          }
          result(FlutterError(code: "AUTH_FAILED", message: errorMessage, details: nil))
        }
      }
      
    case "presentAppPicker":
      // Note: FamilyActivityPicker must be presented from a SwiftUI view or UIViewController
      // Since this is a plugin, we'll need to use the root view controller
      DispatchQueue.main.async {
        self.presentNativePicker(result: result)
      }
      
    case "getSelectedAppsCount":
      result(activitySelection.applicationTokens.count + activitySelection.categoryTokens.count)
      
    case "startFocusSession":
      guard let args = call.arguments as? [String: Any],
            let duration = args["duration"] as? Int else {
        result(FlutterError(code: "INVALID_ARGS", message: "Duration missing", details: nil))
        return
      }
      
      let websites = websiteService.loadBlockedWebsites()
      blockingEngine.blockAppsAndWebsites(selection: activitySelection, websites: websites)
      scheduleManager.scheduleSession(duration: TimeInterval(duration), selection: activitySelection)
      notificationService.scheduleSessionEndNotification(after: TimeInterval(duration))
      result(nil)
      
    case "endFocusSession":
      blockingEngine.unblockAll()
      scheduleManager.cancelAllSchedules()
      notificationService.cancelPendingNotifications()
      result(nil)
      
    case "emergencyUnblock":
      // Emergency unblock - use this if the app locked itself
      blockingEngine.unblockAll()
      scheduleManager.cancelAllSchedules()
      notificationService.cancelPendingNotifications()
      result(nil)
      
    case "saveBlockedWebsites":
      guard let args = call.arguments as? [String: Any],
            let jsonStr = args["websites"] as? String,
            let data = jsonStr.data(using: .utf8) else {
        result(FlutterError(code: "INVALID_ARGS", message: "Websites data missing", details: nil))
        return
      }
      
      do {
        let decoder = JSONDecoder()
        // We'll need the BlockedWebsite model to be accessible here
        // Assuming it was copied to Service directory
        let websites = try decoder.decode([BlockedWebsite].self, from: data)
        websiteService.saveBlockedWebsites(websites)
        result(nil)
      } catch {
        result(FlutterError(code: "DECODE_FAILED", message: error.localizedDescription, details: nil))
      }
      
    case "loadBlockedWebsites":
      let websites = websiteService.loadBlockedWebsites()
      do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(websites)
        result(String(data: data, encoding: .utf8))
      } catch {
        result(nil)
      }
      
    case "getStatistics":
      // Fetch stats from UserDefaults (as in StatisticsViewModel.swift)
      let defaults = UserDefaults(suiteName: "group.com.focusflow.shared") ?? UserDefaults.standard
      if let data = defaults.data(forKey: "completedSessions") {
        result(String(data: data, encoding: .utf8))
      } else {
        result(nil)
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func presentNativePicker(result: @escaping FlutterResult) {
    guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
      result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller", details: nil))
      return
    }
    
    NativePickerHelper.shared.presentPicker(from: rootViewController) { selection in
      self.activitySelection = selection
    }
    result(nil)
  }
}
