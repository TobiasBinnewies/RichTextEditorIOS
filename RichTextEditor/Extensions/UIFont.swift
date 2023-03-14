//
//  UIFont.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 05.03.23.
//

import Foundation
import UIKit

extension UIFont {

    var traits: UIFontDescriptor.SymbolicTraits {
        return fontDescriptor.symbolicTraits
    }

    var isBold: Bool {
        return traits.contains(.traitBold)
    }

    var isItalics: Bool {
        return traits.contains(.traitItalic)
    }

    var isMonoSpaced: Bool {
        return traits.contains(.traitMonoSpace) // iOS 14 mono font does not contain
            || fontName.contains("Monospaced") // eg. ".AppleSystemUIFontMonospaced-Regular"
    }

    var isAppleEmoji: Bool {
        return fontName == ".AppleColorEmojiUI" // inserted from iOS Emoji keyboard or macOS Character Viewer
            || fontName == "LastResort" // interesting font available since Mac OS 8.5 to render unsupported emoji
    }

    var textStyle: UIFont.TextStyle {
        guard let style = fontDescriptor.object(forKey: .textStyle) as? String else {
            return .body
        }
        return UIFont.TextStyle(rawValue: style)
    }

    var isNonDynamicTextStyle: Bool {
        return textStyle.rawValue == "CTFontRegularUsage"
    }

    func contains(trait: UIFontDescriptor.SymbolicTraits) -> Bool {
        return traits.contains(trait)
    }

    func toggled(trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let updatedFont: UIFont
        if self.contains(trait: trait) {
            updatedFont = removing(trait: trait)
        } else {
            updatedFont = adding(trait: trait)
        }

        return updatedFont
    }

    func adding(trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        var traits = self.traits
        traits.formUnion(trait)
        guard let updatedFontDescriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }

        return UIFont(descriptor: updatedFontDescriptor, size: 0.0)
    }
    
    func adding(traits: [UIFontDescriptor.SymbolicTraits]) -> UIFont {
        var prevTraits = self.traits
        traits.forEach { trait in
            prevTraits.formUnion(trait)
        }
        guard let updatedFontDescriptor = fontDescriptor.withSymbolicTraits(prevTraits) else {
            return self
        }

        return UIFont(descriptor: updatedFontDescriptor, size: 0.0)
    }

    func removing(trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        var traits = self.traits
        traits.subtract(trait)
        guard let updatedFontDescriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }

        return UIFont(descriptor: updatedFontDescriptor, size: 0.0)
    }
    
    func withTraints(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let updatedFontDescriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }

        return UIFont(descriptor: updatedFontDescriptor, size: 0.0)
    }
    
    func getStyle() -> UIFont.TextStyle? {
        for style in TextStyle.allValues {
            if self == style.prefferedFont {
                return style
            }
        }
        return nil
    }
}

extension UIFontDescriptor.SymbolicTraits: Hashable {
    public static let allTrains = [
        traitItalic,
        traitBold,
        traitExpanded,
        traitCondensed,
        traitMonoSpace,
        traitVertical,
        traitUIOptimized,
        traitTightLeading,
        traitLooseLeading,
        classMask,
        classOldStyleSerifs,
        classTransitionalSerifs,
        classModernSerifs,
        classClarendonSerifs,
        classSlabSerifs,
        classFreeformSerifs,
        classSansSerif,
        classOrnamentals,
        classScripts,
        classSymbolic,
    ]
}

extension UIFont.TextStyle {
    static let allValues: [UIFont.TextStyle] = [.body, .largeTitle, .title1, .title2, .title3, .callout, .caption1, .caption2, .headline, .subheadline, .footnote]
    
    var prefferedFont: UIFont {
        switch self {
        case .body: return UIFont.preferredFont(forTextStyle: .body)
        case .largeTitle: return UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title1: return UIFont.preferredFont(forTextStyle: .title1)
        case .title2: return UIFont.preferredFont(forTextStyle: .title2)
        case .title3: return UIFont.preferredFont(forTextStyle: .title3)
        case .callout: return UIFont.preferredFont(forTextStyle: .callout)
        case .caption1: return UIFont.preferredFont(forTextStyle: .caption1)
        case .caption2: return UIFont.preferredFont(forTextStyle: .caption2)
        case .footnote: return UIFont.preferredFont(forTextStyle: .footnote)
        case .headline: return UIFont.preferredFont(forTextStyle: .headline)
        case .subheadline: return UIFont.preferredFont(forTextStyle: .subheadline)
        default:
            return UIFont()
        }
    }
}
