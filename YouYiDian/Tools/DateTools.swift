//
//  DateTools.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/24.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit

class DateTools: NSObject {
    class func date2String(_ pDate:Date,_ strFormat:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = strFormat
        return dateFormatter.string(from: pDate)
    }
    class func string2Date(_ strDate:String,_ strFormat:String)->Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = strFormat
        let date = dateFormatter.date(from: strDate)
        return date!
    }
    //MARK: 毫秒数转化为时分秒
    class func NumToTimeString(_ nTime:NSNumber )->String{
        let dTime = nTime.doubleValue
        let dSecond = dTime/1000
        var dMin = 0
        if dSecond > 60 {
            dMin = Int(dSecond/60)
         //   dSecond = dSecond % 60
            return "\(dMin)分钟"
        }else{
            return "\(dSecond)秒"
        }
    }
    //保存订单的开始充电时间
    class func saveNow(_ strKey:String){
        let strFormat = "yyyy-MM-dd HH:mm:ss"
        let nowDate = Date.init()
        let strNow = DateTools.date2String(nowDate, strFormat)
        UserDefaults.standard.set(strNow, forKey: strKey)
        UserDefaults.standard.synchronize()
    }
    //通过订单号,结束时间,获得充电持续时间
    class func getHHMMSSFormSS(seconds:Int) -> String {
        let nhour = Int(seconds/3600)
        var str_hour = "\(nhour)"
        if nhour<10{str_hour = "0\(nhour)"}
        let nMin = (seconds%3600)/60
        var str_minute = "\(nMin)"
        if nMin<10 {str_minute = "0\(nMin)"}
        let nSec = seconds%60
        var strSec = "\(nSec)"
        if nSec<10 {strSec = "0\(nSec)"}
        let format_time = "\(str_hour):\(str_minute):\(strSec)"
        return format_time as String
    }
    class func getOrderTimeDiff(_ strKey:String,_ strEndTime:String)->String{
        let strBgnTime = UserDefaults.standard.string(forKey: strKey)
        if strBgnTime != nil {
            let strDiff = DateTools.getDiffer(strBgnTime!, strEndTime)
            return strDiff
        }
        return "起始时间不存在"
    }
    class func getDiffer(_ strBgnTime:String,_ strEndTime:String)->String{
        let strFormat = "yyyy-MM-dd HH:mm:ss"
        let EndDate = DateTools.string2Date(strEndTime, strFormat)
        let StartDate = DateTools.string2Date(strBgnTime, strFormat)
        let second = EndDate.timeIntervalSince(StartDate)
        let strDiff = DateTools.getHHMMSSFormSS(seconds: Int(second))
        return strDiff
    }
    class func Int2Date(_ second:Int)->Date{
        return Date.init(timeIntervalSince1970: TimeInterval(second))
    }
}
