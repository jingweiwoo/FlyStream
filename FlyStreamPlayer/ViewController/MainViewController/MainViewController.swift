//
//  MainViewController.swift
//  OpenCVToy
//
//  Created by Jingwei Wu on 08/02/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {

    @IBOutlet weak var mainTableView: UITableView!
    


    let cellElements: [String] = ["Streaming"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewTitle = NSLocalizedString("Stream Manger", comment: "")
                
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.isScrollEnabled = false
        mainTableView.scrollsToTop = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareViewController(storyboardName: String, identifier: String) -> UIViewController {
        let board = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return board.instantiateViewController(withIdentifier: identifier)
    }
    
    func performSegue(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: TableView dataSource
extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellElements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowNumber = indexPath.row
        let cellIdentifier = "cellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = cellElements[rowNumber]
        
        return cell!
    }
}

// MARK: TableView delegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowNumber = indexPath.row
        
        var viewController: StreamViewController = self.prepareViewController(storyboardName: "Stream", identifier: "StreamViewController") as! StreamViewController
    
        self.performSegue(viewController: viewController)
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
}
