//
//  ViewTwo.swift
//  CustomVision
//
//  Created by henrylai on 23/2/19.
//  Copyright © 2019 Adam Behringer. All rights reserved.
//

import Foundation
import UIKit

class ViewTwo: UIViewController {
    
    @IBOutlet weak var LabelOne: UILabel!
    var Labeltext = String()
    override func viewDidLoad() {
        LabelOne.text = Labeltext
    }
}
