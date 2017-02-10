//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

// swiftlint:disable missing_docs

import Foundation

public struct Cart {
    public let id: String
    public let items: [CartItem]
    public let itemsOutOfStock: [String]
    public let delivery: Delivery
    public let grossTotal: Money
    public let taxTotal: Money
}

extension Cart: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
}

public func == (lhs: Cart, rhs: Cart) -> Bool {
    return lhs.id == rhs.id
}

extension Cart: JSONInitializable {

    fileprivate struct Keys {
        static let id = "id"
        static let items = "items"
        static let itemsOutOfStock = "items_out_of_stock"
        static let delivery = "delivery"
        static let grossTotal = "gross_total"
        static let taxTotal = "tax_total"
    }

    init?(json: JSON) {
        guard let id = json[Keys.id].string,
            let delivery = Delivery(json: json[Keys.delivery]),
            let grossTotal = Money(json: json[Keys.grossTotal]),
            let taxTotal = Money(json: json[Keys.taxTotal])
            else { return nil }
        self.init(id: id,
                  items: json[Keys.items].jsons.flatMap { CartItem(json: $0) },
                  itemsOutOfStock: json[Keys.itemsOutOfStock].jsons.flatMap { $0.string },
                  delivery: delivery,
                  grossTotal: grossTotal,
                  taxTotal: taxTotal)
    }
}
