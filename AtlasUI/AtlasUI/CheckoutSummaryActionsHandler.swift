//
//  CheckoutSummaryActionsHandler.swift
//  AtlasUI
//
//  Created by Hani Ibrahim Ibrahim Eloksh on 26/08/16.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import AtlasSDK

struct CheckoutSummaryActionsHandler {

    internal unowned let viewController: CheckoutSummaryStoryboardViewController

}

extension CheckoutSummaryActionsHandler {

    internal func handleBuyAction() {
        guard let checkout = viewController.checkoutViewModel.checkout else { return }

        viewController.showLoader()
        viewController.checkout.client.createOrder(checkout.id) { result in
            self.viewController.hideLoader()
            switch result {
            case .failure(let error): UserMessage.showError(title: self.viewController.loc("Fatal Error"), error: error)
            case .success: self.viewController.viewState = .OrderPlaced
            }
        }
    }

}

extension CheckoutSummaryActionsHandler {

    internal func loadCustomerData() {
        viewController.checkout.client.customer { result in
            Async.main {
                switch result {
                case .failure(let error): UserMessage.showError(title: self.viewController.loc("Fatal Error"), error: error)
                case .success(let customer): self.generateCheckout(customer)
                }
            }
        }
    }

    private func generateCheckout(customer: Customer) {
        viewController.showLoader()
        viewController.checkout.createCheckout(withArticle: viewController.checkoutViewModel.article, articleUnitIndex: viewController.checkoutViewModel.selectedUnitIndex) { result in
            self.viewController.hideLoader()
            switch result {
            case .failure(let error):
                self.viewController.dismissViewControllerAnimated(true) {
                    UserMessage.showError(title: self.viewController.loc("Fatal Error"), error: error)
                }
            case .success(var checkout):
                checkout.customer = customer
                self.viewController.checkoutViewModel = checkout
                self.viewController.viewState = .LoggedIn
            }
        }
    }

}

extension CheckoutSummaryActionsHandler {

    internal func showPaymentSelectionScreen() {
        guard Atlas.isUserLoggedIn() else { return loadCustomerData() }
        guard let paymentURL = viewController.checkoutViewModel.checkout?.payment.selectionPageUrl else { return }

        let paymentSelectionViewController = PaymentSelectionViewController(paymentSelectionURL: paymentURL)
        paymentSelectionViewController.paymentCompletion = { _ in
            self.loadCustomerData()
        }
        viewController.showViewController(paymentSelectionViewController, sender: viewController)
    }

}
