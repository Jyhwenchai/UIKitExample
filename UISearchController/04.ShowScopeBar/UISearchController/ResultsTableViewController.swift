//
//  ResultsTableViewController.swift
//  ResultsTableViewController
//
//  Created by 蔡志文 on 2021/8/4.
//

import UIKit

class ResultsTableViewController: UITableViewController {

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
        
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        view.addSubview(emptyLabel)
    }


   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyLabel.frame = view.bounds
    }
}

extension ResultsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resultColors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell") as! ColorCell
        let color = resultColors[indexPath.row]
        cell.nameLabel.text = color.name
        cell.nameLabel.textColor = color.value
        cell.colorView.backgroundColor = color.value
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
}
