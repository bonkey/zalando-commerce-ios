//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation
import UIKit
import AtlasSDK

typealias SizeListTableViewDelegateCompletion = (_ selectedArticle: SelectedArticle) -> Void

class SizeListTableViewDelegate: NSObject {

    let article: Article
    fileprivate let completion: SizeListTableViewDelegateCompletion?

    init(article: Article, completion: SizeListTableViewDelegateCompletion?) {
        self.article = article
        self.completion = completion

        if article.hasSingleUnit {
            completion?(SelectedArticle(article: article, selectedUnitIndex: 0))
        }
    }

}

extension SizeListTableViewDelegate: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedArticle = SelectedArticle(article: article, selectedUnitIndex: indexPath.row)
        completion?(selectedArticle)
    }

}
