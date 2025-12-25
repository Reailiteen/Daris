import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/website_blocking_controller.dart';
import '../../../data/models/blocked_website.dart';

class WebsiteBlockingView extends GetView<WebsiteBlockingController> {
  const WebsiteBlockingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(isDark),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildList(context, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Websites',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                'Manage blocked domains',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
          IconButton.filledTonal(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.blockedWebsites.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public_off, size: 64, color: Colors.grey.withOpacity(0.3)),
              const SizedBox(height: 16),
              const Text('No websites blocked yet', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: controller.blockedWebsites.length,
        itemBuilder: (context, index) {
          final website = controller.blockedWebsites[index];
          return _WebsiteListItem(website: website);
        },
      );
    });
  }

  void _showAddDialog(BuildContext context) {
    // Basic dialog to add a website
    final domainController = TextEditingController();
    final nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Blocked Website'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Display Name (e.g. Twitter)'),
            ),
            TextField(
              controller: domainController,
              decoration: const InputDecoration(labelText: 'Domain (e.g. twitter.com)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (domainController.text.isNotEmpty && nameController.text.isNotEmpty) {
                controller.addWebsite(BlockedWebsite(
                  domain: domainController.text,
                  displayName: nameController.text,
                ));
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _WebsiteListItem extends GetView<WebsiteBlockingController> {
  final BlockedWebsite website;

  const _WebsiteListItem({required this.website});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: website.category.icon == Icons.public 
                ? AppColors.accentBlue.withOpacity(0.1)
                : AppColors.accentPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(website.category.icon, size: 24, color: AppColors.accentPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  website.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  website.formattedDomain,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: website.isEnabled,
            onChanged: (_) => controller.toggleWebsite(website.id),
            activeColor: AppColors.accentPurple,
          ),
          IconButton(
            onPressed: () => controller.removeWebsite(website.id),
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }
}
