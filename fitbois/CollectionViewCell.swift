//
//  CollectionViewCell.swift
//  fitbois
//
//  Created by Luc Nglankong on 12/8/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit
import JTAppleCalendar

// Cell of calendar view
class CollectionViewCell: JTAppleCell {
    
    // highlighting for dates with past workout data
    @IBOutlet weak var savedView: UIView!
    
    // highlighting for dates with planned workout data
    @IBOutlet weak var plannedView: UIView!
    
    // highlighting for selected date
    @IBOutlet weak var selectedView: UIView!
    
    // highlighting for todays date
    @IBOutlet weak var todaysView: UIView!
    
    // label for cells date
    @IBOutlet weak var dateLabel: UILabel!
}
