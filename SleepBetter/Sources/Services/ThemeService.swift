import Foundation

final class ThemeService {
    static let shared = ThemeService()

    private let themeKey = "app_theme"

    private init() {}

    var isDarkMode: Bool {
        get { UserDefaults.standard.bool(forKey: themeKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: themeKey)
            applyTheme()
        }
    }

    func applyTheme() {
        if isDarkMode {
            UIColor.applyDarkTheme()
        } else {
            UIColor.applyLightTheme()
        }
    }

    func toggleTheme() {
        isDarkMode.toggle()
    }
}

import UIKit

extension UIColor {
    static var primaryColor: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "#6366F1")
                : UIColor(hex: "#4F46E5")
        }
    }

    static var secondaryColor: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "#818CF8")
                : UIColor(hex: "#6366F1")
        }
    }

    static var accentColor: UIColor {
        return UIColor(hex: "#A78BFA")
    }

    static var backgroundColor: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "#0F0F23")
                : UIColor(hex: "#F8FAFC")
        }
    }

    static var cardBackground: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "#1E1E3F")
                : UIColor(hex: "#FFFFFF")
        }
    }

    static var textPrimary: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "#F1F5F9")
                : UIColor(hex: "#1E293B")
        }
    }

    static var textSecondary: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "#94A3B8")
                : UIColor(hex: "#64748B")
        }
    }

    static var successColor: UIColor {
        return UIColor(hex: "#10B981")
    }

    static var warningColor: UIColor {
        return UIColor(hex: "#F59E0B")
    }

    static var errorColor: UIColor {
        return UIColor(hex: "#EF4444")
    }

    static var sleepDeepColor: UIColor {
        return UIColor(hex: "#3B82F6")
    }

    static var sleepLightColor: UIColor {
        return UIColor(hex: "#60A5FA")
    }

    static var sleepRemColor: UIColor {
        return UIColor(hex: "#A78BFA")
    }

    static func applyDarkTheme() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
    }

    static func applyLightTheme() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
    }

    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}