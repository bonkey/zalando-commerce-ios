//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK

typealias AddressFormCompletion = UserAddress -> Void

class AddressFormViewController: UIViewController, CheckoutProviderType {

    internal let scrollView: KeyboardScrollView = {
        let scrollView = KeyboardScrollView()
        scrollView.keyboardDismissMode = .Interactive
        return scrollView
    }()

    internal lazy var addressStackView: AddressFormStackView = {
        let stackView = AddressFormStackView()
        stackView.addressType = self.addressType
        stackView.axis = .Vertical
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        stackView.layoutMarginsRelativeArrangement = true
        return stackView
    }()

    private let addressType: AddressFormType
    private let addressMode: AddressFormMode
    internal let checkout: AtlasCheckout
    private let addressViewModel: AddressFormViewModel
    internal var completion: AddressFormCompletion?

    init(addressType: AddressFormType, addressMode: AddressFormMode, checkout: AtlasCheckout, completion: AddressFormCompletion?) {
        self.addressType = addressType
        self.addressMode = addressMode
        self.checkout = checkout
        self.completion = completion

        switch addressMode {
        case .createAddress:
            self.addressViewModel = AddressFormViewModel(countryCode: checkout.client.config.salesChannel.countryCode)
        case .updateAddress(let address):
            self.addressViewModel = AddressFormViewModel(equatableAddress: address,
                                                         countryCode: checkout.client.config.salesChannel.countryCode)
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()
        buildView()
        addressStackView.configureData(addressViewModel)
        configureNavigation()
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "address-edit-right-button"
    }

}

extension AddressFormViewController {

    private func configureNavigation() {
        let saveButton = UIBarButtonItem(title: Localizer.string("button.title.save"),
            style: .Plain, target: self, action: #selector(submitButtonPressed))
        navigationItem.rightBarButtonItem = saveButton

        if addressMode == .createAddress {
            let cancelButton = UIBarButtonItem(title: Localizer.string("button.title.cancel"),
                style: .Plain, target: self, action: #selector(cancelButtonPressed))
            navigationItem.leftBarButtonItem = cancelButton
        }
    }

    private dynamic func submitButtonPressed() {
        view.endEditing(true)

        let isValid = addressStackView.textFields.map { $0.validateForm() }.filter { $0 == false }.isEmpty
        guard isValid else { return }

        disableSaveButton()
        checkAddressRequest()
    }

    private dynamic func cancelButtonPressed() {
        dismissView()
    }

    private func dismissView() {
        view.endEditing(true)

        if addressMode == .createAddress {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }

    private func enableSaveButton() {
        navigationItem.rightBarButtonItem?.enabled = true
    }

    private func disableSaveButton() {
        navigationItem.rightBarButtonItem?.enabled = false
    }

}

extension AddressFormViewController: UIBuilder {

    func configureView() {
        view.addSubview(scrollView)
        scrollView.addSubview(addressStackView)
        scrollView.registerForKeyboardNotifications()
    }

    func configureConstraints() {
        scrollView.fillInSuperView()
        addressStackView.fillInSuperView()
        addressStackView.setWidth(equalToView: scrollView)
    }

    func builderSubviews() -> [UIBuilder] {
        return [addressStackView]
    }

}

extension AddressFormViewController {

    private func checkAddressRequest() {
        guard let request = CheckAddressRequest(addressFormViewModel: addressViewModel) else { return enableSaveButton() }
        UserMessage.displayLoader { [weak self] hideLoader in
            self?.checkout.client.checkAddress(request) { [weak self] result in
                hideLoader()
                self?.checkAddressRequestCompletion(result)
            }
        }
    }

    private func createAddressRequest() {
        guard let request = CreateAddressRequest(addressFormViewModel: addressViewModel) else { return enableSaveButton() }
        UserMessage.displayLoader { [weak self] hideLoader in
            self?.checkout.client.createAddress(request) { [weak self] result in
                hideLoader()
                self?.createUpdateAddressRequestCompletion(result)
            }
        }
    }

    private func updateAddressRequest(originalAddress: EquatableAddress) {
        guard let request = UpdateAddressRequest(addressFormViewModel: addressViewModel) else { return enableSaveButton() }
        UserMessage.displayLoader { [weak self] hideLoader in
            self?.checkout.client.updateAddress(originalAddress.id, request: request) { [weak self] result in
                hideLoader()
                self?.createUpdateAddressRequestCompletion(result)
            }
        }
    }

    private func checkAddressRequestCompletion(result: AtlasResult<CheckAddressResponse>) {
        guard let checkAddressResponse = result.process() else { return enableSaveButton() }
        if checkAddressResponse.status == .notCorrect {
            UserMessage.displayError(AtlasCheckoutError.addressInvalid)
            enableSaveButton()
        } else {
            switch addressMode {
            case .createAddress: createAddressRequest()
            case .updateAddress(let address): updateAddressRequest(address)
            }
        }
    }

    private func createUpdateAddressRequestCompletion(result: AtlasResult<UserAddress>) {
        guard let address = result.process() else { return enableSaveButton() }
        dismissView()
        completion?(address)
    }

}
