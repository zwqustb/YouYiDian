//
//  chargingView.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/20.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit

class chargingView: UIView {
    weak var m_pChargeVC:chargeVC?
   

    var orderMoney:NSNumber?
    @IBOutlet weak var lMoney: UILabel!
    @IBOutlet weak var lTime: UILabel!
    @IBOutlet weak var lElectricity: UILabel!
    @IBOutlet weak var lChargeID: UILabel!

    @IBAction func clickStopCharge(_ sender: UIButton) {
        m_pChargeVC?.m_bCharging = false
        m_pChargeVC?.endCharge()
       
       // self.showPayVC()
    }
   


}
