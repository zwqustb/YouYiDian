//
//  CarInfoVC.swift
//  YouYiDian
//
//  Created by xhgc01 on 2018/1/31.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

class CarInfoVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var m_aryData:NSArray?
    //车型
    //添加车型 carType =//车型添加
    //carType;          //品牌
    //version;    //型号
    // idNumber;  //车辆识别码
    var strAddCarType = "/memb/addCarType.json"
    //查询车型
    var strQueryCarType = "/memb/queryCarType.json"
    
    @IBOutlet weak var tableview: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        self.tableview.delegate = self
        self.tableview.dataSource = self
//        self.tableview.register(CarCell.self, forCellReuseIdentifier: "reuseIdentifier")

        self.tableview.register(UINib.init(nibName: "CarCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewDidAppear(_ animated: Bool) {
        ZwqHttp.get(strQueryCarType, success: { (pData) in
            if pData is NSArray{
                let pAry = pData as! NSArray
                self.m_aryData = pAry
                self.tableview.reloadData()
            }else if pData is NSDictionary{
                let pDic = pData as! NSDictionary
                print(pDic)
            }
        }) { (pData) in
            print("查询汽车信息失败")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let nRow = m_aryData?.count ?? 0
        return nRow
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! CarCell
        let pDic = m_aryData![indexPath.row] as! NSDictionary
        cell.txtTop?.text = pDic["carType"] as? String ?? ""
        cell.txtLeft.text =  pDic["version"] as? String ?? ""
        cell.txtRight.text = pDic["idNumber"] as? String ?? ""
        
        // Configure the cell...
        return cell
    }
 
    @IBAction func clickAdd(_ sender: UIButton) {
        let pAddInfoVC = CarAddInfoVC()
        pushView(pAddInfoVC)
    }
    //mark: func diy

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


