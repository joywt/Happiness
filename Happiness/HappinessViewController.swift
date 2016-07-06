//
//  HappinessViewController.swift
//  Happiness
//
//  Created by wang tie on 16/7/1.
//  Copyright © 2016年 developer. All rights reserved.
//

import UIKit

class HappinessViewController: UIViewController,FaceViewDataSource {
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.dataSource = self
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action:Selector(("scale:"))))
            faceView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action:#selector(HappinessViewController.changeHappiness(_:))))
        }
    }
    
    var happiness: Int = 75 { // 0 = very sad, 100 = ecstatic
        didSet {
            happiness = min(max(happiness, 0), 100)
            updateUI()
        }
    }
    
    private struct Constants {
        static let HappinessGestureScale: CGFloat = 4
    }
    

    func changeHappiness(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended: fallthrough
        case .changed:
            let traslation = gesture.translation(in: faceView)
            let happinessChange = -Int(traslation.y / Constants.HappinessGestureScale)
            if happinessChange  != 0 {
                happiness += happinessChange
                gesture.setTranslation(CGPoint.zero, in: faceView)
            }
        default: break
            
        }
    }
    func updateUI(){
        faceView.setNeedsDisplay()
    }
    
    func smilinessForFaceView(_ sender: FaceView) -> Double? {
        return Double(happiness - 50)/50
    }
    
}
