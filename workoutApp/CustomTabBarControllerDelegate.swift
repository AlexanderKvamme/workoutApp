//
//  CustomTabBarDelegateViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 20/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class CustomTabBarControllerDelegate: NSObject, UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
//        if viewController == tabBarController {
//                return false
//        } else {
//            return true
//        }
        print("test")
        
        print(" returning \(viewController != tabBarController)")
        
        return viewController != tabBarController
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("selected: ", viewController)
    }
}

