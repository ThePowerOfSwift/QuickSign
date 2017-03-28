//
//  CustomTableViewCell.swift
//  QuickSign
//
//  Created by mac on 2017-03-19.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    // customize the appearance of your cell
    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView?.frame = CGRect(x:20,y:15,width:40,height:60)
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.textLabel?.frame = CGRect(x:70, y:25, width:self.frame.width - 45, height: 20)
        self.detailTextLabel?.frame = CGRect(x:70, y:50, width:self.frame.width - 45, height:15)
        
    }
    
}
