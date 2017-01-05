//
//  LoginViewController.swift
//  LoginFormAnimation
//
//  Created by Devika Sukumaran on 15/12/16.
//  Copyright © 2016 Devika Sukumaran. All rights reserved.
//

import UIKit


class LoginViewController : UIViewController, UITextFieldDelegate, FormTextFieldDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var email: FormTextField!
    @IBOutlet weak var mobile: FormTextField!
    @IBOutlet weak var name: FormTextField!
    
    var nextFieldForAnimation : FormTextField?
    var jumpingAnimationLayer =  CAShapeLayer()
    
    let jumpingAnimationKey = "jumping"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeTagsAndDelegates()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeTagsAndDelegates() {
        
        email.tag = 10001;
        name.tag = 10002;
        mobile.tag = 10003;
        email.formTextFieldDelegate = self
        name.formTextFieldDelegate = self
        mobile.formTextFieldDelegate = self
    }
    
    /*
     Remove the jumping animation path
    */
    func removeAnimatedPath() {
        
        let subLayers = self.view.layer.sublayers
        if subLayers != nil && (subLayers?.count)! > 1 {
            
            for subLayer in subLayers!{
                
                if subLayer == self.jumpingAnimationLayer {
                    subLayer.removeFromSuperlayer()
                }
            }
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }

    
    //MARK: FormTextFieldDelegate
    
    func completedAnimations() {

        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.endEditing(true)
            self.view.layoutIfNeeded()
        })
    }
    
    func drawJumpingAnimationWith(layer : CAShapeLayer, animation : CABasicAnimation, nextField : FormTextField){
        
        self.jumpingAnimationLayer = layer
        self.nextFieldForAnimation = nextField
        animation.delegate = self
        jumpingAnimationLayer.add(animation, forKey: jumpingAnimationKey as String)
        self.view.layer.addSublayer(jumpingAnimationLayer)
    }
    
    func dismissJumpingAnimationPath() {
    
        self.removeAnimatedPath()
    }
    
    //MARK: CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if flag {
            
            if let animationID: AnyObject = anim.value(forKey: jumpingAnimationKey as String) as AnyObject? {
                
                if animationID as? NSString != nil {
                   
                  
                   let nextField = self.nextFieldForAnimation;
                   let dataDict = [ "nextFieldForAnimation": nextField]
                   NotificationCenter.default.post(name: Notification.Name("CompletedJumpingNotification"), object: dataDict)
                }
            }
        }
    }
}
