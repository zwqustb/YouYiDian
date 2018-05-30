//
//  CarAddInfoVC.swift
//  YouYiDian
//
//  Created by xhgc01 on 2018/1/31.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

class CarAddInfoVC: UIViewController {
    //车型
    //添加车型 carType =//车型添加
    //carType;          //品牌
    //version;    //型号
    // idNumber;  //车辆识别码
    var strAddCarType = "/memb/addCarType.json"
    
    @IBOutlet weak var txtCarName: UITextField!
    
    @IBOutlet weak var txtCarType: UITextField!
    
    @IBOutlet weak var txtCarCode: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func clickCommit(_ sender: UIButton) {
        let pDic = ["carType":txtCarName.text ?? ""
            ,"version":txtCarType.text ?? ""
            ,"idNumber":txtCarCode.text ?? ""]
        ZwqHttp.get(strAddCarType, paras: pDic, success: { (pData) in
            if pData is NSArray{
                let pAry = pData as! NSArray
                print(pAry)
            }else if pData is NSDictionary{
                let pDic = pData as! NSDictionary
                print(pData)
                let pDicMsg = pDic["retMsg"] as? NSDictionary
                let strMsg = pDicMsg?["msg"] as? String ?? "添加失败"
                MBProgressHUD.showSuccess(strMsg)
            }
        }) { (pData) in
            print("提交车型信息失败")
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
