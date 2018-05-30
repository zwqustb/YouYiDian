//
//  PayVC.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/21.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit
class PayVC: UITableViewController {
    var strZFBPay = "/charge/pay/genZfbData.json"
    var strWXPay = "/charge/pay/genWxPayData.json"
    var strChargeId = ""
    var m_numMoney:NSNumber?
    var m_bDeposit = false//是否是支付押金界面
    //支付宝支付：
    var cmdDepositZfb="/charge/pay/genZfbDepositData.json"
    //微信支付
    var cmdDepositWX="/charge/pay/genWxPayDepositData.json"
    //获取应该交多少押金
    var cmdGetDepositInfo="/charge/queryChargingDeposit.json"
    @IBOutlet weak var lMoney: UILabel!
    @IBOutlet weak var lNote: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lMoney.text = "\(m_numMoney ?? 0)"
        self.navigationController?.isNavigationBarHidden = false
        if(m_bDeposit){
            self.title = "充电保证金"
            self.navigationController?.navigationBar.isTranslucent = true
            lNote.text = "需缴纳保证金(元)"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if m_bDeposit{
            ZwqHttp.get(self.cmdGetDepositInfo, success: { (pData) in
                if(pData is NSDictionary){
                    let pDic = pData as! NSDictionary
                    let nMoney = pDic["amount"] as? NSNumber ?? (0)
                    self.m_numMoney = nMoney
                    self.lMoney.text = "\(nMoney)"
                }}){ (pData) in
                    print("获取押金详情失败")
            }
        }

    }
    override func viewDidAppear(_ animated: Bool) {
       // lMoney.text = "\(m_numMoney ?? 0)"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let strWX = m_bDeposit ? cmdDepositWX : strWXPay
        let strZfb = m_bDeposit ? cmdDepositZfb : strZFBPay
        let dicParas = m_bDeposit ? nil : ["startChargeSeq":strChargeId]
        switch indexPath.row {
            //微信支付
        case 0:
            ZwqHttp.get(strWX, paras: dicParas, success: { (ret) in
                if ret is NSDictionary{
                    let pDic = ret as! NSDictionary
                    self.WXPay(pDic)
                }
            }, failure: { (ret) in
            })
            
            break
        default:
            ZwqHttp.get(strZfb, paras: dicParas, success: { (ret) in
                if ret is NSDictionary{
                    let pDic = ret as! NSDictionary
                    let strData = pDic["data"] as? String ?? ""
                    self.AliPay(strData)
                }
                
            }, failure: { (ret) in
            })
            
            break
            //支付宝
        }
    }
    func WXPay(_ pDic:NSDictionary){
//        let request = PayReq.init()        
//        WXApi.send(request);
        let req = PayReq.init()
     //   let appid = pDic["appid"] as？ String//wxe70e1d5ee7ee53ea
        //WXApi.registerApp(appid)
        let stamp = pDic["timestamp"] as? NSString ?? "0"
        req.openID = pDic["appid"] as? String ?? "wxe70e1d5ee7ee53ea"
        req.partnerId = pDic["partnerid"] as? String ?? "1488801132"
        req.prepayId = pDic["prepayid"] as? String
        if req.prepayId == nil {
            
            return
        }
        req.nonceStr = pDic["noncestr"] as? String ?? "nonceStr"
        req.timeStamp =  UInt32(stamp as String)!
        req.package = "Sign=WXPay"
        req.sign = pDic["signature"] as? String ?? "signature"
        
     //   req.openID = "wxe70e1d5ee7ee53ea"
//        req.partnerId = "1900000109"
//        req.prepayId = "1101000000140415649af9fc314aa427"
//        req.package = "Sign=WXPay"
//        req.nonceStr = "1101000000140429eb40476f8896f4c9"
//        req.timeStamp = UInt32("1398746574")!
//        req.sign = "7FFECB600D7157C5AA49810D2D8F28BC2811827B"
        WXApi.send(req)
    }
    func AliPay(_ strData:String){
        let appScheme = "zhongqiYouyidian"
        AlipaySDK.defaultService().payOrder(strData, fromScheme: appScheme) { (pDic) in
            let pNavVC = getNavVC()
            pNavVC.popViewController(animated: false)
        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
