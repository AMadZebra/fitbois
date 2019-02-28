//
//  TextFieldCell.swift
//  fitbois
//
//  Created by Krishna Chenna on 11/21/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet var setsTxt: UITextField!
    @IBOutlet var repsTxt: UITextField!
    @IBOutlet var weightTxt: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
