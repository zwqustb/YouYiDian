//
//  DepositVC.swift
//  YouYiDian
//
//  Created by xhgc01 on 2018/1/30.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

class DepositVC: UIViewController {
    var m_pBackView:backDeposits?
    var m_pBackOKView:BackDepositOK?
    var m_bRefund:Bool = false//
    //获取应该交多少押金
    var cmdGetDepositInfo="/charge/queryChargingDeposit.json"
    @IBOutlet weak var lMoney: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationController?.isNavigationBarHidden = false
      
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        if(m_bRefund){
            self.showBackOK()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        
        ZwqHttp.get(cmdGetDepositInfo, success: { (pData) in
            if(pData is NSDictionary){
                let pDic = pData as! NSDictionary
                let nMoney = pDic["amount"] as? NSNumber ?? (0)
                self.lMoney.text = "\(nMoney)"
            }}){ (pData) in
                print("获取押金详情失败")
        }
        m_pBackOKView?.frame = self.view.bounds
    }
    func showBackConfirm(){
        if m_pBackView == nil {
            m_pBackView = Bundle.main.loadNibNamed("backDeposits", owner: nil, options: nil)?.first as? backDeposits
            m_pBackView?.frame = self.view.bounds
            m_pBackView?.m_pDeposit = self
//            m_pBackView?.center = self.view.center
            self.view.addSubview(m_pBackView!)
        }
        m_pBackView?.isHidden = false
    }
    func showBackOK(){
        if m_pBackOKView == nil {
            m_pBackOKView = Bundle.main.loadNibNamed("BackDepositOK", owner: nil, options: nil)?.first as? BackDepositOK
            m_pBackOKView?.frame = self.view.bounds
            m_pBackOKView?.m_pDepositVC = self
            //            m_pBackOKView?.center = self.view.center
            self.view.addSubview(m_pBackOKView!)
        }
        m_pBackOKView?.isHidden = false
    }
    @IBAction func clickBackDeposit(_ sender: UIButton) {
        self.showBackConfirm()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
