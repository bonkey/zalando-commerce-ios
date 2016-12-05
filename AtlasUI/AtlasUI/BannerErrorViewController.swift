//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit

class BannerErrorViewController: UIViewController {

    private static let topMargin: CGFloat = UIScreen.isSmallScreen ? 25 : 10

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .orangeColor()
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .Vertical
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: topMargin, left: 30, bottom: 10, right: 30)
        stackView.layoutMarginsRelativeArrangement = true
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .whiteColor()
        label.textAlignment = .Left
        label.font = .systemFontOfSize(12, weight: UIFontWeightBold)
        label.backgroundColor = .clearColor()
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .whiteColor()
        label.textAlignment = .Left
        label.font = .systemFontOfSize(12, weight: UIFontWeightLight)
        label.backgroundColor = .clearColor()
        return label
    }()

    private let cancelIconLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .blackColor()
        label.textAlignment = .Right
        label.text = "x"
        label.font = .systemFontOfSize(10, weight: UIFontWeightLight)
        label.backgroundColor = .clearColor()
        return label
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.backgroundColor = .clearColor()
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.alpha = 0
        buildView()
    }

    func showBanner() {
        containerView.transform = CGAffineTransformMakeTranslation(0, -containerView.bounds.height)
        view.alpha = 1

        UIView.animate(.fast) { [weak self] in
            self?.containerView.transform = CGAffineTransformIdentity
        }
    }

    func hideBanner(completion: (() -> Void)? = nil) {
        let bannerHeight = containerView.bounds.height
        UIView.animate(.fast, animations: { [weak self] in
            self?.containerView.transform = CGAffineTransformMakeTranslation(0, -bannerHeight)
        }) { [weak self] _ in
            self?.view.removeFromSuperview()
            self?.removeFromParentViewController()
            completion?()
        }
    }

    func cancelButtonPressed() {
        hideBanner()
    }

}

extension BannerErrorViewController: UIBuilder {

    func configureView() {
        view.clipsToBounds = true
        view.userInteractionEnabled = true
        view.addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(cancelIconLabel)
        containerView.addSubview(cancelButton)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), forControlEvents: .TouchUpInside)
    }

    func configureConstraints() {
        containerView.snapAnchorToSuperView(.top)
        containerView.snapAnchorToSuperView(.right)
        containerView.snapAnchorToSuperView(.left)
        stackView.fillInSuperView()
        cancelIconLabel.snapAnchorToSuperView(.top, constant: BannerErrorViewController.topMargin)
        cancelIconLabel.snapAnchorToSuperView(.right, constant: -10)
        cancelButton.fillInSuperView()
    }

}

extension BannerErrorViewController: UIDataBuilder {

    typealias T = UserPresentable

    func configureData(viewModel: T) {
        titleLabel.text = viewModel.displayedTitle
        messageLabel.text = viewModel.displayedMessage.oneLineString
        showBanner()
    }

}
