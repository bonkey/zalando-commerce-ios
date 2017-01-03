//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

struct GetArticleEndpoint: CatalogEndpoint {

    let config: Config

    var path: String { return "articles/\(sku)" }
    let acceptedContentType = "application/x.zalando.article+json"
    var queryItems: [URLQueryItem]? {
        return URLQueryItem.build(from: [
            "client_id": clientId,
            "fields": fields?.joined(separator: ",")
            ])
    }

    let sku: String
    let fields: [String]?

    init(config: Config, sku: String, fields: [String]? = nil) {
        self.config = config
        self.sku = sku
        self.fields = fields
    }

}
