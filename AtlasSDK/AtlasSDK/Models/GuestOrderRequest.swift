//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

// swiftlint:disable missing_docs

import Foundation

public struct GuestOrderRequest {

    public let checkoutId: String
    public let token: String

    public init(checkoutId: String, token: String) {
        self.checkoutId = checkoutId
        self.token = token
    }

}

extension GuestOrderRequest: JSONRepresentable {

    private struct Keys {
        static let checkoutId = "checkout_id"
        static let token = "token"
    }

    func toJSON() -> JSONDictionary {
        return [
            Keys.checkoutId: checkoutId,
            Keys.token: token
        ]
    }

}
