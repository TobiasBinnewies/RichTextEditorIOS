//
//  AutogrowingTextView.swift
//  RichTextEditor
//
//  Created by Tobias Binnewies on 08.03.23.
//

import Foundation
import UIKit

class AutogrowingTextView: UITextView {

    var maxHeight: CGFloat = 0
    weak var boundsObserver: BoundsObserving?
    var maxHeightConstraint: NSLayoutConstraint!
    var heightAnchorConstraint: NSLayoutConstraint!

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        isScrollEnabled = false
        heightAnchorConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: contentSize.height)
        heightAnchorConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            heightAnchorConstraint
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override var isScrollEnabled: Bool {
//        didSet {
//            // Invalidate intrinsic content size when scrolling is disabled again as a result of text
//            // getting cleared/removed. In absence of the following code, the textview does not
//            // resize when cleared until a character is typed in.
//            guard isScrollEnabled == false,
//                  oldValue == true
//            else { return }
//
//            invalidateIntrinsicContentSize()
//        }
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard maxHeight != .greatestFiniteMagnitude else { return }
        let bounds = self.bounds.integral
        let fittingSize = self.calculatedSize(attributedText: attributedText, frame: frame.size, textContainerInset: textContainerInset)
        let isScrollEnabled = (fittingSize.height > bounds.height) || (self.maxHeight > 0 && self.maxHeight < fittingSize.height)
        self.isScrollEnabled = isScrollEnabled
        heightAnchorConstraint.constant = fittingSize.height
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize = calculatedSize(attributedText: attributedText, frame: frame.size, textContainerInset: textContainerInset)
        if maxHeight > 0 {
            fittingSize.height = min(maxHeight, fittingSize.height)
        }
        return fittingSize
    }

    override var bounds: CGRect {
        didSet {
            guard oldValue.height != bounds.height else {
                layoutSubviews()
                return
            }
            boundsObserver?.didChangeBounds(bounds)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.becomeFirstResponder()
    }

    private func calculatedSize(attributedText: NSAttributedString, frame: CGSize, textContainerInset: UIEdgeInsets) -> CGSize {
        // Adjust for horizontal paddings in textview to exclude from overall available width for attachment
        let horizontalAdjustments = (textContainer.lineFragmentPadding * 2) + (textContainerInset.left + textContainerInset.right)
        let boundingRect = attributedText.boundingRect(with: CGSize(width: frame.width - horizontalAdjustments, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil).integral

        let insets = UIEdgeInsets(top: -textContainerInset.top, left: -textContainerInset.left, bottom: -textContainerInset.bottom, right: -textContainerInset.right)
        return boundingRect.inset(by: insets).size
    }
}

/// Describes an object interested in observing the bounds of a view. `Attachment` is `BoundsObserving` and reacts to
/// changes in the bounds of views hosted within the `Attachment`. Any view contained in the `Attachment` that is capable of
/// changing its bounds must define and set `BoundsObserving` to `Attachment`.

/// ### Usage Example ###
/// ```
///  class MyAttachmentView: UIView {
///  weak var boundsObserver: BoundsObserving?
///
///  override var bounds: CGRect {
///      didSet {
///          guard oldValue != bounds else { return }
///          boundsObserver?.didChangeBounds(bounds)
///      }
///     }
///  }
///
///  let myView = MyAttachmentView()
///  let attachment = Attachment(myView, size: .matchContent)
///  myView.boundsObserver = attachment
/// ```
public protocol BoundsObserving: AnyObject {
    /// Lets the observer know that bounds of current object have changed
    /// - Parameter bounds: New bounds
    func didChangeBounds(_ bounds: CGRect)
}
