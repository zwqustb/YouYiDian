//
//  MapPoint.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/18.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit
import MapKit
class MapPoint: MKPointAnnotation {
    var dicData:NSDictionary?
    var BdLocation:CLLocationCoordinate2D?
    func setData(_ pData:NSDictionary){
        dicData = NSDictionary.init(dictionary: pData)
        let pLng = pData["stationLng"] as? NSNumber
        let pLnt = pData["stationLat"] as? NSNumber
        self.BdLocation = CLLocationCoordinate2D.init(latitude: pLnt?.doubleValue ?? 0, longitude: pLng?.doubleValue ?? 0)
//        let Location = JZLocationConverter.bd09(toGcj02:self.BdLocation!)
//        let Location = JZLocationConverter.bd09(toWgs84: self.BdLocation!)
        let pTitle = pData["stationName"] as? String ?? "未知地点"
        //MARK: 避免坐标被释放
        self.coordinate =  self.BdLocation!
        self.title = pTitle
        self.subtitle = pTitle
       // print(self.coordinate)
    }

}
