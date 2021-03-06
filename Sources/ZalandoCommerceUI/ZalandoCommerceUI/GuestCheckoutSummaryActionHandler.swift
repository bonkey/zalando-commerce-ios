//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import UIKit
import ZalandoCommerceAPI

class GuestCheckoutSummaryActionHandler: CheckoutSummaryActionHandler {

    weak var dataSource: CheckoutSummaryActionHandlerDataSource?
    weak var delegate: CheckoutSummaryActionHandlerDelegate?

    fileprivate let actionHandler = GuestAddressActionHandler()
    var paymentURL: URL?
    var guestCheckout: GuestCheckout? {
        didSet {
            updateDataModel(addresses: addresses, guestCheckout: guestCheckout)
        }
    }
    var guestCheckoutId: GuestCheckoutId?

    init(email: String) {
        self.actionHandler.emailAddress = email
    }

    func handleSubmit() {
        guard hasAddresses else {
            UserError.display(error: CheckoutError.missingAddress)
            return
        }
        guard let guestCheckoutId = guestCheckoutId else {
            UserError.display(error: CheckoutError.missingPaymentMethod)
            return
        }

        let request = GuestOrderRequest(guestCheckoutId: guestCheckoutId)
        ZalandoCommerceAPI.withLoader.createGuestOrder(request: request) { [weak self] result in
            guard let order = result.process() else { return }
            self?.handleOrderConfirmation(order: order)
        }
    }

    func handlePaymentSelection() {
        guard let callbackURL = Config.shared?.payment.selectionCallbackURL else {
            UserError.display(error: CheckoutError.unclassified)
            return
        }

        getPaymentURL { paymentURL in
            let paymentViewController = PaymentViewController(paymentURL: paymentURL, callbackURL: callbackURL)
            paymentViewController.paymentCompletion = { [weak self] paymentStatus in
                switch paymentStatus {
                case .guestRedirect(let guestCheckoutId):
                    self?.getGuestCheckout(with: guestCheckoutId)
                case .redirect:
                    if let guestCheckoutId = self?.guestCheckoutId {
                        self?.getGuestCheckout(with: guestCheckoutId)
                    }
                case .cancel:
                    break
                case .error, .success:
                    UserError.display(error: CheckoutError.unclassified)
                }
            }

            ZalandoCommerceUIViewController.push(paymentViewController)
        }
    }

    func handleShippingAddressSelection() {
        actionHandler.addressCreationStrategy = ShippingAddressViewModelCreationStrategy()
        actionHandler.handleAddressModification(address: shippingAddress) { [weak self] newAddress in
            self?.validateAddressModification(newAddress: newAddress, oldAddress: self?.shippingAddress)
            let addresses = CheckoutAddresses(shippingAddress: newAddress, billingAddress: self?.billingAddress, autoFill: true)
            self?.updateDataModel(addresses: addresses, guestCheckout: self?.guestCheckout)
        }
    }

    func handleBillingAddressSelection() {
        actionHandler.addressCreationStrategy = BillingAddressViewModelCreationStrategy()
        actionHandler.handleAddressModification(address: billingAddress) { [weak self] newAddress in
            self?.validateAddressModification(newAddress: newAddress, oldAddress: self?.billingAddress)
            let addresses = CheckoutAddresses(shippingAddress: self?.shippingAddress, billingAddress: newAddress, autoFill: true)
            self?.updateDataModel(addresses: addresses, guestCheckout: self?.guestCheckout)
        }
    }

    func handleCouponChanges(coupon: String?) {
        // Coupon should have no action if the user is not logged in
    }

    func updated(selectedArticle: SelectedArticle) {
        guard let email = actionHandler.emailAddress else { return }
        clearCurrentState()

        let dataModel = CheckoutSummaryDataModel(selectedArticle: selectedArticle,
                                                 guestCheckout: guestCheckout,
                                                 email: email,
                                                 addresses: addresses)
        try? delegate?.updated(dataModel: dataModel)
    }

}

extension GuestCheckoutSummaryActionHandler {

