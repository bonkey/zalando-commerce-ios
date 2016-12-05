//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK

public class AtlasUIViewController: UIViewController {

    let mainNavigationController: UINavigationController
    private let atlasReachability = AtlasReachability()

    static var instance: AtlasUIViewController? {
        return try? AtlasUI.provide()
    }

    private let loaderView: LoaderView = {
        let view = LoaderView()
        view.hidden = true
        return view
    }()

    init(forProductSKU sku: String) {
        let sizeSelectionViewController = SizeListSelectionViewController(sku: sku)
        mainNavigationController = UINavigationController(rootViewController: sizeSelectionViewController)

        super.init(nibName: nil, bundle: nil)
    }

    required public  init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        loadErrorView()
        addChildViewController(mainNavigationController)
        view.addSubview(mainNavigationController.view)
        mainNavigationController.view.fillInSuperView()
        atlasReachability.setupReachability()
    }

    private func loadErrorView() {
        UserMessage.displayError(AtlasCheckoutError.unclassified)
        UserMessage.hideError()
    }

}

extension AtlasUIViewController {

    func showLoader() {
        loaderView.removeFromSuperview()
        UIApplication.topViewController()?.view.addSubview(loaderView)
        loaderView.fillInSuperView()
        loaderView.buildView()
        loaderView.show()
    }

    func hideLoader() {
        loaderView.hide()
        loaderView.removeFromSuperview()
    }

}
