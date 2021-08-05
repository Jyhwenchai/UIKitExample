//
//  ResultsTableViewController.swift
//  ResultsTableViewController
//
//  Created by 蔡志文 on 2021/8/4.
//

import UIKit

class ResultsTableViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    var resultColors: [Color] = [] {
        didSet {
            emptyLabel.isHidden = !resultColors.isEmpty
            tableView.reloadData()
        }
    }
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.text = "No Results."
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        view.addSubview(emptyLabel)
        view.addSubview(tableView)
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyLabel.frame = view.bounds
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13, *) {
            statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = 20
        }
        let navigationBarHeight: CGFloat = statusBarHeight + 56 // status bar height + search Bar height
        tableView.frame = CGRect(x: 0, y: navigationBarHeight, width: view.bounds.width, height: view.bounds.height - navigationBarHeight)
    }
    
}

extension ResultsTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resultColors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell") as! ColorCell
        let color = resultColors[indexPath.row]
        cell.nameLabel.text = color.name
        cell.nameLabel.textColor = color.value
        cell.colorView.backgroundColor = color.value
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = DetailViewController(resultColors[indexPath.row])
        presentingViewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
