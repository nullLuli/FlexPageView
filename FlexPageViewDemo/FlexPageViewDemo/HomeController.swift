//
//  HomeController.swift
//  FlexPageView
//
//  Created by nullLuli on 2019/3/11.
//  Copyright © 2019 nullLuli. All rights reserved.
//

import Foundation
import UIKit

class HomeController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView: UITableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
    let datas: [String] = ["default ui", "custom ui"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.rowHeight = 80
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = datas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let control = DefualtUIController()
            navigationController?.pushViewController(control, animated: true)
        case 1:
            let control = CustomMenuUIController()
            navigationController?.pushViewController(control, animated: true)
        default:
            ()
        }
    }
}
