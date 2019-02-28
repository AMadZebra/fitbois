//
//  ExerciseTableCellTableViewCell.swift
//  fitbois
//
//  Created by Luc Nglankong on 11/29/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit

// cell of tableview in DateViewController, contains past exercise information
class ExerciseTableCellTableViewCell: UITableViewCell {
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
