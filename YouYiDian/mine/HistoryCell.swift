//
//  HistoryCell.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/22.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    @IBOutlet weak var lDate: UILabel!
    @IBOutlet weak var lLocation: UILabel!
    @IBOutlet weak var lTime: UILabel!
    @IBOutlet weak var lMoney: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(_ pDic:NSDictionary) {
        lDate.text = pDic["startTime"] as? String
         lLocation.text = pDic["stationAddress"] as? String
        let ms = pDic["totalTime"] as? NSNumber
        if ms != nil {
            lTime.text = "充电时间:\(DateTools.NumToTimeString(ms!))"
        }
        let money = (pDic["totalMoney"] as? NSNumber)?.floatValue ?? 0
        lMoney.text = "充电费用:\(money)元"
    }
}
