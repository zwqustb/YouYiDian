//
//  chargeVC.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/19.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit
enum chargeState:String{
    case notBegin = "扫码充电"
    case start = "开始充电"
    case start_info = "查询充电桩启动状态,若电桩无反应,请拔枪重插,重启应用"
    case status = "正在充电"
    case end = "结束充电"
}
class chargeVC: UIViewController,ScanDelegate {
    var m_eChargeStat:chargeState = .notBegin
    //开始充电
    var strQueryStartCharge = "/charge/query_start_charge.json"//connectorId
    //未支付订单
    var strUnpayOrderInfo = "/charge/checkUnPayedCharge.json"
    //正在充电的订单
    var strChargingOrder = "/charge/checkChargingOrder.json"
    //开始充电状态
    var strQueryStartChargeInfo = "/charge/query_start_charge_info.json"//connectorId
    //结束充电
    var strQueryStopCharge = "/charge/query_stop_charge.json"//?startChargeSeq=
    //正在充电
    var strQueryChargeStatus = "/charge/query_equip_charge_status.json"//?startChargeSeq="
    //充电订单
    var strGetPayOrder = "/charge/query_charge_order_info.json"
    var strQueryChargeRecords = "/charge/queryChargeRecords.json"//查询总数据,cookie中取参数
    //是否交了押金
    //如果返回数组长度为1的时候就说明已经支付押金了

   // var cmdQueryDeposit="/charge/queryDeposits.json"//返回数组
    var cmdCheckDeposit="/charge/checkDeposits.json"//返回对象
    var m_bShouldRefreshData = true
    var connectID:String? //充电枪ID
    var chargeID:String? //充电订单号
    var m_bCharging = false
//    var m_pChargingView:chargingView?
    var m_bChargeEnd = false
    
    var m_pBarcodeVC:BarcodeVC?
    var m_bOpenPayVC = false
     var m_pPayVC:PayVC? //支付界面
    var m_pChargeOverView:chargeOver?
    //MARK: 状态文字和控件
    @IBOutlet weak var labelTop: UILabel!
    @IBOutlet weak var labelFirst: UILabel!
    @IBOutlet weak var labelSecond: UILabel!
    @IBOutlet weak var labelThird: UILabel!
    @IBOutlet weak var m_btnCharge: UIButton!
    
