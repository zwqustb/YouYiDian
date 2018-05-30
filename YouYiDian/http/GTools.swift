//
//  GTools.swift
//  bookfans
//
//  Created by zhangwenqiang on 2017/4/10.
//  Copyright © 2017年 chang. All rights reserved.
//

import UIKit

class GTools: NSObject {
 //   static var netManager:AFNetworkReachabilityManager?=nil
    public class func isLogin()->Bool
    {
        return !self.token.isEmpty
    }
//只能用于引导页判断
    static var firstLogin:String{
        set{
            GTools.saveKey(newValue, key: "firstLogin")
        }
        get{
            return GTools.getKey("firstLogin")
        }
    }
    static var username:String{
        set{
            GTools.saveKey(newValue, key: "username")
        }
        get{
           return GTools.getKey("username")
        }
    }
    static var password:String{
        set{
            GTools.saveKey(newValue, key: "password")
        }
        get{
            return GTools.getKey("password")
        }
    }
    public class func alert(title str1:String,msg str2:String,strOk str3:String,strCamcel str4:String,clickOK:@escaping ()->())->UIAlertController
    {
        let pAlert=UIAlertController.init(title: str1, message: str2, preferredStyle: UIAlertControllerStyle.alert)
        let OKAction:UIAlertAction=UIAlertAction.init(title: str3, style: UIAlertActionStyle.default) { (UIAlertAction) in
            clickOK()
        }
        let cancelAction:UIAlertAction=UIAlertAction.init(title: str4, style: UIAlertActionStyle.cancel) { (UIAlertAction) in
        }
        pAlert.addAction(OKAction)
        pAlert.addAction(cancelAction)
        //设置弹出框对齐方式:居左对齐
        let attrMsg = NSMutableAttributedString.init(string: str2)
        let paragraph:NSMutableParagraphStyle=NSMutableParagraphStyle.init()
        paragraph.alignment=NSTextAlignment.left
//        attrMsg.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 15), range: NSRange(location:0,length:attrMsg.length))
//        attrMsg.addAttribute(NSParagraphStyleAttributeName, value:paragraph, range: NSRange(location:0,length:attrMsg.length))
        pAlert.setValue(attrMsg, forKey: "attributedMessage")
        return pAlert
    }
    public class func alert(title str1:String,msg str2:String,strOk str3:String,clickOK:@escaping ()->())->UIAlertController
    {
        let pAlert=UIAlertController.init(title: str1, message: str2, preferredStyle: UIAlertControllerStyle.alert)
        let OKAction:UIAlertAction=UIAlertAction.init(title: str3, style: UIAlertActionStyle.default) { (UIAlertAction) in
            clickOK()
        }
        pAlert.addAction(OKAction)
        return pAlert
    }
    public class func dateFormat(_ strIn:String)->String
    {
        if(!strIn.isEmpty)
        {
            let df:DateFormatter=DateFormatter.init()
            df.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date:Date=df.date(from:strIn)!
            let tz:TimeZone=NSTimeZone.local //TimeZone.init(identifier: "UTC")!
            df.timeZone=tz
            df.dateFormat="yyyy-MM-dd HH:mm:ss"
            return df.string(from: date)
        }
        return ""
    }
    public class func dateFormat(_ strIn:String,format strFormat:String)->String
    {
        if(!strIn.isEmpty && !strFormat.isEmpty)
        {
            let df:DateFormatter=DateFormatter.init()
            df.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date:Date=df.date(from:strIn)!
            let tz:TimeZone=NSTimeZone.local //TimeZone.init(identifier: "UTC")!
            df.timeZone=tz
            df.dateFormat=strFormat
            return df.string(from: date)
        }
        return ""
    }
    //MARK:token
    static var refreshToken:String{
        get{
           
           return GTools.getKey("refreshToken")
        }
        set{
            GTools.saveKey(newValue, key:"refreshToken")
        }
    }
    static var token:String{
        get{
            return GTools.getKey("saveToken")
        }
        set{
            GTools.saveKey(newValue, key:"saveToken")
        }
    }
    static var orgCode:String{
        get{
            return GTools.getKey("orgCode")
        }
        set{
            GTools.saveKey(newValue, key:"orgCode")
        }
    }
    class func saveKey(_ strIn:String?,key:String) {
        var strSave = strIn
        if strSave == nil {
            strSave=""
        }
        UserDefaults.standard.set(strSave, forKey:key)
        UserDefaults.standard.synchronize()
    }
    class func getKey(_ key:String)->String{
        let token=UserDefaults.standard.object(forKey: key)
        if (token != nil && token is String) {
            let ret=token as! String
            return ret
        }
        return  ""
    }
    //MARK:net
     public class func monitorNet()
     {
      //  netManager = GCnetWorkManager.checkNetworkReachability()
  //      netManager =  AFNetworkReachabilityManager.shared()// AFNetworkReachabilityManager.SM_SHARED
        
//        //2.监听改变
//        [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//            //发送网络状态变化的通知
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"networkStateChange" object:[NSNumber numberWithInteger:status]];
//            switch (status) {
//            case AFNetworkReachabilityStatusUnknown:
//            break;
//            case AFNetworkReachabilityStatusNotReachable:
//            break;
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//            break;
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//            break;
//            default:
//            break;
//            }
//            }];
//        //开启监听，记得开启，不然不走block
   //    netManager?.startMonitoring()
//        manager = manger;
     }
    //MARK:操作流程工具
    //判断是否登陆,未登录则弹框提示,
    public class func checkLogin(_ parentVC:UIViewController)->Bool
    {
        if(self.token.isEmpty  )
        {
            let pAlert=GTools.alert(title: "你未登录,请登录后操作", msg: "", strOk: "好的",strCamcel:"取消", clickOK: {
                NotificationCenter.default.post(name: Notification.Name("showLogin"), object: nil)
            })
            parentVC.present(pAlert, animated: true, completion: {
                
            })
            return false
        }
        return true
    }
    //MARK:时间格式
    public class func dateFormatStandard(_ strIn:String)->String
    {
        if(!strIn.isEmpty)
        {
            let df:DateFormatter=DateFormatter.init()
            df.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date:Date=df.date(from:strIn)!
            let tz:TimeZone=NSTimeZone.local //TimeZone.init(identifier: "UTC")!
            df.timeZone=tz
            df.dateFormat="yyyy-MM-dd HH:mm:ss"
            return df.string(from: date)
        }
        return ""
    }
    public class func dateFormatStandard(_ strIn:String,format strFormat:String)->String
    {
        if(!strIn.isEmpty && !strFormat.isEmpty)
        {
            let df:DateFormatter=DateFormatter.init()
            df.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date:Date=df.date(from:strIn)!
            let tz:TimeZone=NSTimeZone.local //TimeZone.init(identifier: "UTC")!
            df.timeZone=tz
            df.dateFormat=strFormat
            return df.string(from: date)
        }
        return ""
    }
}


