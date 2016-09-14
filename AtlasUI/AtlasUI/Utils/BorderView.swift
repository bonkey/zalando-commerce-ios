//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit

class BorderView: UIView {

    var topBorder: Bool = false
    var rightBorder: Bool = false
    var bottomBorder: Bool = false
    var leftBorder: Bool = false
    var leadingMargin: CGFloat = 0
    var trailingMarging: CGFloat = 0
    var borderColor: UIColor = .blackColor() {
        didSet {
            subviews.forEach { $0.backgroundColor = borderColor }
        }
    }

    private let onePixel = 1 / UIScreen.mainScreen().scale

    override func layoutSubviews() {
        super.layoutSubviews()
        removeAllSubviews()

        let totalMargin = leadingMargin + trailingMarging

        if topBorder {
            addView(CGRect(x: leadingMargin, y: 0, width: bounds.width - totalMargin, height: onePixel))
        }
        if rightBorder {
            addView(CGRect(x: bounds.width - onePixel, y: leadingMargin, width: onePixel, height: bounds.height - totalMargin))
        }
        if bottomBorder {
            addView(CGRect(x: leadingMargin, y: bounds.height - onePixel, width: bounds.width - totalMargin, height: onePixel))
        }
        if leftBorder {
            addView(CGRect(x: 0, y: leadingMargin, width: onePixel, height: bounds.height - totalMargin))
        }
    }

    private func addView(frame: CGRect) {
        let view = UIView(frame: frame)
        view.backgroundColor = borderColor
        addSubview(view)
    }

}