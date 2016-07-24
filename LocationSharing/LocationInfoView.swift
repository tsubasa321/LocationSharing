//
//  LocationInfoView.swift
//  LocationSharing
//
//  Created by Qi (Alvin) Jing on 2016-07-24.
//  Copyright © 2016 Qi (Alvin) Jing. All rights reserved.
//

import UIKit

class LocationInfoView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    
    @IBOutlet weak var longitudeLabel: UILabel!

    @IBOutlet weak var nameValueLabel: UILabel!
    
    @IBOutlet weak var latitudeValueLabel: UILabel!
    
    @IBOutlet weak var longitudeValueLabel: UILabel!
    
    @IBAction func didClickButton(sender: AnyObject) {
        
        print("button clicked")
        
    }
}
