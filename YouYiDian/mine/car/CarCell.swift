//
//  CarCell.swift
//  YouYiDian
//
//  Created by xhgc01 on 2018/1/31.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

class CarCell: UITableViewCell {

    @IBOutlet weak var txtTop: UILabel!
    
    @IBOutlet weak var txtLeft: UILabel!
    
    @IBOutlet weak var txtRight: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
