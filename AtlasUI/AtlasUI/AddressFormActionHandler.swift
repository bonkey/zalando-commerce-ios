//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import AtlasSDK

protocol AddressFormActionHandlerDelegate: NSObjectProtocol {

    func addressProcessingFinished()
    func dismissView(withAddress address: EquatableAddress, animated: Bool)

}

protocol AddressFormActionHandler {

    weak var delegate: AddressFormActionHandlerDelegate? { get set }

    func submitButtonPressed(dataModel: AddressFormDataModel)

}

extension AddressFormActionHandler {

    func validateAddress(dataModel: AddressFormDataModel, completion: (Bool) -> Void) {
        guard let request = CheckAddressRequest(dataModel: dataModel) else {
            completion(false)
            return
        }

        AtlasUIClient.checkAddress(request) { result in
            guard let checkAddressResponse = result.process() else {
                completion(false)
                return
            }

            if checkAddressResponse.status == .notCorrect {
                UserMessage.displayError(AtlasCheckoutError.addressInvalid)
                completion(false)
            } else {
                completion(true)
            }
        }
    }

}
