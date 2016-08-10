//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import AtlasSDK

final class CheckoutSummaryViewController: UIViewController {

    internal let productImageView = UIImageView()
    internal let productNameLabel = UILabel()
    internal let purchasedObjectSummaryLabel = UILabel()
    internal let termsAndConditionsButton = UIButton()
    internal let paymentSummaryTableview = UITableView()
    internal let stackView: UIStackView = UIStackView()
    internal let shippingPrice: Float = 0
    internal var customer: Customer? = nil
    internal var buyButton = UIButton()
    internal var checkoutViewModel: CheckoutViewModel

    private var styler: CheckoutSummaryStyler?

    internal var checkout: AtlasCheckout

    init(checkout: AtlasCheckout, customer: Customer?, checkoutViewModel: CheckoutViewModel) {
        self.checkout = checkout
        self.customer = customer
        self.checkoutViewModel = checkoutViewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        styler = CheckoutSummaryStyler(checkoutSummaryViewController: self)
        self.setupViews()
    }

    private func setupViews() {
        Async.main {
            self.view.removeAllSubviews()
            self.title = "Summary".loc
            self.view.backgroundColor = UIColor.clearColor()
            self.view.opaque = false
            self.setupNavBar()
            self.setupBlurView()
            self.setupProductImageView()
            self.setupViewLabels()
            self.view.addSubview(self.stackView)
            self.setupTermsAndConditionsButton()
            self.setupBuyButton()

            if let styler = self.styler {
                styler.stylize()
            }
        }
    }

    @objc internal func buyButtonTapped(sender: UIButton) {
        let paymentProcessingViewController = PaymentProcessingViewController(checkout: checkout, checkoutViewModel: self.checkoutViewModel)

        self.showViewController(paymentProcessingViewController, sender: self)
    }

    @objc internal func connectToZalandoButtonTapped(sender: UIButton) {
        connectToZalando()
    }

    @objc private func cancelCheckoutTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    private func showLoadingView() {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        backgroundView.backgroundColor = .grayColor()
        backgroundView.alpha = 0.2
        indicator.center = CGPoint(x: self.view.bounds.size.width / 2, y: (self.view.bounds.size.height) / 2)
        indicator.color = .blackColor()
        Async.main {
            indicator.startAnimating()
            self.view.addSubview(backgroundView)
            self.view.addSubview(indicator)
        }
    }

    private func setupNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        if let article = self.checkoutViewModel.article where article.hasSingleUnit {
            self.navigationItem.setHidesBackButton(true, animated: false)
        }

        let cancelButton = UIBarButtonItem(title: "Cancel".loc, style: UIBarButtonItemStyle.Plain,
            target: self, action: #selector(CheckoutSummaryViewController.cancelCheckoutTapped(_:)))

        navigationItem.rightBarButtonItem = cancelButton
    }

    private func connectToZalando() {
        checkout.client.customer { result in
            Async.main {
                switch result {
                case .failure(let error):
                    UserMessage.showError(title: "Fatal Error".loc, error: error)

                case .success(let customer):
                    self.showLoadingView()
                    self.generateCheckoutAndRefreshViews(customer)
                }
            }
        }
    }

    private func generateCheckoutAndRefreshViews(customer: Customer) {
        guard let article = self.checkoutViewModel.article,
            articleIndex = self.checkoutViewModel.articleUnitIndex else { return }

        checkout.createCheckout(withArticle: article, articleUnitIndex: articleIndex) { result in
            switch result {
            case .failure(let error):
                self.dismissViewControllerAnimated(true) {
                    UserMessage.showError(title: "Fatal Error".loc, error: error)
                }
            case .success(let checkout):
                self.checkoutViewModel = checkout
                self.customer = customer
                self.setupViews()
            }
        }
    }

    private func setupProductImageView() {
        view.addSubview(productImageView)

    }

    private func setupViewLabels() {
        if let _ = self.checkoutViewModel.article {
            view.addSubview(productNameLabel)
            view.addSubview(purchasedObjectSummaryLabel)
        }
    }

    private func setupTermsAndConditionsButton() {
        self.view.addSubview(termsAndConditionsButton)
    }

    private func setupBuyButton() {
        self.view.addSubview(buyButton)

        if customer != nil {
            buyButton.addTarget(self, action: #selector(CheckoutSummaryViewController.buyButtonTapped(_:)),
                forControlEvents: .TouchUpInside)
        } else {
            buyButton.addTarget(self, action: #selector(CheckoutSummaryViewController.connectToZalandoButtonTapped(_:)),
                forControlEvents: .TouchUpInside)
        }

    }

    private func setupBlurView() {
        let blurEffect = UIBlurEffect(style: .ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.view.addSubview(blurEffectView)

        blurEffectView.frame = self.view.bounds
        blurEffectView.frame.makeIntegralInPlace()

        let vibrancy = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        vibrancyView.frame = blurEffectView.bounds
        vibrancyView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        let extraLightVibrancyView = vibrancyView
        blurEffectView.contentView.addSubview(extraLightVibrancyView)
    }

}

extension CheckoutSummaryViewController {

    internal func shippingView(text: String) -> UIView? {
        let shippingView = CheckoutSummaryRow()
        shippingView.translatesAutoresizingMaskIntoConstraints = false
        shippingView.initWith("Shipping".loc, detail: text) {
            print("Shipping")
        }
        return shippingView
    }

    internal func topSeparatorView() -> UIView? {
        let topSeparatorView = UIView()
        topSeparatorView.layer.borderWidth = 5
        topSeparatorView.layer.borderColor = UIColor.blackColor().CGColor
        topSeparatorView.alpha = 0.2
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        return topSeparatorView
    }

    internal func discountView(text: String) -> UIView? {
        let discountView = CheckoutSummaryRow()
        discountView.translatesAutoresizingMaskIntoConstraints = false
        discountView.initWith("Discount".loc, detail: text) {
            print("Discount")
        }
        return discountView
    }

    internal func paymentSummaryRow() -> UIView? {
        if let article = self.checkoutViewModel.articleUnit {
            var shippingPrice: Float? = nil
            if customer != nil {
                shippingPrice = self.shippingPrice
            }

            let paymentSummaryRow = PaymentSummaryRow.init(shippingPrice: shippingPrice,
                itemPrice: article.price)
            paymentSummaryRow.translatesAutoresizingMaskIntoConstraints = false

            return paymentSummaryRow
        }
        return nil
    }

    internal func cardView(text: String) -> UIView? {
        let cardView = CheckoutSummaryRow()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.initWith("Payment".loc, detail: text) {
            print("Payment")
        }
        return cardView
    }

}
