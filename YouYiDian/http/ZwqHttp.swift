//
//  ZwqHttp.swift
//  bookfans
//
//  Created by zhangwenqiang on 2017/4/12.
//  Copyright © 2017年 chang. All rights reserved.
//

import UIKit
struct requestInfo  {
     var Cmd:String?
     var CmdType:String?//get or post
     var Params:NSDictionary?
}
class ZwqHttp: UIView {
#if DEBUG
#else
#endif
//MARK:参数命令
static var m_pdataTask : URLSessionDataTask?
//（独立用户中心的接口，提供用户信息维护、登录、机构与权限管理相关的接口）
//static var strUserServer="http://ucenter.teach.dev.xhgc/"
//（其他接口）
//static var strServer="http://192.168.100.58:3010/"
static var strServer="http://101.201.198.234:8091"
//接口说明：http://jenkins.it.xhgc/job/xhgc.teaching.ucenter/ws/src/jsdoc/web-api/xhgc.teaching.ucenter/1.0.0/module-api_user.html
//错误码:http://192.168.100.168:16880/xhgc/xhgc.teaching.ucenter/blob/master/src/web/model/retSchema.js
//登陆接口
static var Login="api/user/login/mobile"
//根据refreshtoken生成accessToken
static var RefreshToken="api/user/token/refresh"
//接口说明:http://192.168.100.168:8080/job/xhgc.teaching/ws/src/jsdoc/xhgc.teaching/0.1.0/module-route_res_index.html#~route/res/index/detailApi__anchor
//首页接口http://jenkins.it.xhgc/job/xhgc.teaching/ws/src/jsdoc/xhgc.teaching/0.1.0/module-route_user_index.html
static var HomeFaveritG = "user/favorite/res/list"
//资源详情数据
static var ResDetail="res/detailApi"
//收藏量的接口
static var ResCollectCountG = "res/stat/collect"
//资源列表
static var ResGetList="search/query"
//试题 参数:exerciseCode,torken 
//测试数据7bfc40c0943b11e78af25372ef67cdca
static var TestDetail="exercise/detail"
static var TestCommitAnswer="exercise/commit-answer"
static var TestGetAllAnswer="exercise/get-all-answer"
//试卷相关
static var PaperPostAnswer="exercise/exercise-set/commit-answer"
static var PaperGetAnswer="exercise/exercise-set/get-all-answer"
static var PaperReAnswerG="exercise/exercise-set/re-answer"//G for get,P for Post
//MARK:get post
static var TestPaperDetail="exercise/exercise-set/detail"
//static let aryUserApi=[ZwqHttp.Login,ZwqHttp.RefreshToken,apiUserCurr,apiUserLogout,apiUserUpdate,apiUserIconUpdate]
static var aryNotReconnect=[ZwqHttp.Login,ZwqHttp.RefreshToken]
//static let aryOrgCode=[ZwqHttp.ResDetail,ZwqHttp.TestDetail,ZwqHttp.TestPaperDetail,]
static var LastRequestInfo = requestInfo.init()
    
//多线程
static fileprivate  let group = DispatchGroup()
//无参get
class func get(_ strCmd:String ,success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Any) -> ()))
{
    let strServerPath=self.getServerPath(strCmd)
    let queue = DispatchQueue(label: "com.brycegao.gcdtest", attributes: .concurrent)
    queue.async(group: group) {
        let strToken=GTools.token
        var strPath="\(strServerPath)\(strCmd)"
        if ZwqHttp.isNeedToken(strCmd){
            if strPath.range(of: "?")==nil{
                strPath+="?accessToken=\(strToken)&platform=ios"
                LastRequestInfo.Cmd=strCmd
                LastRequestInfo.Params=nil
            }else{
                strPath+="&accessToken=\(strToken)&platform=ios"
            }
            LastRequestInfo.CmdType="get"
        }
        let strUrl = strPath.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!
        print(strUrl)
        let url = URL(string:strUrl)
        if url == nil{
            return
        }
        //.appending("&num=\(arc4random())"))//添加随机数
        let session = URLSession.shared
     //   session.configuration=URLSessionConfiguration.init()
//        if(m_pdataTask.state == URLSessionTask.State.running)
//        {
         //   m_pdataTask.cancel()
//        }
      //  if (strCmd.index(of: apiMistakeList))
//        let config = URLSessionConfiguration.in
//        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        //let session = URLSession.init(configuration: config)

        
//        let urlRequset = URLRequest.init(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        let pdataTask = session.dataTask(with: url!) { (data, respond, error) in
       //     pMsg?.hide(true)
            if data == nil
            {
                 print("\(strCmd)请求数据为空1")
                DispatchQueue.main.async
                {
//                    if(!(GTools.netManager?.isReachable)!)
//                    {
                        MBProgressHUD.showError("网络未连接")
                        print("\(strCmd)请求数据为空0")
                        failure("无数据,请稍后再试")
                        return
//                    }
                }
                return
            }
            if let data = data {
          //      let strRet = String.init(data: data, encoding: .utf8)
                if let result = try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers]){
                        DispatchQueue.main.async {
                            success(result)
//                            let dicRet=result as! Dictionary<String,Any>
//                            let pCode = dicRet["code"]
//                            if  !(pCode is NSNumber){
//                                failure("错误码:\(pCode ?? "")")
//                            }else{
//                                let nCode=dicRet["code"] as! NSNumber
//                                if(nCode==0){
//                                    let anyData = dicRet["data"]  as Any
//                                    success(anyData)
//                                }else{
//                                    if(ZwqHttp.isShouldRelogin(Int(nCode))){
//                                        if(strCmd.hasPrefix(ZwqHttp.RefreshToken)){
//                                            failure("刷新token失败")
//                                            return
//                                        }
//                                        print(dicRet["msg"] ?? "")
//                                        ZwqHttp.relogin(success: success, failure: failure)
//                                    }else{
//                                        failure(dicRet["msg"] ?? "")
//                                    }
//                                }
//                            }
                        }
                }else{
                    //返回数据不是json
                    MBProgressHUD.showError("返回数据不是json")
                    DispatchQueue.main.async {
                        let httpData = data as Data
                        if httpData.count == 0{
                            failure(data)
                        }else{
                            success(data)
                        }
                        
                    }
                }
              
            }else {
                DispatchQueue.main.async {
//                    if(!(GTools.netManager?.isReachable)!)
//                    {
                        MBProgressHUD.showError("\(strCmd)请求失败,请稍后再试")
//                        return
//                    }
                    failure("请求失败")
                }
            }
        }
        if(!strCmd.hasPrefix(ZwqHttp.RefreshToken) && !strCmd.hasPrefix(ZwqHttp.Login))
        {
            m_pdataTask=pdataTask
        }
        pdataTask.resume()
    }
}

    
    //有参get
    class func get(_ strCmd:String ,paras:Dictionary<String,Any>?, success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Any) -> ()))
    {
        if !ZwqHttp.aryNotReconnect.contains(strCmd) {
            LastRequestInfo.Cmd=strCmd
            LastRequestInfo.Params = paras as? NSDictionary
        }
        
        var i = 0
        var address="\(strCmd)"
        if paras != nil {
            for (key,value) in paras! {
                if i == 0 {
                    address += "?\(key)=\(value)"
                }else {
                    address += "&\(key)=\(value)"
                }
                i += 1
            }
        }
        
        self.get(address, success: success, failure: failure )
    }
    //有参post
    class func post(_ strCmd:String,paras: Dictionary<String,Any>?,success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Any) -> ())) {
        if !ZwqHttp.aryNotReconnect.contains(strCmd) {
            LastRequestInfo.Cmd=strCmd
            LastRequestInfo.CmdType="post"
            LastRequestInfo.Params = paras! as NSDictionary
        }
        let strServer = ZwqHttp.getServerPath(strCmd)
        DispatchQueue.global().async {
            var i = 0
            let httpPath="\(strServer)\(strCmd)"
            var postData: String = "" //""
            if let paras = paras {
                for (key,value) in paras {
                    if i == 0 {
                        postData += "\(key)=\(value)"
                    }else {
                        postData += "&\(key)=\(value)"
                    }
                    i += 1
                }
                let strToken=GTools.token
                if ZwqHttp.isNeedToken(strCmd)
                {
                    postData += "&accessToken=\(strToken)"
                }
            }
            let url = URL(string:httpPath.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!)
            print("post url :\(String(describing: url))")
            var request = URLRequest.init(url: url!)
            request.httpMethod = "POST"
          //  print(postData)
            request.httpBody = postData.data(using: .utf8)
            let session = URLSession.shared
//            if(m_pdataTask.state == URLSessionTask.State.running)
//            {
//                m_pdataTask.cancel()
//            }
            m_pdataTask = session.dataTask(with: request) { (data, respond, error) in
                if let data = data {
                    let ret:String=String.init(data: data, encoding: String.Encoding.utf8)!
                    print(ret)
                    if let result = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                        DispatchQueue.main.async {
                            if result is Dictionary<String, Any>
                            {
                                let dicRet=result as! Dictionary<String,Any>
                                let nCode:NSNumber=dicRet["code"] as! NSNumber
                                if(self.isShouldRelogin( nCode.intValue ) )//token 缺失
                                {
                                    GTools.token=""
                                    ZwqHttp.relogin(success: success, failure: failure)
                                }
                                else if (nCode.intValue == 0)
                                {
                                    let anyData = dicRet["data"]  as Any
                                    success(anyData)
                                }
                                else
                                {
                                    let errorMsg = dicRet["msg"] as! String
                                    failure(errorMsg)
                                }
                            }
                        }
                    }
                }else {
                    DispatchQueue.main.async {
//                        if(!(GTools.netManager?.isReachable)!)
//                        {
                            MBProgressHUD.showError("接口异常,请稍后再试")
                            print(error.debugDescription)
                            failure(error!)
                            return
//                        }
                        
                    }
                    
                }
            }
            m_pdataTask?.resume()
        }
    }
    //有参json post
    class func postJson(_ strCmd:String,paras: NSMutableDictionary,success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Any) -> ())) {
        if !ZwqHttp.aryNotReconnect.contains(strCmd) {
            LastRequestInfo.Cmd=strCmd
            LastRequestInfo.CmdType="postJson"
            LastRequestInfo.Params=paras
        }
        let strServer = ZwqHttp.getServerPath(strCmd)
//        DispatchQueue.global().async {
////            var i = 0
//            let httpPath="\(strServer)\(strCmd)"
////            var postData: String = "" //""
//            if paras != nil {
//                let strToken=GTools.token
//                if ZwqHttp.isNeedToken(strCmd)
//                {
//                    paras.setValue(strToken, forKey: "accessToken")
//                }
//            }
//            //自己写
//            GCnetWorkManager.share().postJson(toServerUrlString: httpPath, withParaments: paras, withSuccessBlock: { (result:Any) in
//                DispatchQueue.main.async {
//                    if result is Dictionary<String, Any>
//                    {
//                        let dicRet=result as! Dictionary<String,Any>
//                        let nCode:NSNumber=dicRet["code"] as! NSNumber
//                        if(self.isShouldRelogin( nCode.intValue ) )//token 缺失
//                        {
//                            GTools.token=""
//                           ZwqHttp.relogin(success: success, failure: failure)
//                        }
//                        else if (nCode.intValue == 0)
//                        {
//                            let anyData = dicRet["data"]  as Any
//                            success(anyData)
//                        }
//                        else
//                        {
//                            let errorMsg = dicRet["msg"] as! String
//                            failure(errorMsg)
//                        }
//                    }
//                }
//            }, withFailureBlock: { (error:Any) in
//                failure(error)
//            })
//        }
    }
    //上传image post
