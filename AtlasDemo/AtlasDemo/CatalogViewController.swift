//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK
import AtlasUI

class CatalogViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var productCollectionView: UICollectionView!

    var articles = [Article]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.productCollectionView.reloadData()
            }
        }
    }

    private let sampleSKUs = [
        "L2711E002-Q11", "GU121D08Z-Q11", "AZ711M001-B11",
        "AZ711N00B-Q11", "MK151F00E-Q11", "M0Q21C068-B11",
        "EV451D00U-302", "RA252F005-802"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        self.navigationController?.navigationBar.accessibilityIdentifier = "catalog-navigation-controller"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadHomepageArticles()
    }

    internal func loadHomepageArticles() {
        AppSetup.checkout?.client.articles([sampleSKUs.first!]) { result in
            switch result {
            case .success(let articles):
                self.articles = articles.sort { $0.id < $1.id }
            case .failure(let error):
                self.displayError(error)
            }
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCollectionViewCell", forIndexPath: indexPath)
        guard let productCell = cell as? ProductCollectionViewCell else {
            return cell
        }

        return productCell.setupCell(withArticle: articles[indexPath.row])
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }

}
