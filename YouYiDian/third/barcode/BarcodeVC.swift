//
//  BarcodeVC.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2018/1/24.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

class BarcodeVC: ScanningViewController {

    @IBOutlet weak var m_pBgView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickClose(_ sender: UIButton) {
        self.closeself(false)
    }
    
    @IBAction func clickWriteCode(_ sender: UIButton) {
        self.closeself(true)
    }
    @IBAction func clickLight(_ sender: UIButton) {
        self.clickLight()
    }
    override func addMaskView(_ pView: UIView!) {
        self.m_pBgView.addSubview(pView)
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
