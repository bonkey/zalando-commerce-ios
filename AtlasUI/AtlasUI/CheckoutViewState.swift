//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

enum CheckoutViewState {

    case NotLoggedIn
    case LoggedIn
    case OrderPlaced

    var submitButtonTitleLocalizedKey: String {
        switch self {
        case .NotLoggedIn: return "Zalando.Checkout"
        case .LoggedIn: return "order.place"
        case .OrderPlaced: return "navigation.back.shop"
        }
    }

    var submitButtonBackgroundColor: UIColor {
        switch self {
        case .NotLoggedIn, .LoggedIn: return .orangeColor()
        case .OrderPlaced: return UIColor(red: 80.0/255.0, green: 150.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        }
    }

    var navigationBarTitleLocalizedKey: String {
        switch self {
        case .NotLoggedIn, .LoggedIn: return "Summary"
        case .OrderPlaced: return "order.placed"
        }
    }

    var showCancelButton: Bool {
        switch self {
        case .NotLoggedIn, .LoggedIn: return true
        case .OrderPlaced: return false
        }
    }

    var showPrice: Bool {
        switch self {
        case .NotLoggedIn: return false
        case .LoggedIn, .OrderPlaced: return true
        }
    }

    var showFooter: Bool {
        switch self {
        case .NotLoggedIn, .LoggedIn: return true
        case .OrderPlaced: return false
        }
    }

    var showDetailArrow: Bool {
        switch self {
        case .NotLoggedIn, .LoggedIn: return true
        case .OrderPlaced: return false
        }
    }

    func hideBackButton(hasSingleUnit: Bool) -> Bool {
        guard !hasSingleUnit else { return true }
        switch self {
        case .NotLoggedIn, .LoggedIn: return false
        case .OrderPlaced: return true
        }
    }

}
