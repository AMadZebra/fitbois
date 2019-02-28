//
//  ExpandableHeaderView.swift
//  fitbois
//
//  Created by Luc Nglankong on 12/2/18.
//  Copyright © 2018 Krishna Chenna. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate{
    func toggleSection(header: ExpandableHeaderView, section: Int)
}

// handles expansion capabilities of a cell header for both DateViewController and FutureViewController
// also configures cell header
class ExpandableHeaderView: UITableViewHeaderFooterView {
    let goldColor = UIColor(red: 0.635, green: 0.584, blue: 0, alpha: 1.0)
    let whiteColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int!
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Add ability to recognize when user taps header
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (selectHeaderAction)))
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // handles when user taps header
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer){
        let cell = gestureRecognizer.view as! ExpandableHeaderView
        
        // expand or collapse header
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    
    // configures given cell header
    func customInit(title: String, section: Int, time: String, delegate: ExpandableHeaderViewDelegate){
        // Create a label inside cell header
        let label: UILabel = UILabel(frame: CGRect(x:0, y: -10, width: 347, height: 80))
        
        // Change header label depending on if a time needs to be displayed
        if(time == ""){
            label.text = "\(title)"
        }else{
            label.text = "\(title) \n \(time)"
        }
        
        // Configure cell header label
        label.font = label.font.withSize(25)
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.textAlignment = NSTextAlignment.center
        label.textColor = self.whiteColor
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        // Add label to cell header
        self.addSubview(label)
        
        // save cell header data
        self.section = section
        self.delegate = delegate
    }
    
    
    override func layoutSubviews(){
        super.layoutSubviews()
        
        //Change cell header background color to a dark color
        self.contentView.backgroundColor = UIColor.darkGray 
    }
}
