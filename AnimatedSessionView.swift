import UIKit



@IBDesignable  class AnimatedSessionView: UIView {
    
    let pi = CGFloat(M_PI)
    @IBInspectable var outlineColor: UIColor!
    @IBInspectable var counterColor: UIColor!
    var cnt : CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var visibleCircle = false
    
    override func drawRect(rect: CGRect) {
        if visibleCircle {
            let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
            let radius: CGFloat = max(bounds.width/2, bounds.height/2)
            let arcWidth: CGFloat = 2
            let startAngle =  CGFloat(0)
            let endAngle = pi * 2
            let path = UIBezierPath(arcCenter: center,
                                    radius: radius/2 - arcWidth/2,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
            
            path.lineWidth = arcWidth
            counterColor.setStroke()
            path.stroke()
            
            //Draw the outline
            let outlinePath = UIBezierPath(arcCenter: center,
                                           radius: radius/2 - 1,
                                           startAngle: 3 * pi/2,
                                           endAngle: 2 * pi * (cnt / 100.0) + (3 * pi/2),
                                           clockwise: true)
            
            //4 - close the path
            outlineColor.setStroke()
            outlinePath.lineWidth = 3
            outlinePath.stroke()
        }
    }
}
