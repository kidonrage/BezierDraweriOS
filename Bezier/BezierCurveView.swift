//
//  BezierCurveView.swift
//  Bezier
//
//  Created by Vlad Eliseev on 12.12.2019.
//  Copyright © 2019 Vlad Eliseev. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable
class BezierView: UIView {
    
    let pointRadius: CGFloat = 10
    
    var pointDraggingMode = false
    var draggingPointIndex: Int? = nil
    
    var currentPoints: [CGPoint] = [
        CGPoint(x: 50, y: 50),
        CGPoint(x: 300, y: 80),
        CGPoint(x: 350, y: 200),
        CGPoint(x: 30, y: 250),
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.addGestureRecognizer(panRecognizer)
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let recognizerView = recognizer.view else {return}
        
        if recognizer.state == .began {
            pointDraggingMode = false
            
            let firstTouchPos = recognizer.location(in: recognizerView)
            
            setPointOnDrag(firstTouchPos)
        } else {
            guard
                pointDraggingMode,
                let pointIndex = draggingPointIndex
                else { return }
            
            let currentTouchPoint = recognizer.location(in: recognizerView)
            
            currentPoints[pointIndex].x = currentTouchPoint.x
            currentPoints[pointIndex].y = currentTouchPoint.y
            
            setNeedsDisplay()
        }
    }
    
    private func setPointOnDrag(_ pointToDrag: CGPoint) {
        let pointDiameter = pointRadius * 2
        
        for (index, point) in currentPoints.enumerated() {
            if (point.x - pointDiameter...point.x + pointDiameter).contains(pointToDrag.x) && (point.y - pointDiameter...point.y + pointDiameter).contains(pointToDrag.y) {
                pointDraggingMode = true
                draggingPointIndex = index
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }
        
        let color = UIColor.red
        color.setFill()
        context.setLineWidth(2)
        context.addLines(between: currentPoints)
        context.strokePath()
        
        for point in currentPoints {
            let path = UIBezierPath(ovalIn: CGRect(
                x: point.x - pointRadius,
                y: point.y - pointRadius,
                width: pointRadius * 2,
                height: pointRadius * 2))
            path.fill()
        }
        
        drawBezierCurve(points: currentPoints)
    }
    
    private func drawBezierCurve(points: [CGPoint], step: CGFloat = 0.05) {
        // P = (1−t)3P1 + 3(1−t)2tP2 +3(1−t)t2P3 + t3P4 - Для 4 контрольных точек
        guard
            points.count == 4,
            let context = UIGraphicsGetCurrentContext()
            else {return}

        
        var t: CGFloat = 0
        var bezierPoints: [CGPoint] = []
        
        repeat {
            //x = (1−t)2x1 + 2(1−t)tx2 + t2x3
            let x =
                (pow(1 - t, 3) * points[0].x) +
                (3 * pow(1 - t, 2) * t * points[1].x) +
                (3 * (1 - t) * pow(t, 2) * points[2].x) +
                (pow(t, 3) * points[3].x)
              
            //y = (1−t)2y1 + 2(1−t)ty2 + t2y3
            let y =
                (pow(1 - t, 3) * points[0].y) +
                (3 * pow(1 - t, 2) * t * points[1].y) +
                (3 * (1 - t) * pow(t, 2) * points[2].y) +
                (pow(t, 3) * points[3].y)
                
            let point = CGPoint(x: x, y: y)
            drawCurvePoint(in: point)
            bezierPoints.append(point)
            
            t += step
        } while(t <= 1.0)
        
        let color = UIColor.blue
        color.setFill()
        context.setLineWidth(1)
        context.addLines(between: bezierPoints)
        context.strokePath()
    }
    
    private func drawCurvePoint(in point: CGPoint) {
        let curvePointRadius: CGFloat = 3
        
        let color = UIColor.blue
        color.setFill()
        let path = UIBezierPath(ovalIn: CGRect(
            x: point.x - curvePointRadius,
            y: point.y - curvePointRadius,
            width: curvePointRadius * 2,
            height: curvePointRadius * 2))
        path.fill()
    }
    
}
