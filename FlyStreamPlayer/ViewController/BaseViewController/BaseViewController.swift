//
//  BaseViewController.swift
//  FlyStream
//
//  Created by Jingwei Wu on 05/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    var animatedOnNavigationBar = true
    var viewTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = viewTitle
        
        let tempNavigationBackButton = UIBarButtonItem()
        tempNavigationBackButton.title = self.viewTitle
        self.navigationItem.backBarButtonItem = tempNavigationBackButton
        
        
        guard let navigationController = navigationController else {
            return
        }
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
