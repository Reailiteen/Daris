import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../models/blocked_website.dart';
import 'dart:convert';

class FocusFlowService extends GetxService {
  static const MethodChannel _channel = MethodChannel(AppConstants.channelName);

  // MARK: - Authorization
  
  Future<bool> checkAuthorizationStatus() async {
    try {
      final bool status = await _channel.invokeMethod('checkAuthorizationStatus');
      return status;
    } on PlatformException catch (e) {
      print("Failed to check authorization: ${e.message}");
      return false;
    }
  }

  Future<void> requestAuthorization() async {
    try {
      await _channel.invokeMethod('requestAuthorization');
    } on PlatformException catch (e) {
      // Only log if it's not the "helper application" error (extension not configured)
      // This prevents spam when extensions aren't set up yet
      if (!e.message.toString().contains('helper application')) {
        print("Failed to request authorization: ${e.message}");
      }
      // Re-throw to let the controller handle it
      rethrow;
    }
  }

  // MARK: - App Selection

  Future<void> presentAppPicker() async {
    try {
      await _channel.invokeMethod('presentAppPicker');
    } on PlatformException catch (e) {
      print("Failed to present app picker: ${e.message}");
    }
  }

  Future<int> getSelectedAppsCount() async {
    try {
      final int count = await _channel.invokeMethod('getSelectedAppsCount');
      return count;
    } on PlatformException catch (e) {
      print("Failed to get app count: ${e.message}");
      return 0;
    }
  }

  // MARK: - Focus Session

  Future<void> startFocusSession(int durationSeconds) async {
    try {
      await _channel.invokeMethod('startFocusSession', {'duration': durationSeconds});
    } on PlatformException catch (e) {
      print("Failed to start focus session: ${e.message}");
    }
  }

  Future<void> endFocusSession() async {
    try {
      await _channel.invokeMethod('endFocusSession');
    } on PlatformException catch (e) {
      print("Failed to end focus session: ${e.message}");
    }
  }

  // MARK: - Website Blocking

  Future<void> saveBlockedWebsites(List<BlockedWebsite> websites) async {
    try {
      final String jsonStr = jsonEncode(websites.map((e) => e.toJson()).toList());
      await _channel.invokeMethod('saveBlockedWebsites', {'websites': jsonStr});
    } on PlatformException catch (e) {
      print("Failed to save websites: ${e.message}");
    }
  }

  Future<List<BlockedWebsite>> loadBlockedWebsites() async {
    try {
      final String? jsonStr = await _channel.invokeMethod('loadBlockedWebsites');
      if (jsonStr == null || jsonStr.isEmpty) return [];
      
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => BlockedWebsite.fromJson(e)).toList();
    } on PlatformException catch (e) {
      print("Failed to load websites: ${e.message}");
      return [];
    }
  }

  // MARK: - Statistics

  Future<String?> getStatistics() async {
    try {
      return await _channel.invokeMethod('getStatistics');
    } on PlatformException catch (e) {
      print("Failed to get statistics: ${e.message}");
      return null;
    }
  }
}