    @IBOutlet weak var panel2: UIView!
    @IBOutlet weak var labelElecCurrent: UILabel!//电流
    @IBOutlet weak var labelVoltage: UILabel!//电压
    @IBOutlet weak var labelPower: UILabel!//功率
    
    
    @IBOutlet weak var lNote: UILabel!
    //充电前要填充的控件
    @IBOutlet weak var labelMoney: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    //电量
    @IBOutlet weak var labelElectricity: UILabel!
    //充电次数||当前充电订单号
    @IBOutlet weak var labelCount: UILabel!
    //扫描充电按钮
    //mark:生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
//           m_pChargingView = Bundle.main.loadNibNamed("chargingView", owner: nil, options: nil)?.first as? chargingView
//        m_pChargingView?.frame = self.view.bounds
//        self.view.addSubview(m_pChargingView!)
//        m_pChargingView?.m_pChargeVC = self
//        m_pChargingView?.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.hiddenChargeEndView()
        if m_bShouldRefreshData {
            UITools.relogin(success: { (pData:Any) in
                self.getData()
            }) { (pData:Any) in
                
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = true
        UITools.relogin(success: { (pData:Any) in
            self.getDepositsInfo()
        }) { (pData:Any) in
            
        }
    }
    //MARK: 扫码二维码相关
    @IBAction func clickBarcode(_ sender: UIButton) {
        let pImg = m_btnCharge.image(for: .normal)
        if pImg == #imageLiteral(resourceName: "iconStopCharge"){
            self.endCharge()
        }else{
//测试开始
//            self.showCharingView("123", ["qe":21])
//            return
//测试结束
            m_bShouldRefreshData = false
            if m_pBarcodeVC == nil {
                m_pBarcodeVC = BarcodeVC()
                m_pBarcodeVC?.delegate = self
            }
            self.setChargeStatus(.notBegin)
            self.present(m_pBarcodeVC!, animated: true) {
            }
        }
       
    }
    //二维码回调
    func getScanResult(_ strRet: String!) {
        print(strRet)
        connectID = strRet
        self.queryBgnCharge()
    }
    func barcodeViewDidClosed(_ bWrite:Bool) {
        m_bShouldRefreshData = true
        if bWrite {
            UITools.alertInfo(["title":"请输入电桩编号","textNum":"1"], on: self, callback: { (index, strText) in
                if(index==0){
                    self.getScanResult(strText as String!)
                }
            })
        }
        m_pBarcodeVC = nil
    }
    //获取押金状态信息
    func getDepositsInfo(){
        //检查是否交押金
        m_btnCharge.isEnabled = false
        ZwqHttp.get(cmdCheckDeposit, success: { (pData) in
            if pData is NSDictionary{
                let pDic = pData as! NSDictionary
                let strMsg = pDic["msg"] as? String ?? "0"
                if strMsg == "2"{
                    //未缴纳
                    if(self.m_bOpenPayVC){
                        self.tabBarController?.selectedIndex=0
                        self.m_bOpenPayVC = false
                    }else{
                        self.m_bOpenPayVC = true
                        let pPayDepositVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PayVC") as! PayVC
                        pPayDepositVC.m_numMoney = 0
                        pPayDepositVC.m_bDeposit = true
                        pushView(pPayDepositVC)
                    }
                }else if strMsg == "0"{
                    //已缴纳
                    self.m_btnCharge.isEnabled = true
                }else if strMsg == "1"{
                    //正在申请退款
                    if(self.m_bOpenPayVC){
                        self.tabBarController?.selectedIndex=0
                        self.m_bOpenPayVC = false
                    }else{
                        self.m_bOpenPayVC = true
                        let pDepositVC = DepositVC()
                        pDepositVC.m_bRefund = true
                        pushView(pDepositVC)
                    }
                }else{
                    MBProgressHUD.showError("未知的押金状态码:\(strMsg)")
                }
            }
        }, failure: { (pData) in
            MBProgressHUD.showError("押金状态获取失败")
        })
    }
    //MARK:获取总的充电记录
    func getData(){
        ZwqHttp.get(strQueryChargeRecords, success: { (pData:Any) in
            print(pData)
            if pData is NSDictionary{
                let pDic = pData as! NSDictionary
                self.labelMoney.text = self.getDataNum("totalElecMoney", pDic)
                self.labelTime.text = self.getDataNum("totalTime", pDic)
                self.labelElectricity.text = self.getDataNum("totalPower", pDic)
                self.labelCount.text = self.getDataNum("chargeTime", pDic)
                ZwqHttp.get(self.strUnpayOrderInfo, success: { (ret) in
                    print(ret)
                    if ret is NSArray{
                        let pAry = ret as! NSArray
                        if pAry.count > 0{
                            let pDic = pAry.firstObject as! NSDictionary
                            self.showCharingView("您有订单未支付", pDic)
                        }else{
                            print("没有未支付订单")
                            ZwqHttp.get(self.strChargingOrder,  success: { (ret) in
                                if ret is NSArray{
                                    let pAry = ret as! NSArray
                                    if pAry.count > 0{
                                        let pDic = pAry.firstObject as! NSDictionary
                                        self.showCharingView("您的订单正在充电中", pDic)
                                        self.setChargeStatus(.status)
                                        self.queryChargeState()
                                        return
                                    }
                                }
//                                self.m_pChargingView?.isHidden = true
                            }, failure: { (ret) in
                            })
                        }
                    }
                }, failure: { (ret) in
                })
            }
        }) { (pData:Any) in
        }
    }
    func getDataNum(_ key:String,_ pDic:NSDictionary)->String{
        let pNum = pDic[key] as? NSNumber
        if pNum != nil {
            var nNum = pNum!.doubleValue
            if key == "totalTime"{//时间返回的是毫秒数
                nNum = nNum/1000*60
            }
            return "\(nNum)"
        }
        return "0"
    }
    //MARK:充电流程
    func queryBgnCharge() {
        
        if connectID == nil {
            return
        }
//        MBProgressHUD.showWaiting("正在启动充电装置", to: nil)
        UITools.relogin(success: { (ret) in
            self.setChargeStatus (.start)
            ZwqHttp.get(self.strQueryStartCharge, paras: ["connectorId":self.connectID!], success: { (pData:Any) in
                let pDic = pData as? NSDictionary
                let bRet = pDic?["success"] as? Bool
                if bRet == true {
                    self.setChargeStatus ( .start_info)
                    self.lNote.text = chargeState.start_info.rawValue
                    self.chargeID = pDic?["msg"] as? String
                    self.queryBgnChargeState()
                }else{
                    self.setChargeStatus(.notBegin)
                    MBProgressHUD.showError("电桩启动失败")
                }
                
            }) { (pData:Any) in
                
            }
        }) { (ret) in
        }
    }
    @objc func queryBgnChargeState(){
        if chargeID == nil || self.m_eChargeStat != .start_info{
            return
        }
        ZwqHttp.get(strQueryStartChargeInfo, paras: ["startChargeSeq":chargeID!], success: { (pData:Any) in
            let pDic = pData as? NSDictionary
            let nRet = pDic?["succStat"] as? NSNumber
            if nRet == nil{
                 MBProgressHUD.showError("\(self.strQueryStartChargeInfo)的succStat为空")
            } else if nRet!.intValue == 0{//成功,开始充电
                DateTools.saveNow(self.chargeID!)
                self.setChargeStatus(.status)
//                self.m_pChargingView?.isHidden = false
                MBProgressHUD.closeWaiting()
                self.queryChargeState()
            }else if nRet!.intValue == 2{//未知状态,继续查
                self.perform(#selector(chargeVC.queryBgnChargeState) , with: nil, afterDelay: 1)
            }else{
                 MBProgressHUD.showError("启动失败,\(self.strQueryStartChargeInfo)的succStat为\(nRet!)")
            }
        }) { (pData:Any) in
        }
    }
    @objc func queryChargeState(){
        if chargeID == nil || m_eChargeStat != .status {
            return
        }
        ZwqHttp.get(strQueryChargeStatus, paras: ["startChargeSeq":chargeID!], success: { (pData:Any) in
            let pDic = pData as? NSDictionary
            ZwqHttp.get(self.strGetPayOrder, paras: ["startChargeSeq":self.chargeID! ], success: { (ret) in
                if ret is NSDictionary{
                    let pDicOrder = ret as! NSDictionary
                    if pDicOrder["totalMoney"] != nil{
                        //充电状态自动结束了
                        print("充电状态自动结束了")
                        self.showChargeEndView(pDicOrder)
                        return
                    }
                }
                //正在充电,继续查
                self.perform(#selector(chargeVC.queryChargeState) , with: nil, afterDelay: 10)
                self.setChargingData(pDic!)
            }) { (pData:Any) in
            }
        }) { (pData:Any) in
        }
    }
    @objc func endCharge() {
        //测试开始
//        self.setChargeStatus( .notBegin )
//        self.showChargeEndView(["totalPower":"123","totalMoney":"3","stopReason":(1),"totalPower":"123"]);
        //测试结束
        if chargeID == nil || connectID == nil {
            return
        }
        MBProgressHUD.showSuccess("正在查询未支付订单")
        ZwqHttp.get(strQueryStopCharge, paras: ["startChargeSeq":chargeID!,"connectorId":connectID!], success: { (pData:Any) in
            MBProgressHUD.showSuccess("正在查询本次充电金额,请稍等")
            let pDicChargeEnd = pData as? NSDictionary//看充电结束返回结果
            let nSuccStat = pDicChargeEnd?["succStat"] ?? 0
            print("QueryStopCharge-SuccStat:\(nSuccStat)")
            //充电结束获取订单状态
            self.perform(#selector(chargeVC.getEndChargeOrder) , with: nil, afterDelay: 2)
        }) { (pData:Any) in
            MBProgressHUD.showError("结束充电请求失败,请再试一次")
        }
    }
    @objc func getEndChargeOrder(){
        
        ZwqHttp.get(self.strGetPayOrder, paras: ["startChargeSeq":self.chargeID! ], success: { (ret) in
            if ret is NSDictionary{
                let pDicOrder = ret as! NSDictionary
                if pDicOrder["totalMoney"] != nil{
                    self.showChargeEndView(pDicOrder)
                    self.setChargeStatus( .notBegin )
                    return
                }
            }
            //没有获取到订单金额
            MBProgressHUD.showSuccess("正在查询本次充电金额,请稍等")
            self.perform(#selector(chargeVC.getEndChargeOrder) , with: nil, afterDelay: 2)
            //没有取到结束信息,继续查
            // self.perform(#selector(chargeVC.endCharge) , with: nil, afterDelay: 10)
        }) { (pData:Any) in
            MBProgressHUD.showError("订单信息请求失败,请再试一次")
        }
    }
    //MARK: 工具方法
    
    func setChargeStatus(_ pState:chargeState) {
        self.m_eChargeStat = pState
        lNote.text = pState.rawValue
        let bCharging = pState == .status
     //   self.m_pChargingView?.isHidden = !bCharging
        self.setTimerStart(bCharging)
        self.setViewMode(bCharging:bCharging)
    }
    //有未支付订单,需要显示结束充电状态
    func showCharingView(_ strReason:String,_ pDic:NSDictionary){
        self.chargeID = pDic["startChargeSeq"] as? String
        self.connectID = pDic["connectorId"] as? String
        MBProgressHUD.showError(strReason)
//        self.m_pChargingView?.isHidden = false
//        print(strReason)
        self.setViewMode(bCharging:true)
        ZwqHttp.get(self.strGetPayOrder, paras: ["startChargeSeq":self.chargeID! ], success: { (ret) in
            if ret is NSDictionary{
                let pDicOrder = ret as! NSDictionary
                if pDicOrder["totalMoney"] != nil{
                    //查到未支付订单了
                    self.setUnpayChargingData(pDicOrder)
                    self.showChargeEndView(pDicOrder)
                    return
                }
            }
        }) { (pData:Any) in
        }
    }
    func setViewMode(bCharging:Bool){
        labelTop.text = bCharging ?"充电金额":"总充电金额"
        labelFirst.text = bCharging ?"时长(分)":"总时长(分)"
        labelSecond.text = bCharging ?"充电量(度)":"总充电量(度)"
        labelThird.text = bCharging ?"充电订单号":"充电次数(次)"
        panel2.isHidden = !bCharging
        let pBtnImg = bCharging ?#imageLiteral(resourceName: "iconStopCharge"):#imageLiteral(resourceName: "chargeBtn")
        m_btnCharge.setImage(pBtnImg, for: .normal)
    }
    //显示结束充电弹框
    func showChargeEndView(_ pDic:NSDictionary){
        self.tabBarController?.tabBar.isHidden = true
        if m_pChargeOverView == nil {
            m_pChargeOverView = Bundle.main.loadNibNamed("chargeOver", owner: nil, options: nil)?.first as? chargeOver
            m_pChargeOverView?.frame = self.view.bounds
            m_pChargeOverView?.m_pChargeVC = self
            self.view.addSubview(m_pChargeOverView!)
        }
        m_pChargeOverView?.setData(pDic)
        m_pChargeOverView?.isHidden = false
       // let pRootView = UIApplication.shared.keyWindow
    }
    func hiddenChargeEndView(){
        m_pChargeOverView?.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    func showPayVC(){
        m_pPayVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PayVC") as? PayVC
        m_pPayVC?.strChargeId = self.chargeID ?? "未知充电订单号"
        m_pPayVC?.m_numMoney = NSNumber(value:Float(self.labelMoney.text ?? "0.0")!)
        self.getOrderStatus()
    }
    func getOrderStatus(){
        //测试开始
//        self.m_pPayVC?.m_numMoney = (100)
//        pushView(self.m_pPayVC!)
//        return
        //测试结束
        let pChargeID = self.chargeID ?? ""
        ZwqHttp.get(strGetPayOrder, paras: ["startChargeSeq":pChargeID ], success: { (pData:Any) in
            if pData is NSDictionary{
                let pDic = pData as? NSDictionary
                self.m_pPayVC?.m_numMoney = pDic!["totalMoney"] as? NSNumber
                pushView(self.m_pPayVC!)
            }
        }) { (pData:Any) in
            MBProgressHUD.showError("获取订单信息失败,订单号:\(pChargeID)")
        }
    }
    
    // MARK: - 计时器
     var timerCharging:Timer?
     var startTime:Date?
    var endTime:Date?//充电结束时间
    @objc func tickDown(){
        
        if startTime != nil {
            let curDate = Date()
            let time = curDate.timeIntervalSince(startTime!)
            let hours = Int(time)/3600
            let minutes = ( Int(time) % 3600)/60
            let seconds = Int(time) % 60
            
            labelTime.text = "\(hours)时\(minutes)分\(seconds)秒"
            //根据开始和结束时间计算时长
            
        }
    }
    func initChargeStartTime(){
        if startTime == nil{
            let strFormat = "yyyy-MM-dd HH:mm:ss"
            let strStartTime = UserDefaults.standard.string(forKey: self.chargeID!)
            startTime = DateTools.string2Date(strStartTime!, strFormat)
        }
    }
    func setTimerStart(_ bStart:Bool) {
        timerCharging?.invalidate()
        startTime = nil
        if bStart {
            timerCharging = Timer.scheduledTimer(timeInterval: 1,
                                                 target:self,selector:#selector(chargeVC.tickDown),
                                                 userInfo:nil,repeats:true)
           // startTime = Date()
           self.initChargeStartTime()
        }
    }
    //设置充电中的状态显示
    func setChargingData(_ pDic:NSDictionary){
        print(pDic)
        let dMoney = pDic["totalMoney"] as? NSNumber
        let dPower = pDic["totalPower"] as? NSNumber
        
        let fCurrent = pDic["currentA"] as? NSNumber
        let fVoltage = pDic["voltageA"] as? NSNumber
        let fPower = (fCurrent?.floatValue ?? 0)*(fVoltage?.floatValue ?? 0)
        labelMoney.text = "\(dMoney?.floatValue ?? 0)"
        labelElectricity.text =  "\(dPower?.floatValue ?? 0)"
        //        let sTime = pDic["startTime"] as? NSNumber
        //        let eTime = pDic["endTime"] as? NSNumber
        //        let nTime = (pDic["totalTime"] as? NSNumber)?.floatValue ?? 0
        let strID = self.chargeID as NSString? ?? ""
        let nStrIDLength = strID.length
        if nStrIDLength>5{
            let strIDSmall = strID.substring(from: nStrIDLength-5)
            labelCount.text = strIDSmall
        }else{
            labelCount.text = self.chargeID
        }
        
        
        labelElecCurrent.text = String(format: "%.1f", fCurrent?.floatValue ?? 0.0)
        labelVoltage.text = String(format: "%.1f", fVoltage?.floatValue ?? 0.0)
        labelPower.text = String(format: "%.1f", fPower )
        //     lTime.text = "\(nTime/60000)分钟"
    }
    func setUnpayChargingData(_ pDic:NSDictionary){
        let dMoney = pDic["totalElecMoney"] as? NSNumber
        let dPower = pDic["totalPower"] as? NSNumber
        
        labelMoney.text = "\(dMoney?.floatValue ?? 0)"
        labelElectricity.text =  "\(dPower?.floatValue ?? 0)"

        let strBgnTime = pDic["startTime"] as? String
        let strEndTime = pDic["endTime"] as? String
        if (strBgnTime != nil)&&(strEndTime != nil){
            let strDiff = DateTools.getDiffer(strBgnTime!, strEndTime!)
            labelTime.text = strDiff
        }
        //        let nTime = (pDic["totalTime"] as? NSNumber)?.floatValue ?? 0
        let strID = self.chargeID as NSString? ?? ""
        let nStrIDLength = strID.length
        if nStrIDLength>5{
            let strIDSmall = strID.substring(from: nStrIDLength-5)
            labelCount.text = strIDSmall
        }else{
            labelCount.text = self.chargeID
        }

    }
}
