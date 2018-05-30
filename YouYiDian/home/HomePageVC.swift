//
//  HomePageVC.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/18.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit

class HomePageVC: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc1 = HomeVC()
        let nInsert:CGFloat = 5
        self.navigationController?.isNavigationBarHidden=true
        vc1.tabBarItem.image=#imageLiteral(resourceName: "footer0")
        vc1.tabBarItem.selectedImage=#imageLiteral(resourceName: "footer0_active")
        vc1.tabBarItem.imageInsets = UIEdgeInsetsMake(nInsert, 0, -nInsert, 0)
        let vc2 = chargeVC.init(nibName: "chargeVC", bundle: nil)
        vc2.tabBarItem.image=#imageLiteral(resourceName: "footer1")
        vc2.tabBarItem.selectedImage=#imageLiteral(resourceName: "footer1_active")
        vc2.tabBarItem.imageInsets = UIEdgeInsetsMake(nInsert, 0, -nInsert, 0)
        // 2.包装导航控制器
        let vc3 = ExploreVC.init(nibName: "ExploreVC", bundle: nil)
        vc3.tabBarItem.image=#imageLiteral(resourceName: "footer2")
        vc3.tabBarItem.selectedImage=#imageLiteral(resourceName: "footer2_active")
        vc3.tabBarItem.imageInsets = UIEdgeInsetsMake(nInsert, 0, -nInsert, 0)
        let vc4 = storyboard?.instantiateViewController(withIdentifier: "mineVC") as! MineVC
        vc4.tabBarItem.image=#imageLiteral(resourceName: "footer3")
        vc4.tabBarItem.selectedImage=#imageLiteral(resourceName: "footer3_active")
        vc4.tabBarItem.imageInsets = UIEdgeInsetsMake(nInsert, 0, -nInsert, 0)
        self.setViewControllers([vc1,vc2,vc3,vc4], animated: true);
        self.delegate = self
        // Do any additional setup after loading the view.
        //导航条返回按钮
        let backItem = UIBarButtonItem.init(title: "返回", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:tabbar delegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //       getNavVC().navigationBar.isHidden=false
        let nCount = tabBarController.viewControllers?.index(of: viewController)
        if  nCount == self.selectedIndex{
           return false
        }
        return true
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = tabBarController.selectedIndex
        if index == 1 || index == 3 {
            UITools.checkIsLogin(self)
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
