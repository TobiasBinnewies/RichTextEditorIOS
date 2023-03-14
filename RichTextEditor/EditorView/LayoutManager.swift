//
//  LayoutManager.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 05.03.23.
//

import Foundation
import UIKit

class LayoutManager: NSLayoutManager {
    weak var editorView: EditorView!
    
    private var defaultFont: UIFont {
        editorView.richTextEditorContext.defaultAttributes[.font] as! UIFont
    }
    
    private var defaultParaStyle: NSParagraphStyle {
        editorView.richTextEditorContext.defaultParaStyle
    }
    
    private var lvlHeadIndent: Int {
        editorView.richTextEditorContext.lvlHeadIndent
    }
    
    private var defaultTextColor: UIColor {
        editorView.richTextEditorContext.defaultAttributes[.foregroundColor] as! UIColor
    }
    
    private var counters = [Int: Int]()
    private var previousLevel = 0
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        let textStorage = editorView.textStorage
        
        textStorage.enumerateAttribute(.listItem, in: textStorage.fullRange) { listItem, listRange, _ in
            guard let listItem = listItem as? ListItem else { return }
            drawListMarkers(textStorage: textStorage, listRange: listRange, attributeValue: listItem)
            // WARN: Could not work!! (To reset the counters for every list
            counters = [:]
        }
        editorView.handleTextChange()
    }
    
    private func drawListMarkers(textStorage: NSTextStorage, listRange: NSRange, attributeValue: ListItem) {
        let listGlyphRange = glyphRange(forCharacterRange: listRange, actualCharacterRange: nil)
        enumerateLineFragments(forGlyphRange: listGlyphRange) { [weak self] (rect, usedRect, textContainer, glyphRange, stop) in
            guard let self = self else { return }
            let characterRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            
            let newLineRange: NSRange = {
                if characterRange.location <= 0 {
                    return NSRange.zero
                }
                return NSRange(location: characterRange.location-1, length: 1)
            }()
            
            let isPreviousLineComplete: Bool
            let skipMarker: Bool
            if newLineRange.length > 0 {
                isPreviousLineComplete = textStorage.substring(from: newLineRange) == "\n"
                skipMarker = textStorage.attribute(.skipNextListMarker, at: newLineRange.location, effectiveRange: nil) != nil
            } else {
                isPreviousLineComplete = true
                skipMarker = false
            }
            
            guard isPreviousLineComplete, !skipMarker else { return }
            
            let font = textStorage.attribute(.font, at: characterRange.location, effectiveRange: nil) as? UIFont ?? self.defaultFont
            let paraStyle = textStorage.attribute(.paragraphStyle, at: characterRange.location, effectiveRange: nil) as? NSParagraphStyle ?? self.defaultParaStyle
            
            let level: Int = Int(paraStyle.firstLineHeadIndent) / self.lvlHeadIndent
            var index = (self.counters[level] ?? 0)
            self.counters[level] = index + 1
            
            // reset index counter for level when list indentation (level) changes.
            if level > self.previousLevel {
                index = 0
                self.counters[level] = 1
            }
            
            self.drawListItem(level: level, previousLevel: self.previousLevel, index: index, rect: rect, paraStyle: paraStyle, font: font, listItem: attributeValue)
            self.previousLevel = level
        }
    }
    
    private func drawListItem(level: Int, previousLevel: Int, index: Int, rect: CGRect, paraStyle: NSParagraphStyle, font: UIFont, listItem: ListItem) {
        guard level > 0 else { return }
        
        let color = defaultTextColor
        color.set()
        
        let marker = listItem.getSymbol(forLevel: level).value(at: index)
        
        let listMarkerImage: UIImage
        let markerRect: CGRect
        
        switch marker {
        case let .string(text):
            let markerSize = text.boundingRect(with: CGSize(width: paraStyle.firstLineHeadIndent, height: rect.height), options: [], context: nil).size
            markerRect = rectForBullet(markerSize: markerSize, rect: rect, indent: paraStyle.firstLineHeadIndent, yOffset: paraStyle.paragraphSpacingBefore)
            listMarkerImage = self.generateBitmap(string: text, rect: markerRect)
        case let .image(image):
            markerRect = rectForBullet(markerSize: image.size, rect: rect, indent: paraStyle.firstLineHeadIndent, yOffset: paraStyle.paragraphSpacingBefore)
            listMarkerImage = image
        }
        
        listMarkerImage.draw(at: markerRect.origin)
    }
    
    private func generateBitmap(string: NSAttributedString, rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        let image = renderer.image { context in
            string.draw(at: .zero)
        }
        return image
    }
    
    private func rectForBullet(markerSize: CGSize, rect: CGRect, indent: CGFloat, yOffset: CGFloat) -> CGRect {
        let topInset: CGFloat = editorView.textContainerInset.top
        let spacerRect = CGRect(origin: CGPoint(x: rect.minX, y: rect.minY + topInset), size: CGSize(width: indent, height: rect.height))
        let stringRect = CGRect(origin: CGPoint(x: spacerRect.maxX - markerSize.width, y: spacerRect.minY + yOffset), size: markerSize)
        return stringRect
    }
}
