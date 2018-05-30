//
//  PopDetail.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/18.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit
import MapKit
class PopDetail: UIView {
    weak var tabBarVC:UITabBarController?
    var m_pDic:NSDictionary?
    var nQuickCount = 0
    var nSlowCount = 0
    var nQuickUnusedCount = 0
    var nSlowUnusedCount = 0
    var location:CLLocationCoordinate2D?
    var BDlocation:CLLocationCoordinate2D?
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var QuickNum: UILabel!
    @IBOutlet weak var QuickUnusedNum: UILabel!
    @IBOutlet weak var SlowNum: UILabel!
    @IBOutlet weak var SlowUnusedNum: UILabel!
    
    @IBOutlet weak var elecFee: UILabel!//电价
    
    @IBOutlet weak var carStopFee: UILabel!
    @IBOutlet weak var time: UILabel!//开放时间
    
    //MARK:网络接口
    var strCollect = "/memb/addFavStation.json"
    override func awakeFromNib() {
        super.awakeFromNib()
        let pTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(PopDetail.viewClicked))
        //detailView?.addGestureRecognizer(pTapGesture)
        self.addGestureRecognizer(pTapGesture)
    }
    @objc func viewClicked() {
        tabBarVC?.tabBar.isHidden = false
        self.isHidden = true
    }
    func setData(_ pData:Any){
        if pData is NSDictionary {
            m_pDic = pData as? NSDictionary
            stationName.text = m_pDic?["stationName"] as? String ?? "数据获取中..."
            position.text = m_pDic?["address"] as? String ?? "数据获取中..."
            let strParkFee = m_pDic?["parkFee"] as? String
            let strElecFee = m_pDic?["electricityFee"] as? String
            elecFee.text = (strElecFee != nil) ? "\(strElecFee!)元/千瓦时" : "未知"
            carStopFee.text = (strParkFee != nil) ? "\(strParkFee!)元/小时" : "未知"
            let openTime = m_pDic?["busineHours"] as? String ?? ""
            let aryEquipment = m_pDic?["equipmentInfoList"] as? Array<NSDictionary>
            if aryEquipment != nil{//充电桩
                for pData in aryEquipment!{
                    let aryConnector = pData["connectorInfos"] as? Array<NSDictionary>//充电枪
                    if aryConnector != nil{
                        for pCon in aryConnector!{
                            let isFast = pCon["isFast"] as? NSNumber
                            let status = pCon["status"] as? NSNumber
                            if isFast?.intValue == 1{
                                nQuickCount+=1
                                if status?.intValue == 1{
                                    nQuickUnusedCount+=1
                                }
                            }else{
                                nSlowCount+=1
                                if status?.intValue == 1{
                                    nSlowUnusedCount+=1
                                }
                            }
                        }
                    }
                }
            }
            QuickNum.text = "\(nQuickCount)"
            SlowNum.text = "\(nSlowCount)"
            if nQuickUnusedCount != 0{
                QuickUnusedNum.text = "空闲\(nQuickUnusedCount)"
            }
            if nSlowUnusedCount != 0{
                SlowUnusedNum.text = "空闲\(nSlowUnusedCount)"
            }
            time.text=openTime
            
        }
    }
    //mark:按钮点击事件
    //点击收藏
    @IBAction func clickCollect(_ sender: UIButton) {
        let pID = m_pDic?["stationId"] as? String ?? ""
        UITools.relogin(success: { (pData:Any) in
            ZwqHttp.get(self.strCollect, paras: ["stationId":pID], success: { (pData:Any) in
                if(pData is NSDictionary){
                    let pDic = pData as? NSDictionary
                    let strMsg = pDic?["msg"] ?? "收藏成功"
                    MBProgressHUD.showSuccess(strMsg as! String)
                }
            }) { (pData:Any) in
                if(pData is NSDictionary){
                    let pDic = pData as! NSDictionary
                    print(pDic)
                }
                MBProgressHUD.showError("服务器忙,请稍后再试")
            }
        }) { (pData:Any) in
            
        }
    }
    
    //点击导航
    @IBAction func clickNavgation(_ sender: UIButton) {
        if location == nil {
            return
        }
        let alertController = UIAlertController.init(title: "导航到设备", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction.init(title: "自带地图", style: UIAlertActionStyle.default, handler: { (pAction) in
            let currentLocation = MKMapItem.forCurrentLocation()
            let toLocation = MKMapItem.init(placemark: MKPlacemark.init(coordinate: self.location!, addressDictionary: nil))
            let pDic = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                        MKLaunchOptionsShowsTrafficKey:NSNumber.init(value: true) ] as [String : Any]

            MKMapItem.openMaps(with: [currentLocation,toLocation], launchOptions:pDic
            )
        }))
    
        if UIApplication.shared.canOpenURL(URL.init(string: "baidumap://")!) {
            alertController.addAction(UIAlertAction.init(title: "百度地图", style: UIAlertActionStyle.default, handler: { (pAction) in
                let bdLocation = self.BDlocation!
                let urlString = "baidumap://map/direction?origin={{我的位置}}&destination=latlng:\(bdLocation.latitude),\(bdLocation.longitude)|name=目的地&mode=driving&coord_type=gcj02".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                UIApplication.shared.openURL(URL.init(string: urlString!)!)
            }))
        }
         if UIApplication.shared.canOpenURL(URL.init(string: "iosamap://")!) {
        alertController.addAction(UIAlertAction.init(title: "高德地图", style: UIAlertActionStyle.default, handler: { (pAction) in
            let urlString = "iosamap://navi?sourceApplication= &backScheme= &lat=\(self.location!.latitude)&lon=\(self.location!.longitude)&dev=0&style=2".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            UIApplication.shared.openURL(URL.init(string: urlString!)!)
        }))
        
    }
        alertController.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: { (pAction) in
            alertController.dismiss(animated: true, completion: {
                
            })
        }))
        getNavVC().present(alertController, animated: true) {
        }
    }
    //点击扫码充电
    @IBAction func clickChargeBtn(_ sender: Any) {
        self.tabBarVC?.tabBar.isHidden = false
        self.tabBarVC?.selectedIndex = 1
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
