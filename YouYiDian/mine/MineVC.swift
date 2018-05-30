//
//  MineVC.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/20.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit

class MineVC: UITableViewController {
    
    @IBOutlet weak var lFirstCell: UILabel!
    var strHistory = "/charge/queryHistoryChargeRecordes.json"
    var strMyCollect = "/memb/queryFavStation.json"
    //查询押金状态
    var cmdCheckDeposit="/charge/checkDeposits.json"//返回对象

    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITools.checkIsLogin(self)
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        var UserName = GTools.username as NSString
        if UserName.length > 10 {
            UserName = UserName.replacingCharacters(in: NSRange.init(location: 3, length: 4), with: "****") as NSString
        }
        lFirstCell.text = "\(UserName)/退出"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case 0:
            switch indexPath.row{
            case 0:
                if GTools.username != ""{
                    GTools.username = ""
                     MBProgressHUD.showSuccess("退出成功")
                    UITools.checkIsLogin(self)
                }
            case 1://收藏
                ZwqHttp.get(strMyCollect, success: { (ret) in
                    if ret is NSArray{
                        let ary = ret as! NSArray
                        let pHistoryVC = HistoryVC.init(style: UITableViewStyle.plain)
                        pHistoryVC.m_aryData = ary
                        pushView(pHistoryVC)
                    }
                }, failure: { (ret) in
                    print(ret)
                })
            case 2://充电记录
                ZwqHttp.get(strHistory, success: { (ret) in
                    if ret is NSArray{
                        let ary = ret as! NSArray
                        let pHistoryVC = HistoryVC.init(style: UITableViewStyle.plain)
                        pHistoryVC.m_aryData = ary
                        pushView(pHistoryVC)
                    }
                }, failure: { (ret) in
                    
                })
            case 5://充电保证金
                ZwqHttp.get(cmdCheckDeposit, success: { (pData) in
                    if pData is NSDictionary{
                        let pDic = pData as! NSDictionary
                        let strMsg = pDic["msg"] as? String ?? "0"
                        if strMsg == "2"{
                            //未缴纳
                            let pPayDepositVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PayVC") as! PayVC
                            pPayDepositVC.m_numMoney = 0
                            pPayDepositVC.m_bDeposit = true
                            pushView(pPayDepositVC)
                        }else if strMsg == "0"{
                            //已缴纳
                            let pDepositVC = DepositVC()
                            pushView(pDepositVC)
                        }else if strMsg == "1"{
                            //正在申请退款
                            let pDepositVC = DepositVC()
                            pDepositVC.m_bRefund = true
                            pushView(pDepositVC)
                        }else{
                            MBProgressHUD.showError("未知的押金状态:strMsg")
                        }
                    }
                }, failure: { (pData) in
                    MBProgressHUD.showError("押金状态获取失败")
                })
            default:
                MBProgressHUD.showError("功能稍后开启")
            }
        case 1:
            if(indexPath.row==0){
                //我的车型
                let pCarInfoVC = CarInfoVC()
                pushView(pCarInfoVC)
            }else{
                MBProgressHUD.showError("功能稍后开启")
            }
        case 3:
            MBProgressHUD.showSuccess("版本号:1.3.8.20180329.1")
        default:
            MBProgressHUD.showError("功能稍后开启")
        }
    
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
