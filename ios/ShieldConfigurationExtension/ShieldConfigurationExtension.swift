import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Shield Configuration Extension for customizing the block screen
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    // MARK: - Shield Configuration for Applications
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return createShieldConfiguration(
            title: "Stay Focused",
            subtitle: "This app is blocked during your focus session",
            icon: application.token
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return createShieldConfiguration(
            title: "Stay Focused",
            subtitle: "Apps in this category are blocked during your focus session",
            icon: application.token
        )
    }
    
    // MARK: - Shield Configuration for Web Domains
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return createShieldConfiguration(
            title: "Website Blocked",
            subtitle: "This website is blocked during your focus session",
            icon: nil
        )
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return createShieldConfiguration(
            title: "Website Blocked",
            subtitle: "Websites in this category are blocked during your focus session",
            icon: nil
        )
    }
    
    // MARK: - Helper Methods
    
    /// Create a customized shield configuration
    private func createShieldConfiguration(
        title: String,
        subtitle: String,
        icon: ApplicationToken?
    ) -> ShieldConfiguration {
        // Create calm, focus-oriented colors
        let backgroundColor = UIColor(
            red: 88/255,
            green: 86/255,
            blue: 214/255,
            alpha: 1.0
        ) // Purple-ish
        
        let labelTextColor = UIColor.white
        let secondaryTextColor = UIColor.white.withAlphaComponent(0.8)
        
        // Create the configuration
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: backgroundColor,
            icon: icon,
            title: ShieldConfiguration.Label(
                text: title,
                color: labelTextColor
            ),
            subtitle: ShieldConfiguration.Label(
                text: subtitle,
                color: secondaryTextColor
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Okay",
                color: labelTextColor
            ),
            primaryButtonBackgroundColor: UIColor.white.withAlphaComponent(0.2),
            secondaryButtonLabel: nil
        )
    }
    
    /// Get a motivational message
    private func getMotivationalMessage() -> String {
        let messages = [
            "You're doing great! Keep focusing.",
            "Stay strong - you've got this!",
            "Every minute of focus counts.",
            "Your future self will thank you.",
            "Distractions can wait.",
            "Focus is your superpower.",
            "You chose to focus for a reason.",
            "Almost there - keep going!"
        ]
        return messages.randomElement() ?? messages[0]
    }
}

// MARK: - Additional Shield Action Handling
extension ShieldConfigurationExtension {
    /// Handle when user taps the primary button
    /// Note: This doesn't actually get called in the extension,
    /// but shows how you might handle actions
    func handlePrimaryButtonTap() {
        // User acknowledged the shield
        // Could log this for statistics
    }
}
