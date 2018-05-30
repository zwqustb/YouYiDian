//
//  AppDelegate.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/18.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,WXApiDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        WXApi.registerApp("wxe70e1d5ee7ee53ea")
        ZwqHttp.setCookiePolicy()
      //  LoginVC.backgroundLogin()
        UITools.relogin(success: { (pData:Any) in
            
        }) { (pData:Any) in
            
        }
        return true
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        WXApi.handleOpen(url as URL!, delegate: self)
        self.AlipayHandleOpenUrl(url as URL)
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
//MARK: Diy func
    func AlipayHandleOpenUrl(_ url:URL){
        if url.host == "safepay" {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic) in
                print(resultDic ?? "")
            })
            // 授权跳转支付宝钱包进行支付，处理支付结果
            AlipaySDK.defaultService().processAuth_V2Result(url, standbyCallback: { (resultDic) in
                print(resultDic ?? "")
            })
            // 解析 auth code
            var ret = url.query
            ret = ret?.removingPercentEncoding
            if (ret! as NSString).length > 0 {
                let pDic = try? JSONSerialization.jsonObject(with: ret!.data(using:.utf8)!, options:.mutableLeaves) as! NSDictionary
                let pDicMemo = pDic!["memo"] as! NSDictionary
                let pInfo = pDicMemo["memo"] as? String ?? ""
                MBProgressHUD.showSuccess(pInfo)
            }
        }
    }
    func onResp(_ resp: BaseResp!) {
        if resp is PayResp{
            let pNavVC = getNavVC()
            pNavVC.popViewController(animated: false)
            switch resp.errCode{
            case 0:
                MBProgressHUD.showSuccess("支付成功－PaySuccess，retcode = \(resp.errCode)" )
            default:
                MBProgressHUD.showError("错误，retcode = \(resp.errCode), retstr = \(resp.errStr)")
            }
        }
    }

}

