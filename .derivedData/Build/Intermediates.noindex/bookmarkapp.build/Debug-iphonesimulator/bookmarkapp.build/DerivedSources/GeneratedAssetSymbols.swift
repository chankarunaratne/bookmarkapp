import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "LaunchLogo" asset catalog image resource.
    static let launchLogo = DeveloperToolsSupport.ImageResource(name: "LaunchLogo", bundle: resourceBundle)

    /// The "appicon" asset catalog image resource.
    static let appicon = DeveloperToolsSupport.ImageResource(name: "appicon", bundle: resourceBundle)

    /// The "book-search-banner" asset catalog image resource.
    static let bookSearchBanner = DeveloperToolsSupport.ImageResource(name: "book-search-banner", bundle: resourceBundle)

    /// The "book-thumbnail-icon-blue" asset catalog image resource.
    static let bookThumbnailIconBlue = DeveloperToolsSupport.ImageResource(name: "book-thumbnail-icon-blue", bundle: resourceBundle)

    /// The "book-thumbnail-icon-green" asset catalog image resource.
    static let bookThumbnailIconGreen = DeveloperToolsSupport.ImageResource(name: "book-thumbnail-icon-green", bundle: resourceBundle)

    /// The "book-thumbnail-icon-purple" asset catalog image resource.
    static let bookThumbnailIconPurple = DeveloperToolsSupport.ImageResource(name: "book-thumbnail-icon-purple", bundle: resourceBundle)

    /// The "book-thumbnail-icon-red" asset catalog image resource.
    static let bookThumbnailIconRed = DeveloperToolsSupport.ImageResource(name: "book-thumbnail-icon-red", bundle: resourceBundle)

    /// The "book-thumbnail-icon-yellow" asset catalog image resource.
    static let bookThumbnailIconYellow = DeveloperToolsSupport.ImageResource(name: "book-thumbnail-icon-yellow", bundle: resourceBundle)

    /// The "card-book-icon" asset catalog image resource.
    static let cardBookIcon = DeveloperToolsSupport.ImageResource(name: "card-book-icon", bundle: resourceBundle)

    /// The "hold-icon" asset catalog image resource.
    static let holdIcon = DeveloperToolsSupport.ImageResource(name: "hold-icon", bundle: resourceBundle)

    /// The "library-empty" asset catalog image resource.
    static let libraryEmpty = DeveloperToolsSupport.ImageResource(name: "library-empty", bundle: resourceBundle)

    /// The "no-books-image" asset catalog image resource.
    static let noBooks = DeveloperToolsSupport.ImageResource(name: "no-books-image", bundle: resourceBundle)

    /// The "open-book" asset catalog image resource.
    static let openBook = DeveloperToolsSupport.ImageResource(name: "open-book", bundle: resourceBundle)

    /// The "tabbar-add" asset catalog image resource.
    static let tabbarAdd = DeveloperToolsSupport.ImageResource(name: "tabbar-add", bundle: resourceBundle)

    /// The "tabbar-home" asset catalog image resource.
    static let tabbarHome = DeveloperToolsSupport.ImageResource(name: "tabbar-home", bundle: resourceBundle)

    /// The "tabbar-library" asset catalog image resource.
    static let tabbarLibrary = DeveloperToolsSupport.ImageResource(name: "tabbar-library", bundle: resourceBundle)

    /// The "welcome-mockup" asset catalog image resource.
    static let welcomeMockup = DeveloperToolsSupport.ImageResource(name: "welcome-mockup", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "LaunchLogo" asset catalog image.
    static var launchLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .launchLogo)
#else
        .init()
#endif
    }

    /// The "appicon" asset catalog image.
    static var appicon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appicon)
#else
        .init()
#endif
    }

    /// The "book-search-banner" asset catalog image.
    static var bookSearchBanner: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bookSearchBanner)
#else
        .init()
#endif
    }

    /// The "book-thumbnail-icon-blue" asset catalog image.
    static var bookThumbnailIconBlue: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bookThumbnailIconBlue)
#else
        .init()
#endif
    }

    /// The "book-thumbnail-icon-green" asset catalog image.
    static var bookThumbnailIconGreen: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bookThumbnailIconGreen)
