//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation
import MockAPI

struct TestConsts {

    static let clientId: String = "atlas_Y2M1MzA"
    static let useSandboxEnvironment: Bool = true
    static let salesChannel: String = "82fe2e7f-8c4f-4aa1-9019-b6bde5594456"
    static let interfaceLanguage: String = "en"

    static let configURL = MockAPI.endpointURL(forPath: "/config")
    static let catalogURL = MockAPI.endpointURL(forPath: "/catalog")
    static let checkoutURL = MockAPI.endpointURL(forPath: "/checkout")
    static let loginURL = MockAPI.endpointURL(forPath: "/login")

    static let configLanguage = "de"
    static let configCountry = "DE"
    static let tocURL = "https://www.zalando.de/agb/"
    static let callback = "http://com.zalando.commerce.checkout-demo/redirect"

    static let gateway = "http://localhost.charlesproxy.com:9080"
    static var configLocale: String { return "\(configLanguage)_\(configCountry)" }

}
