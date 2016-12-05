//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    var cornerRadius: CGFloat = 0
    var isCircle: Bool = false
    var borderWidth: CGFloat = 0
    var borderColor: UIColor = .clear

    override func layoutSubviews() {
        super.layoutSubviews()

        if isCircle {
            layer.cornerRadius = bounds.maximumCornerRadius
        } else {
            layer.cornerRadius = min(bounds.maximumCornerRadius, cornerRadius)
        }
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }

}

class RoundedImageView: UIImageView {

    var cornerRadius: CGFloat = 0
    var isCircle: Bool = false
    var borderWidth: CGFloat = 0
    var borderColor: UIColor = .clear

    override func layoutSubviews() {
        super.layoutSubviews()

        if isCircle {
            layer.cornerRadius = bounds.maximumCornerRadius
        } else {
            layer.cornerRadius = min(bounds.maximumCornerRadius, cornerRadius)
        }
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }

}

class RoundedButton: UIButton {

    var cornerRadius: CGFloat = 0
    var isCircle: Bool = false
    var borderWidth: CGFloat = 0
    var borderColor: UIColor = .clear

    override func layoutSubviews() {
        super.layoutSubviews()

        if isCircle {
            layer.cornerRadius = bounds.maximumCornerRadius
        } else {
            layer.cornerRadius = min(bounds.maximumCornerRadius, cornerRadius)
        }
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }

}
