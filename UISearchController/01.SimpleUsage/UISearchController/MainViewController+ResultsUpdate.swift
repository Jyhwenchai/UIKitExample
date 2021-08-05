//
//  MainViewController+UISearchResultsUpdating.swift
//  MainViewController+UISearchResultsUpdating
//
//  Created by 蔡志文 on 2021/8/4.
//

import UIKit

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
}
