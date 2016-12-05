//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

/**
 Represents a single article
 */

public struct SelectedArticleUnit {

    public let article: Article
    public let selectedUnitIndex: Int

    public init(article: Article, selectedUnitIndex: Int) {
        self.article = article
        self.selectedUnitIndex = selectedUnitIndex
    }

    public var sku: String {
        return unit.id
    }

    public var unit: Article.Unit {
        return article.availableUnits[selectedUnitIndex]
    }

    public var priceAmount: MoneyAmount {
        return unit.price.amount
    }

}

public struct Article {

    public let id: String
    public let name: String
    public let color: String
    public let brand: Brand
    public let units: [Unit]
    public let availableUnits: [Unit]
    public let media: Media

    public var hasSingleUnit: Bool {
        return units.count == 1
    }

    public var hasAvailableUnits: Bool {
        return !availableUnits.isEmpty
    }

    public var thumbnailURL: URL? {
        return media.images.first?.catalogURL
    }

    public struct Brand {
        public let name: String
    }

    public struct Unit {
        public let id: String
        public let size: String
        public let price: Money
        public let originalPrice: Money
        public let available: Bool
        public let stock: Int
        public let partner: Partner?
    }

    public struct Media {
        public let images: [Image]
    }

    public struct Image {
        public let order: Int
        public let catalogURL: URL
        public let catalogHDURL: URL
        public let detailURL: URL
        public let detailHDURL: URL
        public let largeURL: URL
        public let largeHDURL: URL
    }

    public struct Partner {
        public let id: String
        public let name: String
        public let detailsURL: String
    }

}

extension Article: JSONInitializable {

    init?(json: JSON) {
        guard let id = json["id"].string,
            let name = json["name"].string,
            let color = json["color"].string,
            let brand = Brand(json: json["brand"]),
            let media = Media(json: json["media"])
        else { return nil }

        self.id = id
        self.name = name
        self.color = color
        self.media = media
        self.brand = brand
        self.units = json["units"].arrayValue.flatMap { Article.Unit(json: $0) }
        self.availableUnits = units.filter { $0.available }
    }

}

extension Article.Unit: JSONInitializable {

    init?(json: JSON) {
        guard let id = json["id"].string,
            let size = json["size"].string,
            let price = Money(json: json["price"]),
            let originalPrice = Money(json: json["original_price"]),
            let available = json["available"].bool,
            let stock = json["stock"].int
        else { return nil }

        self.id = id
        self.size = size
        self.price = price
        self.originalPrice = originalPrice
        self.stock = stock
        self.available = available

        self.partner = Article.Partner(json: json["partner"])
    }

    var isDiscounted: Bool {
        return price < originalPrice
    }

}

extension Article.Brand: JSONInitializable {
    init?(json: JSON) {
        guard let name = json["name"].string else { return nil }

        self.name = name
    }
}

extension Article.Media: JSONInitializable {

    init?(json: JSON) {
        self.images = json["images"].arrayValue.flatMap { Article.Image(json: $0) }
    }

}

extension Article.Image: JSONInitializable {

    init?(json: JSON) {
        guard let order = json["order"].int,
            let catalogURL = json["catalog"].URL,
            let catalogHDURL = json["catalog_hd"].URL,
            let detailURL = json["detail"].URL,
            let detailHDURL = json["detail_hd"].URL,
            let largeURL = json["large"].URL,
            let largeHDURL = json["large_hd"].URL
        else { return nil }
        self.order = order
        self.catalogURL = catalogURL
        self.catalogHDURL = catalogHDURL
        self.detailURL = detailURL
        self.detailHDURL = detailHDURL
        self.largeURL = largeURL
        self.largeHDURL = largeHDURL
    }

}

extension Article.Partner: JSONInitializable {

    init?(json: JSON) {
        guard let id = json["id"].string,
            let name = json["name"].string,
            let detailsURL = json["detail_url"].string
        else { return nil }

        self.id = id
        self.name = name
        self.detailsURL = detailsURL
    }

}