#else
        .init()
#endif
    }

    /// The "book-thumbnail-icon-purple" asset catalog image.
    static var bookThumbnailIconPurple: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bookThumbnailIconPurple)
#else
        .init()
#endif
    }

    /// The "book-thumbnail-icon-red" asset catalog image.
    static var bookThumbnailIconRed: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bookThumbnailIconRed)
#else
        .init()
#endif
    }

    /// The "book-thumbnail-icon-yellow" asset catalog image.
    static var bookThumbnailIconYellow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bookThumbnailIconYellow)
#else
        .init()
#endif
    }

    /// The "card-book-icon" asset catalog image.
    static var cardBookIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cardBookIcon)
#else
        .init()
#endif
    }

    /// The "hold-icon" asset catalog image.
    static var holdIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .holdIcon)
#else
        .init()
#endif
    }

    /// The "library-empty" asset catalog image.
    static var libraryEmpty: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .libraryEmpty)
#else
        .init()
#endif
    }

    /// The "no-books-image" asset catalog image.
    static var noBooks: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .noBooks)
#else
        .init()
#endif
    }

    /// The "open-book" asset catalog image.
    static var openBook: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .openBook)
#else
        .init()
#endif
    }

    /// The "tabbar-add" asset catalog image.
    static var tabbarAdd: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarAdd)
#else
        .init()
#endif
    }

    /// The "tabbar-home" asset catalog image.
    static var tabbarHome: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarHome)
#else
        .init()
#endif
    }

    /// The "tabbar-library" asset catalog image.
    static var tabbarLibrary: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabbarLibrary)
#else
        .init()
#endif
    }

    /// The "welcome-mockup" asset catalog image.
    static var welcomeMockup: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .welcomeMockup)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "LaunchLogo" asset catalog image.
    static var launchLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .launchLogo)
#else
        .init()
#endif
    }

    /// The "appicon" asset catalog image.
    static var appicon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .appicon)
#else
        .init()
#endif
    }

    /// The "book-search-banner" asset catalog image.
    static var bookSearchBanner: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bookSearchBanner)
#else
        .init()
#endif
    }

    /// The "book-thumbnail-icon-blue" asset catalog image.
    static var bookThumbnailIconBlue: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bookThumbnailIconBlue)
#else
        .init()
#endif
    }

    /// The "book-thumbnail-icon-green" asset catalog image.
    static var bookThumbnailIconGreen: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bookThumbnailIconGreen)
#else
        .init()
#endif
    }

    /// The "book-thumbnail-icon-purple" asset catalog image.
    static var bookThumbnailIconPurple: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bookThumbnailIconPurple)
#else
        .init()
#endif
    }

    /// The "book-thumbnail-icon-red" asset catalog image.
    static var bookThumbnailIconRed: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bookThumbnailIconRed)
#else
        .init()
#endif
    }

    /// The "book-thumbnail-icon-yellow" asset catalog image.
    static var bookThumbnailIconYellow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bookThumbnailIconYellow)
#else
        .init()
#endif
    }

    /// The "card-book-icon" asset catalog image.
    static var cardBookIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cardBookIcon)
#else
        .init()
#endif
    }

    /// The "hold-icon" asset catalog image.
    static var holdIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .holdIcon)
#else
        .init()
#endif
    }

    /// The "library-empty" asset catalog image.
    static var libraryEmpty: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .libraryEmpty)
#else
        .init()
#endif
    }

    /// The "no-books-image" asset catalog image.
    static var noBooks: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .noBooks)
#else
        .init()
#endif
    }

    /// The "open-book" asset catalog image.
    static var openBook: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .openBook)
#else
        .init()
#endif
    }

    /// The "tabbar-add" asset catalog image.
    static var tabbarAdd: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarAdd)
#else
        .init()
#endif
    }

    /// The "tabbar-home" asset catalog image.
    static var tabbarHome: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarHome)
#else
        .init()
#endif
    }

    /// The "tabbar-library" asset catalog image.
    static var tabbarLibrary: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tabbarLibrary)
#else
        .init()
#endif
    }

    /// The "welcome-mockup" asset catalog image.
    static var welcomeMockup: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .welcomeMockup)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

