//
//  NavVC.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 17/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class NavVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cor do título da Nav. Controller
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // Cor dos botões na Nav. Controller
        self.navigationBar.barTintColor = .white
        
        // Cor do background da Nav. Controller / Nav. Bar
        self.navigationBar.barTintColor = corAzul
        
        // Desabilitar o translúcido
        self.navigationBar.isTranslucent = false
    }
    
    // Status bar em branco
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