//    class func postImageData(image:UIImage,strCmd:String,paras: Dictionary<String,Any>?,LocalImageName:String,success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Any) -> ()),progress: @escaping ((_ progress: Any) -> ())){
//
//        let strServer1 = ZwqHttp.getServerPath(strCmd)
//        DispatchQueue.global().async {
//            //            var i = 0
//        var httpPath="\(strServer1)\(strCmd)"
//
////          if paras != nil {
//                let strToken=GTools.token
//                if ZwqHttp.isNeedToken(strCmd)
//                {
//                    httpPath = "\(strServer1)\(strCmd)?accessToken=\(strToken)"
//                }
//
//
//            //上传文件接口
////            if (strCmd == apiPhotographUploadOriginalImage){
////                httpPath = "http://file.dev.xhgc/upload/:\(GTools.orgCode)/:\(GTools.username)?accessToken=\(strToken)"
////            }
//
//
//
//
//
//        GCnetWorkManager.uploadImage(withOperations: paras , with: image, withUrlString: httpPath, withLocalImageName: LocalImageName , withSuccessBlock: { (result:Any) in
//            DispatchQueue.main.async {
//                if result is Dictionary<String, Any>
//                {
//                    print(result)
//                    let dicRet=result as! Dictionary<String,Any>
//                    let nCode:NSNumber=dicRet["code"] as! NSNumber
//                    if(self.isShouldRelogin( nCode.intValue ) )//token 缺失
//                    {
//                        GTools.token=""
//                        ZwqHttp.relogin(success: success, failure: failure)
//                    }
//                    else if (nCode.intValue == 0)
//                    {
//                        let anyData = dicRet["data"]  as Any
//                        success(anyData)
//                    }
//                    else
//                    {
//                        let errorMsg = dicRet["msg"] as! String
//                        failure(errorMsg)
//                    }
//                }
//            }
//        }, withFailurBlock: { (error:Any) in
//            failure(error)
//        }) { (progress1:Any) in
//            progress(progress1)
//        }
//      }
//    }
    
    
    //MARK:后台重登陆
    class   func isShouldRelogin(_ nRetNum:Int)->Bool
    {
        //4001 token 缺失 4002 token 失效
        if(!GTools.token.isEmpty && (nRetNum == 4001 || nRetNum == 4002) )
        {
            return true
        }
        return false
    }
    class func relogin(success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Any) -> ()))
    {
        
        self.get(ZwqHttp.RefreshToken, paras: ["refreshToken":GTools.refreshToken], success: { (data:Any) in
            print("刷新token成功")
            ZwqHttp.HandleLoginSuccess(data,success: success,failure: failure)
            return
        }) { (Error) in
           print("刷新Token失败")
            self.get(ZwqHttp.Login, paras: ["userCode":GTools.username,"pwd":GTools.password], success: { (data) in
                print("重登陆成功")
                ZwqHttp.HandleLoginSuccess(data,success: success,failure: failure)
            }) { (error) in
                GTools.refreshToken = ""
                GTools.token = ""
                print("重登陆失败,需要退回到登陆界面")
//                let pNav = getNavVC()
//                pNav.popToRootViewController(animated: true)
            }
        }
    }
    class func HandleLoginSuccess(_ data:Any,success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Any) -> ()))
    {
        var dicRet:Dictionary=data as! Dictionary<String,Any>
        let token = dicRet["accessToken"] as! String
        let orgCode = dicRet["orgCode"] as! String
        let refreshToken = dicRet["refreshToken"] as! String
        GTools.token = token
        GTools.orgCode = orgCode
        GTools.refreshToken = refreshToken
        ZwqHttp.reconnet(success: success,failure: failure)
        return
    }
    class func reconnet(success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Any) -> ()))
    {
        if LastRequestInfo.Cmd != nil {
            if LastRequestInfo.CmdType == "get"{
                if LastRequestInfo.Params == nil
                {
                    ZwqHttp.get(LastRequestInfo.Cmd!,success: success, failure:failure)
                }else{
                    ZwqHttp.get(LastRequestInfo.Cmd!, paras: LastRequestInfo.Params as! Dictionary<String, String>, success: success, failure:failure)
                }
                
            }else if LastRequestInfo.CmdType == "post"{
                ZwqHttp.post(LastRequestInfo.Cmd!, paras: LastRequestInfo.Params as? Dictionary<String, Any>, success: success, failure:failure)
            }
        }
    }
    //MARK:根据命令判断走哪个服务器
    class func getServerPath(_ strCmd:String)->String
    {
//        var cmd = strCmd
//        if let range = strCmd.range(of: "?")  {
//            cmd = strCmd.substring(to: range.lowerBound)
//        }
        let ret=ZwqHttp.strServer
//
//        if aryUserApi.contains(cmd) {
//            ret = ZwqHttp.strUserServer
//        }
//        else{
//        //if aryOrgCode.contains(cmd) {
//            ret = ret+GTools.orgCode+"/"
//        }
        return ret
    }
    class func isNeedToken(_ strCmd:String)->Bool
    {
        if GTools.token.isEmpty {
            return false;
        }
       let aryNoNeedToken=[ZwqHttp.Login,ZwqHttp.RefreshToken]
        for index in 0...aryNoNeedToken.count-1 {
            if strCmd.hasPrefix(aryNoNeedToken[index]) {
               return false
            }
        }
        return true
    }
    //MARK: 下载文件
    class func downloadFile(_ strUrl:String,success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Any) -> ())){
        DispatchQueue.global(qos: .background ).async {
            let strUrl1  = strUrl.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
            let url = URL.init(string: strUrl1!)
            //   let request = NSMutableURLRequest.init(url: url!)
            let session = URLSession.shared
            let downloadTask = session.downloadTask(with: url!) { (location:URL?,response:URLResponse?, error:Error? ) in
                if(error == nil){
                    let fileName = url?.lastPathComponent
                    let locationPath = location!.path
                    //拷贝到用户目录
                    let documnets:String = NSTemporaryDirectory() + fileName!
                    //创建文件管理器
                    let fileManager = FileManager.default
                    try! fileManager.moveItem(atPath: locationPath, toPath: documnets)
                    let newUrl = URL.init(fileURLWithPath:documnets)
                    DispatchQueue.main.async{
                        success(newUrl as Any)
                    }
                }else{
                    DispatchQueue.main.async{
                        failure(error as Any)
                    }
                }
            }
            downloadTask.resume()
           
        }
       
    }
    //MARK:zwqhttp cookie
    class func setCookiePolicy(){
//        ZwqHttp.clearCookies()
//        ZwqHttp.clearCaches()
      let cookieStorage = HTTPCookieStorage.shared
      cookieStorage.cookieAcceptPolicy = .always
//        URLCache.shared.memoryCapacity = 0
//        URLCache.shared.diskCapacity = 0
    }
    class func clearCaches(){
        let cach = URLCache.shared
        cach.removeAllCachedResponses()
    }
    class func clearCookies(){
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies
        //删除cookie
        if cookies != nil{
            for pCookie in cookies!{
                cookieStorage.deleteCookie(pCookie)
            }
        }
    }
    class func saveCookie(){
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies
        cookies?.forEach({ (pHttpCookie) in
            //有效期设为一年后
            let properties = NSMutableDictionary.init(dictionary:pHttpCookie.properties!)
            let expiresDate = NSDate.init(timeIntervalSinceNow: 3600*24*30*12)
            properties[HTTPCookiePropertyKey.expires] = expiresDate
            properties.removeObject(forKey: HTTPCookiePropertyKey.discard)
            cookieStorage.setCookie(HTTPCookie.init(properties: properties as! [HTTPCookiePropertyKey : Any])!)
        })
//        cookieStorage.setValue(GTools.username, forKey: )
//        cookieStorage.setValue(GTools.password, forKey: "password")
//        var cookieProperties = [HTTPCookiePropertyKey: String]()
//        cookieProperties[HTTPCookiePropertyKey.name] = "username"
//        cookieProperties[HTTPCookiePropertyKey.value] = GTools.username
//        cookieProperties[HTTPCookiePropertyKey.domain] = strServer
//        cookieProperties[HTTPCookiePropertyKey.path] = "/" as String
//
//        let cookie = HTTPCookie(properties: cookieProperties)
//        HTTPCookieStorage.shared.setCookie(cookie!)
        
  
    }
}
