//
//  RichtTextEditor.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 03.03.23.
//

import Foundation
import SwiftUI

public struct RichTextEditor: UIViewControllerRepresentable {
    let context: RichTextEditorContext
    let isWriteEnable: Bool
    let initialText: NSAttributedString
    let bodyFontSize: CGFloat?
    let onChange: ((NSAttributedString)->Void)
    
    public init(initialText: NSAttributedString, context: RichTextEditorContext, onChange: @escaping ((NSAttributedString)->Void)) {
        self.initialText = initialText
        self.context = context
        self.isWriteEnable = true
        self.bodyFontSize = nil
        self.onChange = onChange
    }
    
    public init(text: NSAttributedString, context: RichTextEditorContext, bodyFontSize: CGFloat? = nil) {
        self.initialText = text
        self.context = context
        self.isWriteEnable = false
        self.bodyFontSize = bodyFontSize
        self.onChange = {_ in}
    }
    
    public func makeUIViewController(context: Context) -> EditorViewController {
        return EditorViewController(initialText: initialText, context: self.context, writeEnabled: isWriteEnable, bodyFontSize: bodyFontSize, onChange: onChange)
    }
    
    public func updateUIViewController(_ uiViewController: EditorViewController, context: Context) {
        
    }
    
    public typealias UIViewControllerType = EditorViewController
    
    
}

public class EditorViewController: UIViewController {
    let editor: EditorView
    let bodyFontSize: CGFloat?
    let initialText: NSAttributedString
    
    public init(initialText: NSAttributedString, context: RichTextEditorContext, writeEnabled: Bool, bodyFontSize: CGFloat?, onChange: @escaping ((NSAttributedString)->Void)) {
        self.editor = EditorView(initalText: initialText, context: context, writeEnabled: writeEnabled, onChange: onChange)
        self.initialText = initialText
        self.bodyFontSize = bodyFontSize
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        //        let coordinator = Coordinator(editor: editor, parent: self)
        //        takeCoordinator(coordinator)
        self.setup()
    }
    
    private func setup() {
        editor.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editor)
        
        if let bodyFontSize = bodyFontSize {
            editor.attributedText = setFontSizeForText(text: initialText, fontSize: bodyFontSize)
        }
        
        //        editor.isEditable = writeEnabled
        //        editor.isSelectable = writeEnabled
        
        //        if let height = height {
        //            let lineHeight = fontSize != nil ? fontSize! : editor.font.lineHeight
        //            editor.textContainer.maximumNumberOfLines = Int(height*0.5 / lineHeight)
        //            editor.isUserInteractionEnabled = false
        //            editor.textContainer.lineBreakMode = .byTruncatingMiddle
        //        }
        
        //        editor.attributedText = setFontSizeForText(text: text, fontSize: fontSize)
        
        //        editor.delegate = self
        //        EditorViewContext.shared.delegate = self
        
        NSLayoutConstraint.activate([
            editor.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            editor.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            editor.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
        ])
        
    }
    
    private func setFontSizeForText(text: NSAttributedString, fontSize: CGFloat) -> NSAttributedString {
        let text = NSMutableAttributedString(attributedString: text)
        let fontSizeRatio = fontSize / UIFont.preferredFont(forTextStyle: .body).pointSize
        text.enumerateAttribute(.font, in: text.fullRange) { value, range, _ in
            guard let value = value as? UIFont else { return }
            let newSize = UIFont.preferredFont(forTextStyle: value.textStyle).pointSize * fontSizeRatio
            var traits = value.traits
            if value.textStyle == .headline {
                traits.insert(.traitBold)
            }
            let newValue = value.withSize(newSize).adding(trait: traits)
            text.addAttributes([.font: newValue], range: range)
        }
        return text
    }
}