    fileprivate func handleOrderConfirmation(order: GuestOrder) {
        guard let paymentURL = order.externalPaymentURL else {
            showConfirmationScreen(order: order)
            return
        }

        guard let callbackURL = Config.shared?.payment.thirdPartyCallbackURL else {
            UserError.display(error: CheckoutError.unclassified)
            return
        }

        let paymentViewController = PaymentViewController(paymentURL: paymentURL, callbackURL: callbackURL)
        paymentViewController.paymentCompletion = { [weak self] paymentStatus in
            switch paymentStatus {
            case .success: self?.showConfirmationScreen(order: order)
            case .redirect, .cancel: break
            case .error, .guestRedirect: UserError.display(error: CheckoutError.unclassified)
            }
        }
        ZalandoCommerceUIViewController.push(paymentViewController)
    }

    fileprivate func showConfirmationScreen(order: GuestOrder) {
        guard let dataSource = dataSource,
            let delegate = delegate,
            let email = actionHandler.emailAddress
            else { return }

        let selectedArticle = dataSource.dataModel.selectedArticle
        let dataModel = CheckoutSummaryDataModel(selectedArticle: selectedArticle,
                                                 guestCheckout: guestCheckout,
                                                 email: email,
                                                 guestOrder: order)
        try? delegate.updated(dataModel: dataModel)
        delegate.updated(layout: GuestOrderPlacedLayout())
        delegate.updated(actionHandler: OrderPlacedSummaryActionHandler())

        let orderConfirmation = OrderConfirmation(guestOrder: order, selectedArticle: selectedArticle)
        let result = ZalandoCommerceUI.CheckoutResult.orderPlaced(orderConfirmation: orderConfirmation, customerRequestedArticle: nil)
        ZalandoCommerceUIViewController.presented?.dismissalReason = result
    }

    fileprivate func getPaymentURL(completion: @escaping (URL) -> Void) {
        if let paymentURL = paymentURL {
            completion(paymentURL)
            return
        }

        guard let dataSource = dataSource else { return }
        guard
            let email = actionHandler.emailAddress,
            let shippingAddress = shippingAddress,
            let billingAddress = billingAddress
            else {
                UserError.display(error: CheckoutError.missingAddress)
                return
        }

        let shippingGuestAddress = GuestAddressRequest(address: shippingAddress)
        let billingGuestAddress = GuestAddressRequest(address: billingAddress)
        let customer = GuestCustomerRequest(guestEmail: email, subscribeNewsletter: false)
        let selectedSKU = dataSource.dataModel.selectedArticle.sku
        let cartItem = CartItemRequest(sku: selectedSKU, quantity: dataSource.dataModel.selectedArticle.quantity)
        let cart = GuestCartRequest(items: [cartItem])
        let request = GuestPaymentSelectionRequest(cart: cart,
                                                   customer: customer,
                                                   shippingAddress: shippingGuestAddress,
                                                   billingAddress: billingGuestAddress)
        ZalandoCommerceAPI.withLoader.guestCheckoutPaymentSelectionURL(request: request) { [weak self] result in
            guard let paymentURL = result.process() else { return }
            self?.paymentURL = paymentURL
            completion(paymentURL)
        }
    }

    fileprivate func validateAddressModification(newAddress: EquatableAddress, oldAddress: EquatableAddress?) {
        if let oldAddress = oldAddress, !(newAddress === oldAddress) {
            clearCurrentState()
        }
    }

    fileprivate func clearCurrentState() {
        paymentURL = nil
        guestCheckout = nil
        guestCheckoutId = nil
    }

    fileprivate func getGuestCheckout(with guestCheckoutId: GuestCheckoutId) {
        ZalandoCommerceAPI.withLoader.guestCheckout(with: guestCheckoutId) { [weak self] result in
            guard let guestCheckout = result.process() else { return }
            self?.guestCheckout = guestCheckout
            self?.guestCheckoutId = guestCheckoutId
        }
    }

    fileprivate func updateDataModel(addresses: CheckoutAddresses?, guestCheckout: GuestCheckout?) {
        guard let selectedUnit = dataSource?.dataModel.selectedArticle,
            let email = actionHandler.emailAddress
            else { return }

        let dataModel = CheckoutSummaryDataModel(selectedArticle: selectedUnit,
                                                 guestCheckout: guestCheckout,
                                                 email: email,
                                                 addresses: addresses)
        try? delegate?.updated(dataModel: dataModel)
    }

}
