//
//  UITools.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/19.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit
func getNavVC() -> UINavigationController {
    let pNav = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
    return pNav
}
func pushView(_ pVC:UIViewController){
    let pNav = getNavVC()
    pNav.pushViewController(pVC, animated:true)
}
func showView(_ pVC:UIViewController){
    let pNav = getNavVC()
    pNav.pushViewController(pVC, animated:false)
}
var strRelogin = "/Login/relogin.json"
class UITools: NSObject {
    class func relogin(success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Any) -> ()))  {
        if GTools.username != "" {
            let pDic = ["username":GTools.username,"password":GTools.password]
            ZwqHttp.get(strRelogin, paras: pDic, success: { (pData:Any) in
                success(pData)
            }) { (pData:Any) in
                GTools.username = ""
                MBProgressHUD.showError("自动重登陆失败,请重新登陆")
                failure(pData)
            }
        }
    }
    class func checkIsLogin(_ pVC:UIViewController){
       // let strLogin = "/Login/check.json"
        if GTools.username == "" {
            let pLoginVC =  LoginVC.init(nibName: "LoginVC", bundle: nil)
            pVC.present(pLoginVC, animated: false, completion: {
            })
        }else{
            UITools.relogin(success: { (ret) in
            }, failure: { (ret) in
            })
        }
    }
    class func alertInfo(_ pInfo:NSDictionary,on pVC:UIViewController,callback:@escaping (_ index:Int,_ text:NSString)->()){
        let pTitle = pInfo["title"] as? String ?? ""
        let pMsg = pInfo["message"] as? String ?? ""
        let pTextNum = pInfo["textNum"] as? NSString ?? "0"
        let pTextPlaceHolder = pInfo["textPlaceholder"] as? NSString ?? "请输入"
        let strOk = pInfo["OKText"] as? String ?? "确定"
        let strCancel = pInfo["CancelText"] as? String ?? "取消"
        let pAlert = UIAlertController.init(title: pTitle, message: pMsg, preferredStyle: UIAlertControllerStyle.alert)
        if pTextNum.intValue>0 {
            pAlert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = pTextPlaceHolder as String
            }
        }
        let OKAction:UIAlertAction=UIAlertAction.init(title: strOk, style: UIAlertActionStyle.default) { (UIAlertAction) in
            let strText = pAlert.textFields?.last?.text ?? ""
            callback(0,strText as! NSString)
        }
        let cancelAction:UIAlertAction=UIAlertAction.init(title: strCancel, style: UIAlertActionStyle.cancel) { (UIAlertAction) in
        }
        pAlert.addAction(OKAction)
        pAlert.addAction(cancelAction)
        pVC.present(pAlert, animated: true) {
            
        }
    }
}
