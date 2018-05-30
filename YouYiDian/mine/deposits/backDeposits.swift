//
//  backDeposits.swift
//  YouYiDian
//
//  Created by xhgc01 on 2018/1/30.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

class backDeposits: UIView {
    //确认退还押金
    var cmdBackDeposits="/charge/withDrawChargingDeposit.json"
    weak var m_pDeposit:DepositVC?
    @IBAction func clickCancel(_ sender: UIButton) {
        self.isHidden = true
    }
    
    @IBAction func clickOK(_ sender: UIButton) {
        self.isHidden=true
        ZwqHttp.get(cmdBackDeposits, success: { (pData) in
            if(pData is NSDictionary){
                let pDic = pData as! NSDictionary
                print(pDic)
            }
        }) { (pData) in
            print("退押金请求失败\(pData)")
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
