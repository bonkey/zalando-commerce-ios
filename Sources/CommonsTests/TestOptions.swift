//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation

import ZalandoCommerceAPI
import MockAPI

extension Options {

    static func forTests(clientId: String = TestConsts.clientId,
                         useSandboxEnvironment: Bool = TestConsts.useSandboxEnvironment,
                         salesChannel: String = TestConsts.salesChannel,
                         interfaceLanguage: String = TestConsts.interfaceLanguage,
                         configurationURL: URL = TestConsts.configURL) -> Options {
        return Options(clientId: clientId,
                       salesChannel: salesChannel,
                       useSandboxEnvironment: useSandboxEnvironment,
                       interfaceLanguage: interfaceLanguage,
                       configurationURL: configurationURL)
    }

}
