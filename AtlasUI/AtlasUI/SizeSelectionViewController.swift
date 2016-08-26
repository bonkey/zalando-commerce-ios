//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK

final class SizeSelectionViewController: UIViewController, CheckoutProviderType {

    private let sku: String
    internal let checkout: AtlasCheckout

    init(checkout: AtlasCheckout, sku: String) {
        self.checkout = checkout
        self.sku = sku
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = loc("Pick a size")
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        activityIndicatorView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()

        fetchSizes()
    }

    private func showCheckoutScreen(article: Article, selectedUnitIndex: Int) {
        guard Atlas.isUserLoggedIn() else {
            let checkoutModel = CheckoutViewModel(article: article, selectedUnitIndex: 0)
            let checkoutSummaryVC = CheckoutSummaryViewController(checkout: checkout, checkoutViewModel: checkoutModel)
            UIView.performWithoutAnimation {
                self.showViewController(checkoutSummaryVC, sender: self)
            }
            return
        }

        checkout.client.customer { result in
            switch result {
            case .failure(let error):
                self.userMessage.show(error: error)
            case .success(let customer):
                self.generateCheckout(withArticle: article, customer: customer)
            }
        }
    }

    private func generateCheckout(withArticle article: Article, customer: Customer) {
        checkout.createCheckout(withArticle: article, selectedUnitIndex: 0) { result in
            switch result {
            case .failure(let error):
                self.dismissViewControllerAnimated(true) {
                    self.userMessage.show(error: error)
                }
            case .success(let checkoutViewModel):
                let checkoutSummaryVC = CheckoutSummaryViewController(checkout: self.checkout, checkoutViewModel: checkoutViewModel)

                UIView.performWithoutAnimation {
                    self.showViewController(checkoutSummaryVC, sender: self)
                }
            }
        }
    }

    private func fetchSizes() {
        activityIndicatorView.startAnimating()

        checkout.client.article(forSKU: sku) { [weak self] result in
            guard let strongSelf = self else { return }
            Async.main {
                switch result {
                case .failure(let error):
                    strongSelf.userMessage.show(error: error)
                case .success(let article):
                    strongSelf.displaySizes(forArticle: article)
                }
            }
        }
    }

    private func displaySizes(forArticle article: Article) {
        if article.hasSingleUnit {
            showCheckoutScreen(article, selectedUnitIndex: 0)
        } else {
            Async.main {
                self.activityIndicatorView.stopAnimating()
            }
            self.showSizeListViewController(article)
        }
    }

    private func showSizeListViewController(article: Article) {
        let sizeListSelectionViewController = SizeListSelectionViewController(checkout: checkout, article: article)
        addChildViewController(sizeListSelectionViewController)
        sizeListSelectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sizeListSelectionViewController.view)
        sizeListSelectionViewController.view.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        sizeListSelectionViewController.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        sizeListSelectionViewController.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        sizeListSelectionViewController.view.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
        sizeListSelectionViewController.didMoveToParentViewController(self)
    }

}
