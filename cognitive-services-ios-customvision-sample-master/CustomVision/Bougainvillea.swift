//
//  Bougainvillea.swift
//  CustomVision
//
//  Created by henrylai on 24/2/19.
//  Copyright © 2019 Adam Behringer. All rights reserved.
//

import Foundation
import UIKit

class Bougainvillea : UIViewController {
    var Labeltext = String()
    
    @IBOutlet var textField: UITextView!
    
    override func viewDidLoad() {
        textField.isEditable = false
    }
    
}
