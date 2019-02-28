//
//  FutureViewCell.swift
//  fitbois
//
//  Created by Luc Nglankong on 12/6/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit

// tableview cell for FutureViewController that contains exercise information
class FutureViewCell: UITableViewCell {
    @IBOutlet weak var cellExerciseLabel: UILabel!
    @IBOutlet weak var cellWeightLabel: UILabel!
    @IBOutlet weak var cellRepsLabel: UILabel!
    @IBOutlet weak var cellSetsLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
