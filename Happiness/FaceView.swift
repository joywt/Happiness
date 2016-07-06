//
//  FaceView.swift
//  Happiness
//
//  Created by wang tie on 16/7/1.
//  Copyright © 2016年 developer. All rights reserved.
//

import UIKit

protocol FaceViewDataSource: class {
    func smilinessForFaceView(_ sender: FaceView) -> Double?
}

@IBDesignable
class FaceView: UIView {
    
    var lineWidth: CGFloat = 3 { didSet{ setNeedsDisplay() } }
    var color: UIColor = UIColor.blue() { didSet{ setNeedsDisplay() }}
    var scale: CGFloat = 0.90 { didSet { setNeedsDisplay() }}
    
    var faceCenter : CGPoint {
        return center
    }
    var faceRadius : CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    weak var dataSource: FaceViewDataSource?
    
    func scale(_ gesture: UIPinchGestureRecognizer) {
        if  gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    private struct Scaling{
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
        static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        static let FaceRadiusToMouthWidthRatio: CGFloat = 1
        static let FaceRadiusToMouthHeightRation: CGFloat = 3
        static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
    }
    
    private enum Eye { case left, right}
    
    private func bezierPathForEye(_ whichEye: Eye) -> UIBezierPath
    {
        let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
        let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetRatio
        let eyeHorizontalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeVerticalOffset
        switch whichEye{
        case .left: eyeCenter.x -= eyeHorizontalSeparation / 2
        case .right: eyeCenter.x += eyeHorizontalSeparation / 2
        }
        
        let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat( 2*M_PI), clockwise: true)
        path.lineWidth = lineWidth
        return path
    }
    
    private func bezierPathForSmile(_ fractionOfMaxSmile: Double) -> UIBezierPath
    {
        let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
        let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRation
        let mouthVerticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetRatio
        
        let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight
        
        let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthVerticalOffset)
        let end = CGPoint(x: start.x + mouthWidth, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3 , y: cp1.y)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    override func draw(_ rect: CGRect) {
        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        facePath.lineWidth = lineWidth
        color.set()
        facePath.stroke()
        
        bezierPathForEye(.left).stroke()
        bezierPathForEye(.right).stroke()
        
        let smiliness =  dataSource?.smilinessForFaceView(self) ?? 0.0
        let smilPath = bezierPathForSmile(smiliness)
        smilPath.stroke()
        
    }
    
}
