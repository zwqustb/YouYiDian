//
//  chargeOver.swift
//  YouYiDian
//
//  Created by xhgc01 on 2018/1/31.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit
/*
 
 */
class chargeOver: UIView {
    weak var m_pChargeVC:chargeVC?
    @IBOutlet weak var lElec: UILabel!
    @IBOutlet weak var lTime: UILabel!
    @IBOutlet weak var lMoney: UILabel!
    
    @IBOutlet weak var lStopReason: UILabel!
    @IBAction func clickPay(_ sender: UIButton) {
//        m_pChargeVC?.tabBarController?.tabBar.isHidden = false
        m_pChargeVC?.showPayVC()
        
    }
    //设置结束充电的数据
    func setData(_ pDic:NSDictionary) {
        let endPower = (pDic["totalPower"] as? NSNumber)?.floatValue ?? 0
        let endMoney = (pDic["totalMoney"] as? NSNumber)?.floatValue ?? 0
        lElec.text = "\(endPower)"
        lTime.text = m_pChargeVC?.labelTime.text
        lMoney.text = "\(endMoney)"
        //充电时长
        let strBgnTime = pDic["startTime"] as? String
        let strEndTime = pDic["endTime"] as? String
        let strDiff = DateTools.getDiffer(strBgnTime!, strEndTime!)
        lTime.text = strDiff
        //充电结束原因
        var nNum = (pDic["stopReason"] as? NSNumber)?.intValue ?? 5
        var aryStopReason = ["用户停止","运营商中止","BMS停止充电","充电机设备故障","连接器断开","其他原因"]
        if(nNum<0||nNum>5){
            nNum = 5
        }
        lStopReason.text = aryStopReason[nNum]
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
