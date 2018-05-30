//
//  BackDepositOK.swift
//  YouYiDian
//
//  Created by xhgc01 on 2018/1/31.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

class BackDepositOK: UIView {
    var cmdCancelBack = "/charge/cancelChargingDeposit.json"
    weak var m_pDepositVC:DepositVC?
    @IBOutlet weak var lMoneyNum: UILabel!
    @IBAction func clickOK(_ sender: Any) {
        m_pDepositVC?.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        ZwqHttp.get(cmdCancelBack, success: { (pData:Any) in
            var strMsg = ""
            if pData is NSDictionary{
                let pDic = pData as! NSDictionary
                let nRet = pDic["success"] as? NSNumber ?? (0)
                let bRet = nRet.boolValue
                if bRet{
                     MBProgressHUD.showError("取消退押金成功")
                     self.m_pDepositVC?.navigationController?.popViewController(animated: true)
                     return
                }else{
                    strMsg = pDic["msg"] as? String ?? ""
                }
            }
           MBProgressHUD.showError("取消退押金失败,\(strMsg)")
        }) { (pData:Any) in
            MBProgressHUD.showError("取消退押金请求失败")
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
