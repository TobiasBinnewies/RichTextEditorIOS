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
    
    public init(context: RichTextEditorContext, writeEnabled: Bool = true) {
        self.context = context
        self.isWriteEnable = writeEnabled
    }
    
    public func makeUIViewController(context: Context) -> EditorViewController {
        return EditorViewController(context: self.context, writeEnabled: isWriteEnable)
    }
    
    public func updateUIViewController(_ uiViewController: EditorViewController, context: Context) {
        
    }
    
    public typealias UIViewControllerType = EditorViewController
    
    
}

public class EditorViewController: UIViewController {
    let editor: EditorView
    
    public init(context: RichTextEditorContext, writeEnabled: Bool) {
        self.editor = EditorView(context: context, writeEnabled: writeEnabled)
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
}
