//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation
import UIKit

protocol CheckoutSummaryLayout {

    var navigationBarTitleLocalizedKey: String { get }
    var showCancelButton: Bool { get }
    var showFooterLabel: Bool { get }
    var showDetailArrow: Bool { get }
    var showGuestStackView: Bool { get }
    var showOrderStackView: Bool { get }
    var allowArticleRefine: Bool { get }

    func submitButtonBackgroundColor(readyToCheckout: Bool) -> UIColor
    func submitButtonTitle(isPaypal: Bool) -> String

}

struct ArticleNotSelectedLayout: CheckoutSummaryLayout {

    let navigationBarTitleLocalizedKey: String = "summaryView.title.selectSize"
    let showCancelButton: Bool = true
    let showFooterLabel: Bool = true
    let showDetailArrow: Bool = true
    let showGuestStackView: Bool = false
    let showOrderStackView: Bool = false
    let allowArticleRefine: Bool = false

    func submitButtonBackgroundColor(readyToCheckout: Bool) -> UIColor { return .orange }
    func submitButtonTitle(isPaypal: Bool) -> String { return "summaryView.title.selectSize" }

}

struct NotLoggedInLayout: CheckoutSummaryLayout {

    let navigationBarTitleLocalizedKey: String = "summaryView.title.summary"
    let showCancelButton: Bool = true
    let showFooterLabel: Bool = true
    let showDetailArrow: Bool = true
    let showGuestStackView: Bool = false
    let showOrderStackView: Bool = false
    let allowArticleRefine: Bool = true

    func submitButtonBackgroundColor(readyToCheckout: Bool) -> UIColor { return .orange }
    func submitButtonTitle(isPaypal: Bool) -> String { return "summaryView.submitButton.checkoutWithZalando" }

}

struct LoggedInLayout: CheckoutSummaryLayout {

    let navigationBarTitleLocalizedKey: String = "summaryView.title.summary"
    let showCancelButton: Bool = true
    let showFooterLabel: Bool = true
    let showDetailArrow: Bool = true
    let showGuestStackView: Bool = false
    let showOrderStackView: Bool = false
    let allowArticleRefine: Bool = true

    func submitButtonBackgroundColor(readyToCheckout: Bool) -> UIColor { return readyToCheckout ? .orange : .gray }
    func submitButtonTitle(isPaypal: Bool) -> String {
        return isPaypal ? "summaryView.submitButton.payWithPayPal" : "summaryView.submitButton.placeOrder"
    }

}

struct OrderPlacedLayout: CheckoutSummaryLayout {

    let navigationBarTitleLocalizedKey: String = "summaryView.title.orderPlaced"
    let showCancelButton: Bool = false
    let showFooterLabel: Bool = false
    let showDetailArrow: Bool = false
    let showGuestStackView: Bool = false
    let showOrderStackView: Bool = true
    let allowArticleRefine: Bool = false

    func submitButtonBackgroundColor(readyToCheckout: Bool) -> UIColor { return UIColor(hex: 0x509614) }
    func submitButtonTitle(isPaypal: Bool) -> String { return "summaryView.submitButton.backToShop" }

}

struct GuestCheckoutLayout: CheckoutSummaryLayout {

    let navigationBarTitleLocalizedKey: String = "summaryView.title.summary"
    let showCancelButton: Bool = true
    let showFooterLabel: Bool = true
    let showDetailArrow: Bool = true
    let showGuestStackView: Bool = true
    let showOrderStackView: Bool = false
    let allowArticleRefine: Bool = true

    func submitButtonBackgroundColor(readyToCheckout: Bool) -> UIColor { return readyToCheckout ? .orange : .gray }
    func submitButtonTitle(isPaypal: Bool) -> String { return "summaryView.submitButton.guestCheckout" }

}

struct GuestOrderPlacedLayout: CheckoutSummaryLayout {

    let navigationBarTitleLocalizedKey: String = "summaryView.title.orderPlaced"
    let showCancelButton: Bool = false
    let showFooterLabel: Bool = false
    let showDetailArrow: Bool = false
    let showGuestStackView: Bool = true
    let showOrderStackView: Bool = true
    let allowArticleRefine: Bool = false

    func submitButtonBackgroundColor(readyToCheckout: Bool) -> UIColor { return UIColor(hex: 0x509614) }
    func submitButtonTitle(isPaypal: Bool) -> String { return "summaryView.submitButton.backToShop" }

}
