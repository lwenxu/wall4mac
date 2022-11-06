import AppKit

public enum Wallpaper {
    public enum Screen {
        case all
        case main
        case index(Int)
        case nsScreens([NSScreen])

        fileprivate var nsScreens: [NSScreen] {
            switch self {
            case .all:
                return NSScreen.screens
            case .main:
                guard let mainScreen = NSScreen.main else {
                    return []
                }

                return [mainScreen]
            case .index(let index):
                guard let screen = NSScreen.screens[safe: index] else {
                    return []
                }

                return [screen]
            case .nsScreens(let nsScreens):
                return nsScreens
            }
        }
    }

    public enum Scale: String, CaseIterable {
        case auto
        case fill
        case fit
        case stretch
        case center
    }

    /**
    Set an image URL as wallpaper.
    */
    public static func set(_ image: URL, screen: Screen = .all, scale: Scale = .auto, fillColor: NSColor? = nil) throws {
        
        var options = [NSWorkspace.DesktopImageOptionKey: Any]()

        switch scale {
        case .auto:
            break
        case .fill:
            options[.imageScaling] = NSImageScaling.scaleProportionallyUpOrDown.rawValue
            options[.allowClipping] = true
        case .fit:
            options[.imageScaling] = NSImageScaling.scaleProportionallyUpOrDown.rawValue
            options[.allowClipping] = false
        case .stretch:
            options[.imageScaling] = NSImageScaling.scaleAxesIndependently.rawValue
            options[.allowClipping] = true
        case .center:
            options[.imageScaling] = NSImageScaling.scaleNone.rawValue
            options[.allowClipping] = false
        }

        options[.fillColor] = fillColor

        for nsScreen in screen.nsScreens {
            try NSWorkspace.shared.setDesktopImageURL(image, for: nsScreen, options: options)
        }
    }

}
