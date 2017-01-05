//
//  FormTextField.swift
//  LoginFormAnimation
//
//  Created by Devika on 15/12/16.
//  Copyright © 2016 Devika. All rights reserved.
//

import UIKit

@objc protocol FormTextFieldDelegate {
    @objc optional func completedAnimations()
    @objc optional func drawJumpingAnimationWith(layer : CAShapeLayer, animation : CABasicAnimation, nextField : FormTextField)
    @objc optional func dismissJumpingAnimationPath()
}

class FormTextField: UITextField, CAAnimationDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var nextField: FormTextField!
    
    var border                                                = CALayer()       //  Bottom border
    var circleLayer                                           = CAShapeLayer()  //  Circular loader
    var jumpingAnimationLayer                                 = CAShapeLayer()  //  Jumping animation loader
    
    let borderFillColor             : UIColor                 = UIColor(colorLiteralRed: 0.37, green: 0.84, blue: 1.00, alpha: 1.0)
    let borderWidth                 : CGFloat                 = 2.0
    let customFontSize              : CGFloat                 = 12.0
    var formTextFieldDelegate       : FormTextFieldDelegate?
    var shouldAnimateFromLeft       : Bool                    = true
    
    let circleAnimationIdentifier   : NSString                = "Circle"
    let circleAnimationKey          : String                  = "animateCircle"
    let tickAnimationKey            : String                  = "strokeEnd"
    let jumpingAnimationKey         : String                  = "jumping"
    let tickAnimationIdentifier     : NSString                = "Tick"
    let nextFieldForAnimationKey    : NSString                = "nextFieldForAnimation"
    let notificationName            : String                  = "CompletedJumpingNotification"
    let customFontName              : String                  = "Kailasa"
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.customiseTextFieldWithFont(fontName: customFontName, fontSize: customFontSize)
        self.customiseBottomBorder()
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(methodOfReceivedNotification(notification:)), name: Notification.Name(notificationName as String), object: nil)
    }
    
    
    func methodOfReceivedNotification(notification: Notification) {
        
        if nextField != nil {
            
            let dict = notification.object as? NSDictionary
            let receivedNextField = dict?[nextFieldForAnimationKey] as? FormTextField
            if receivedNextField == self.nextField {
                
                nextField.addBottomBorder()
                self.nextField.becomeFirstResponder()
                if let _ = self.formTextFieldDelegate {
                    self.formTextFieldDelegate?.dismissJumpingAnimationPath!()
                }
            }
        }
    }
    
    
    
    //MARK:
    
    /*
     Customise text field
     */
    func customiseTextFieldWithFont(fontName : String, fontSize: CGFloat) {
        
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
        self.font = UIFont(name: fontName as String, size: fontSize)
        self.textColor = UIColor.blue
    }
    
    /*
     Get the bottom border
     */
    func customiseBottomBorder() {
        
        border.borderColor = borderFillColor.cgColor
        border.borderWidth = borderWidth
        border.position = CGPoint(x:  border.frame.origin.x, y: border.frame.origin.y)
        border.anchorPoint = CGPoint(x: 0, y: 0)
    }
    
    /*
     Get the bottom border
     */
    func customiseCircularLoader() {
        
        if(self.rightView != nil) {
            
            let midX = (self.rightView?.bounds)!.midX+2
            let midY = (self.rightView?.bounds)!.midY+2
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: midX, y: midY), radius: (self.rightView?.frame.height)!/3, startAngle: CGFloat(M_PI/2), endAngle: CGFloat(M_PI), clockwise: false)
            
            // Setup the CAShapeLayer with the path, colors, and line width
            self.initialiseCircleLayer()
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = borderFillColor.cgColor
            circleLayer.backgroundColor = UIColor.clear.cgColor
            circleLayer.lineWidth = borderWidth;
            circleLayer.strokeEnd = 0.0
        }
    }
    
    
    /*
     Add the jumping animation
     */
    func addJumpingAnimation() {
        
        self.customiseJumpingAnimation()
        let animation = CABasicAnimation(keyPath: jumpingAnimationKey as String)
        animation.duration = 0.09
        animation.setValue(jumpingAnimationKey, forKey: jumpingAnimationKey as String)
        jumpingAnimationLayer.strokeEnd = 1.0

        if let _ = self.formTextFieldDelegate {
            self.formTextFieldDelegate?.drawJumpingAnimationWith!(layer: jumpingAnimationLayer, animation: animation,nextField: self.nextField)
        }
    }
    
    
    /*
     Customise the jumping animation
     */
    func customiseJumpingAnimation() {
        
        if self.nextField != nil {
            
            let circleRadius : CGFloat = (self.nextField.frame.maxY - self.frame.maxY)/2
            var circlePath : UIBezierPath
            var midX    : CGFloat
            var midY    : CGFloat
            
            if shouldAnimateFromLeft {
                
                midX = self.frame.maxX - 15
                midY = self.frame.maxY + circleRadius
                circlePath = UIBezierPath(arcCenter: CGPoint(x: midX, y: midY), radius: circleRadius, startAngle: CGFloat(3.1*M_PI_2), endAngle: CGFloat(M_PI_2), clockwise: true)
                
            } else {
                
                midX = self.frame.minX
                midY = self.frame.maxY + circleRadius
                circlePath = UIBezierPath(arcCenter: CGPoint(x: midX, y: midY), radius: circleRadius, startAngle: CGFloat(3*M_PI_2), endAngle: CGFloat(M_PI_2), clockwise: false)
            }
            
            // Setup the CAShapeLayer with the path, colors, and line width
            
            jumpingAnimationLayer = CAShapeLayer()
            jumpingAnimationLayer.backgroundColor = UIColor.red.cgColor
            jumpingAnimationLayer.frame = CGRect(x: 0, y: 0, width: circleRadius+10, height: circleRadius*2)
            jumpingAnimationLayer.path = circlePath.cgPath
            jumpingAnimationLayer.fillColor = UIColor.clear.cgColor
            jumpingAnimationLayer.strokeColor = borderFillColor.cgColor
            jumpingAnimationLayer.backgroundColor = UIColor.clear.cgColor
            jumpingAnimationLayer.lineWidth = borderWidth;
            jumpingAnimationLayer.strokeEnd = 0.0
        }
    }
    
    /*
     Initialise circleLayer
     */
    func initialiseCircleLayer() {
        
        circleLayer = CAShapeLayer()
        circleLayer.frame = CGRect(x: 0, y: 0, width: 50, height: self.frame.height)
    }
    
    /*
     Add circular loader
     */
    func addCircularLoader() {
        
        self.addRightView()
        self.customiseCircularLoader()
        self.rightView?.layer.addSublayer(circleLayer)
        self.animateCircle(duration: 0.5)
    }
    
    
    /*
     Add right view
     */
    func addRightView() {
        
        self.rightViewMode = UITextFieldViewMode.always
        let rightView = UIView()
        rightView.frame = CGRect(x: 0, y: 0, width: 25, height: self.frame.height)
        rightView.backgroundColor = UIColor.clear
        self.rightView = rightView
    }
    
    /*
     Animate circle
     */
    func animateCircle(duration: TimeInterval) {
        
        let animation = CABasicAnimation(keyPath: tickAnimationKey as String)
        animation.duration = duration
        animation.setValue(circleAnimationIdentifier, forKey: circleAnimationKey as String)
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        
        circleLayer.strokeEnd = 1.0
        circleLayer.add(animation, forKey: circleAnimationKey as String)
    }
    
    
    /*
     Customise tick
     */
    func customiseTick() {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: circleLayer.frame.size.height * 2 / 5))
        path.addLine(to: CGPoint(x: 2, y: circleLayer.frame.size.height/1.8))
        path.addLine(to: CGPoint(x: circleLayer.frame.size.height/1.8, y: 0))
        
        circleLayer.path = path.cgPath
        circleLayer.strokeColor = borderFillColor.cgColor
        circleLayer.fillColor = nil
        circleLayer.lineWidth = borderWidth
        circleLayer.lineJoin = kCALineJoinBevel
        self.rightView?.layer.addSublayer(circleLayer)
    }
    
    /*
     Add tick
     */
    func addTick() {
        
        self.customiseTick()
        let pathAnimation = CABasicAnimation(keyPath:tickAnimationKey as String)
        pathAnimation.duration = 0.5
        pathAnimation.fromValue = NSNumber(floatLiteral: 0.8)
        pathAnimation.toValue = NSNumber(floatLiteral: 1)
        pathAnimation.setValue(tickAnimationIdentifier, forKey: tickAnimationKey as String)
        pathAnimation.delegate = self
        circleLayer.add(pathAnimation, forKey: tickAnimationKey as String)
    }
    
    /*
     Add the bottom border
     */
    func addBottomBorder() {
        
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width:  self.frame.size.width-10, height: self.frame.size.height)
        let transition: CATransition = self.getTheTransitionForBotomBorder()
        if(self.border.superlayer == nil) {
            
            self.layer.addSublayer(border)
            self.border.add(transition, forKey: "slideInBorderTransition");
        }
    }
    
    /*
     Returns the CATransition object for bottom border animation
     */
    func getTheTransitionForBotomBorder() -> CATransition {
        
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.duration = 0.5
        transition.timingFunction = timeFunc
        transition.fillMode = kCAFillModeRemoved
        self.customiseAnimationDirection()
        transition.delegate = self
        transition.subtype =  shouldAnimateFromLeft ?  kCATransitionFromLeft : kCATransitionFromRight
        return transition
    }
    
    /*
     Customise the animation direction, by default it if from left to right
     */
    func customiseAnimationDirection() {
        
        if self.tag % 2 != 0 {
            shouldAnimateFromLeft = true
        }else {
            shouldAnimateFromLeft = false
        }
    }
    
    /*
     Remove the bottom border and add circular loader
     */
    func giveLoaderAndTickEffect() {
        
        self.addCircularLoader()
    }
    
    /*
     Remove the bottom border
     */
    func removeBottomBorder() {
        
        let subLayers = self.layer.sublayers
        if subLayers != nil && (subLayers?.count)! > 1 {
            
            for subLayer in subLayers!{
                
                if subLayer == self.border {
                    subLayer.removeFromSuperlayer()
                }
            }
        }
    }
    
    /*
     To check if the bottom border is already added
     */
    func doesBottomBorderAvailable() -> Bool {
        
        let subLayers = self.layer.sublayers
        var hasBottomBorder : Bool = false
        if subLayers != nil && (subLayers?.count)! > 1 {
            
            for subLayer in subLayers!{
                if subLayer == self.border {
                    hasBottomBorder = true
                }
            }
        }
        return hasBottomBorder
    }
    
    /*
     Remove the right view
     */
    func removeRightView() {
        
        self.rightView = nil
        self.layoutIfNeeded()
    }
    
    //MARK: CAAnimationDelegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            
            if let animationID: AnyObject = anim.value(forKey: circleAnimationKey as String) as AnyObject? {
                
                if animationID as? NSString != nil {
                    
                    if animationID as? NSString == circleAnimationIdentifier {
                        self.addTick()
                    }
                }
            }else {
                
                if let animationID: AnyObject = anim.value(forKey: tickAnimationKey as String) as AnyObject? {
                    if animationID as? NSString != nil {
                        
                        if animationID as? NSString == tickAnimationIdentifier {
                            
                            //   Uncomment if the tick is to be removed after animation
                            //   self.removeRightView()
                            self.removeBottomBorder()
                            if(self.nextField != nil) {
                                self.addJumpingAnimation()
                            }else {
                                
                                if let _ = self.formTextFieldDelegate {
                                    self.formTextFieldDelegate?.completedAnimations!()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: UITextFieldDelegate methods
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let hasAnyBottomBorder : Bool = self.doesBottomBorderAvailable()
        if !hasAnyBottomBorder {
            self.addBottomBorder()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.giveLoaderAndTickEffect()
        return false
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let hasAnyBottomBorder : Bool = self.doesBottomBorderAvailable()
        if hasAnyBottomBorder {
            self.removeBottomBorder()
        }
    }
    
}

