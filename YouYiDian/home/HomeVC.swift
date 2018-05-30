//
//  HomeVC.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/18.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit
import MapKit
class HomeVC: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    let strGetPoint = "/station/StationInfo/queryAroundStation.json"
    let strGetPointDetail = "/station/StationInfo/queryStationDetail.json"
    var m_pMap:MKMapView?
    var m_pLocation:CLLocationManager?
    var m_aryPoints = NSMutableArray.init(capacity: 5)
    var m_pPopView:PopDetail?
    override func viewDidLoad() {
        super.viewDidLoad()
        //map
        m_pMap = MKMapView.init(frame: self.view.bounds)
        m_pMap?.delegate = self
       
        m_pMap?.userTrackingMode = MKUserTrackingMode.follow
        m_pMap?.mapType = MKMapType.standard
     //   m_pMap?.showsTraffic = false
        self.view.addSubview(m_pMap!)
        
        //location
        m_pLocation = CLLocationManager.init()
        m_pLocation?.delegate=self
        m_pLocation?.distanceFilter = 200
        m_pLocation?.desiredAccuracy = kCLLocationAccuracyBest
        m_pLocation?.startUpdatingLocation()
        m_pMap?.showsUserLocation = true
        
        self.initPopView()
        // Do any additional setup after loading the view.
//        self.addPoint()
    }


    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
            MBProgressHUD.showError("您的手机目前未开启定位服务，如欲开启定位服务，请至设定开启定位服务功能")
        }else{
            m_pLocation?.requestWhenInUseAuthorization()
        }
        self.getData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getData()  {
        m_aryPoints.removeAllObjects()
        ZwqHttp.get(strGetPoint, paras: ["areacode":"110"], success: { (pData:Any) in
            if(pData is NSArray){
                let pAry = pData as! NSArray
                for pAny in pAry {
                    if(pAny is NSDictionary){
                        let pDic = pAny as! NSDictionary
                        let pPoint =  MapPoint()
                        pPoint.setData(pDic )
                        self.m_aryPoints.add(pPoint)
                    }
                }
                self.m_pMap?.addAnnotations(self.m_aryPoints as! [MKAnnotation])
            }
        }) { (pData:Any) in
            
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        let pinID="MapPinID"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier:pinID)
        if pinView == nil {
            pinView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: pinID)
            pinView?.canShowCallout = false
        }else{
            pinView?.annotation = annotation;
        }
        if annotation is MapPoint {
            pinView?.image = #imageLiteral(resourceName: "logo_map")
            let pTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(HomeVC.pinClicked(_:)))
            pinView?.addGestureRecognizer(pTapGesture)
        }
        return pinView
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var theSpan = MKCoordinateSpan.init()
        theSpan.latitudeDelta = 0.2;
        theSpan.longitudeDelta = 0.2;
        var theRegion = MKCoordinateRegion.init()
        theRegion.center = (manager.location?.coordinate)!
        theRegion.span=theSpan;
        m_pMap?.setRegion(theRegion, animated: false)
    }
    @objc func pinClicked(_ pTap:UITapGestureRecognizer){
        let pView = pTap.view as? MKAnnotationView
        let pAnnotation = pView?.annotation as? MapPoint
        let pStationId = pAnnotation?.dicData!["stationId"] as? String ?? ""
        m_pPopView?.isHidden = false
        self.tabBarController?.tabBar.isHidden=true
        m_pPopView?.setData(["":""])
        let pPopView = self.m_pPopView
        pPopView?.location = pAnnotation?.coordinate
        pPopView?.BDlocation = pAnnotation?.BdLocation
        ZwqHttp.get(strGetPointDetail, paras: ["stationId":pStationId], success: { (pData:Any) in
            self.m_pPopView?.setData(pData)
        }) { (pData:Any) in
        
        }
    }
    func initPopView()  {
        if m_pPopView == nil {
            let pPopView = Bundle.main.loadNibNamed("PopDetail", owner: nil, options: nil)?.first as? PopDetail
            
            pPopView?.frame = self.view.bounds

            pPopView?.tabBarVC = self.tabBarController
            self.view.addSubview(pPopView!)
            m_pPopView = pPopView
            m_pPopView?.isHidden = true
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
