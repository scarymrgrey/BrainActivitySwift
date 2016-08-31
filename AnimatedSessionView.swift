import UIKit

@IBDesignable  class AnimatedSessionView: AnimationView {
    @IBOutlet weak var CenterTextLabel: UILabel!
    
    let pi = CGFloat(M_PI)
    @IBInspectable var outlineColor: UIColor! = UIColor.whiteColor()
    @IBInspectable var counterColor: UIColor! = Colors.dorange
    var cnt : CGFloat = 0.0 {
        didSet {
            redrawOutline(with: cnt)
        }
    }
    var outlineLayer : CAShapeLayer!
    var counterLayer : CAShapeLayer!
    func drawCounter(){
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = max(bounds.width/2, bounds.height/2)
        let arcWidth: CGFloat = 1
        let startAngle =  CGFloat(0)
        let endAngle = pi * 2
        let path = UIBezierPath(arcCenter: center,
                                radius: radius/2 - arcWidth/2,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        counterLayer = CAShapeLayer()
        counterLayer.frame = self.bounds
        counterLayer.path = path.CGPath
        counterLayer.lineWidth = arcWidth
        counterLayer.fillColor = UIColor.clearColor().CGColor
        counterLayer.strokeColor = counterColor.CGColor
        layer.insertSublayer(counterLayer, atIndex: 0)
    }
    func redrawOutline(with value: CGFloat){
        let radius: CGFloat = max(bounds.width/2, bounds.height/2)
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        let outlinePath = UIBezierPath(arcCenter: center,
                                       radius: radius/2 - 1,
                                       startAngle: 3 * pi/2,
                                       endAngle: 2 * pi * (value / 100.0) + (3 * pi/2),
                                       clockwise: true)
        
        if outlineLayer == nil  {
            outlineLayer = CAShapeLayer()
            self.layer.insertSublayer(outlineLayer, atIndex: 1)
        }
        outlineLayer.frame = self.bounds
        outlineLayer.path = outlinePath.CGPath
        outlineLayer.lineWidth = 2
        outlineLayer.fillColor = UIColor.clearColor().CGColor
        outlineLayer.strokeColor = outlineColor.CGColor
    }
}
