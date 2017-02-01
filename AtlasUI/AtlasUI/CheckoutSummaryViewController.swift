//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK

class CheckoutSummaryViewController: UIViewController {

    var actionHandler: CheckoutSummaryActionHandler? {
        didSet {
            actionHandler?.dataSource = self
            actionHandler?.delegate = self
        }
    }

    fileprivate var viewModel: CheckoutSummaryViewModel {
        didSet {
            viewModelDidSet()
        }
    }

    fileprivate let rootStackView: CheckoutSummaryRootStackView = {
        let stackView = CheckoutSummaryRootStackView()
        stackView.axis = .vertical
        return stackView
    }()

    init(viewModel: CheckoutSummaryViewModel) {
        self.viewModel = viewModel
        defer { viewModelDidSet() }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildView()
        setupActions()
        rootStackView.productStackView.editArticleStackView.dataSource = self
        rootStackView.productStackView.editArticleStackView.delegate = self
        rootStackView.checkoutContainer.displaySizes(selectedArticle: viewModel.dataModel.selectedArticle, animated: false) { result in

        }
    }

    fileprivate func viewModelDidSet() {
        setupNavigationBar()
        rootStackView.configure(viewModel: viewModel)
    }

}

extension CheckoutSummaryViewController: UIBuilder {

    func configureView() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.accessibilityIdentifier = "checkout-summary-navigation-bar"

        view.backgroundColor = .white
        view.addSubview(rootStackView)
    }

    func configureConstraints() {
        rootStackView.fillInSuperview()
    }

}

extension CheckoutSummaryViewController {

    fileprivate func setupActions() {
        let submitButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(submitButtonTapped))
        rootStackView.checkoutContainer.footerStackView.submitButton.addGestureRecognizer(submitButtonRecognizer)

        let shippingAddressRecognizer = UITapGestureRecognizer(target: self, action: #selector(shippingAddressTapped))
        rootStackView.checkoutContainer.mainStackView.shippingAddressStackView.addGestureRecognizer(shippingAddressRecognizer)

        let billingAddressRecognizer = UITapGestureRecognizer(target: self, action: #selector(billingAddressTapped))
        rootStackView.checkoutContainer.mainStackView.billingAddressStackView.addGestureRecognizer(billingAddressRecognizer)

        let paymentRecognizer = UITapGestureRecognizer(target: self, action: #selector(paymentAddressTapped))
        rootStackView.checkoutContainer.mainStackView.paymentStackView.addGestureRecognizer(paymentRecognizer)
    }

    fileprivate func setupNavigationBar() {
        title = Localizer.format(string: viewModel.layout.navigationBarTitleLocalizedKey)

        navigationItem.setHidesBackButton(viewModel.layout.hideBackButton, animated: false)

        if viewModel.layout.showCancelButton {
            showCancelButton()
        } else {
            hideCancelButton()
        }
    }

}

extension CheckoutSummaryViewController {

    dynamic fileprivate func submitButtonTapped() {
        actionHandler?.handleSubmit()
    }

    dynamic fileprivate func shippingAddressTapped() {
        actionHandler?.handleShippingAddressSelection()
    }

    dynamic fileprivate func billingAddressTapped() {
        actionHandler?.handleBillingAddressSelection()
    }

    dynamic fileprivate func paymentAddressTapped() {
        actionHandler?.handlePaymentSelection()
    }

}

extension CheckoutSummaryViewController: CheckoutSummaryActionHandlerDataSource {

    var dataModel: CheckoutSummaryDataModel {
        return viewModel.dataModel
    }

}

extension CheckoutSummaryViewController: CheckoutSummaryActionHandlerDelegate {

    func updated(dataModel: CheckoutSummaryDataModel) throws {
        let oldModel = self.viewModel.dataModel
        self.viewModel.dataModel = dataModel

        do {
            try dataModel.validate(against: oldModel)
        } catch let error {
            UserMessage.displayError(error: error)
            throw error
        }
    }

    func updated(layout: CheckoutSummaryLayout) {
        self.viewModel.layout = layout
    }

    func updated(actionHandler: CheckoutSummaryActionHandler) {
        self.actionHandler = actionHandler
    }

    func dismissView() {
        dismiss(animated: true, completion: nil)
    }

}

extension CheckoutSummaryViewController: CheckoutSummaryEditProductDataSource {

    var checkoutContainer: CheckoutContainerView {
        return rootStackView.checkoutContainer
    }

    var selectedArticle: SelectedArticle {
        return viewModel.dataModel.selectedArticle
    }

}

extension CheckoutSummaryViewController: CheckoutSummaryEditProductDelegate {

    func updated(selectedArticle: SelectedArticle) {
        viewModel.dataModel = CheckoutSummaryDataModel(selectedArticle: selectedArticle,
                                                       shippingAddress: viewModel.dataModel.shippingAddress,
                                                       billingAddress: viewModel.dataModel.billingAddress,
                                                       paymentMethod: viewModel.dataModel.paymentMethod,
                                                       totalPrice: viewModel.dataModel.totalPrice,
                                                       delivery: viewModel.dataModel.delivery,
                                                       email: viewModel.dataModel.email,
                                                       orderNumber: viewModel.dataModel.orderNumber)
        actionHandler?.selectedArticleChanged()
    }

}
