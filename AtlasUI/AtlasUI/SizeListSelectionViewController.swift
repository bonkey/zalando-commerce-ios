//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import AtlasSDK

final class SizeListSelectionViewController: UIViewController {

    let sku: String
    var tableViewDelegate: SizeListTableViewDelegate? {
        didSet {
            tableView.delegate = tableViewDelegate
        }
    }
    var tableViewDataSource: SizeListTableViewDataSource? {
        didSet {
            tableView.dataSource = tableViewDataSource
            tableView.isHidden = tableViewDataSource?.article.hasSingleUnit ?? true
            tableView.reloadData()
        }
    }

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.isOpaque = false
        tableView.isHidden = true
        return tableView
    }()

    init(sku: String) {
        self.sku = sku
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildView()
        fetchSizes()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

}

extension SizeListSelectionViewController: UIBuilder {

    func configureView() {
        view.addSubview(tableView)
        view.backgroundColor = .clear
        view.isOpaque = false
        tableView.registerReusableCell(UnitSizeTableViewCell.self)
        showCancelButton()
    }

    func configureConstraints() {
        tableView.fillInSuperview()
    }

}

extension SizeListSelectionViewController {

    fileprivate func fetchSizes() {
        AtlasUIClient.article(withSKU: self.sku) { [weak self] result in
            guard let article = result.process(forceFullScreenError: true) else { return }
            self?.tableViewDelegate = SizeListTableViewDelegate(article: article, completion: self?.showCheckoutScreen)
            self?.tableViewDataSource = SizeListTableViewDataSource(article: article)
            self?.showCancelButton()
        }
    }

    fileprivate func showCheckoutScreen(_ selectedArticleUnit: SelectedArticleUnit) {
        let hasSingleUnit = selectedArticleUnit.article.hasSingleUnit
        guard Atlas.isAuthorized() else {
            let actionHandler = NotLoggedInSummaryActionHandler()
            let price = selectedArticleUnit.unit.price.amount
            let dataModel = CheckoutSummaryDataModel(selectedArticleUnit: selectedArticleUnit, totalPrice: price)
            let viewModel = CheckoutSummaryViewModel(dataModel: dataModel, layout: NotLoggedInLayout())
            return displayCheckoutSummaryViewController(viewModel, actionHandler: actionHandler)
        }

        AtlasUIClient.customer { [weak self] customerResult in
            guard let customer = customerResult.process(forceFullScreenError: hasSingleUnit) else { return }

            LoggedInSummaryActionHandler.create(customer: customer, selectedArticleUnit: selectedArticleUnit) { actionHandlerResult in
                guard let actionHandler = actionHandlerResult.process(forceFullScreenError: hasSingleUnit) else { return }

                let dataModel = CheckoutSummaryDataModel(selectedArticleUnit: selectedArticleUnit, cartCheckout: actionHandler.cartCheckout)
                let viewModel = CheckoutSummaryViewModel(dataModel: dataModel, layout: LoggedInLayout())
                self?.displayCheckoutSummaryViewController(viewModel, actionHandler: actionHandler)
            }
        }
    }

    fileprivate func displayCheckoutSummaryViewController(_ viewModel: CheckoutSummaryViewModel,
                                                          actionHandler: CheckoutSummaryActionHandler) {
        let hasSingleUnit = viewModel.dataModel.selectedArticleUnit.article.hasSingleUnit
        let checkoutSummaryVC = CheckoutSummaryViewController(viewModel: viewModel)
        checkoutSummaryVC.actionHandler = actionHandler
        navigationController?.pushViewController(checkoutSummaryVC, animated: !hasSingleUnit)
    }

}
