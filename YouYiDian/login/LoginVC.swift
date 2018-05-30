//
//  LoginVC.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/19.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    var strGetSMS = "/Login/code/sendSMS.json"//?phonenumber=
    //"+"username="+uname+"&password="+passwd,
    static var strLogin = "/Login/check.json"
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getSMSCode(_ sender: UIButton) {
        if username.text == nil {
            MBProgressHUD.showError("请输入手机号")
            return
        }
        ZwqHttp.get(strGetSMS, paras: ["phonenumber":username.text!], success: { (pData:Any) in
             MBProgressHUD.showSuccess("请等待短信")
        }) { (pData:Any) in
            MBProgressHUD.showError("请求失败,请重试")
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        if username.text == nil {
            MBProgressHUD.showError("请输入手机号")
            return
        }
        if password.text == nil {
            MBProgressHUD.showError("请输入验证码")
            return
        }
        ZwqHttp.get(LoginVC.strLogin, paras: ["username":username.text!,"password":password.text!], success: { (pData:Any) in
            if pData is NSDictionary{
                let pDic = pData as! NSDictionary
                let bOK = pDic["success"] as! NSNumber
                if(bOK.boolValue){
                    self.dismiss(animated: true, completion: nil)
                    GTools.username = self.username.text!
                    GTools.password = self.password.text!
                    ZwqHttp.saveCookie()
                }else{
                    let strMsg = pDic["msg"] as? String ?? ""
                    MBProgressHUD.showError(strMsg)
                }
            }
        }) { (pData:Any) in
           MBProgressHUD.showError("登录失败,请稍后重试")
        }
    }
    class func backgroundLogin(){
        let username = GTools.username
        let pwd = GTools.password
        if username != "" {
            ZwqHttp.get(LoginVC.strLogin,paras: ["username":username,"password":pwd], success: { (pData) in
                print("后台登陆成功")
            }, failure: { (pAny) in
                print("后台登陆失败")
            })
        }
    }
    @IBAction func DidEndOnExit(_ sender: UITextField) {
        sender.resignFirstResponder()
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
