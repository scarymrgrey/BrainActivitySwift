//
//  EZConstraint.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 06/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//
class ConstraintsContainer {
    var mainview : UIView!
    var targetItem : UIView!
    var _relatedItem : UIView!
    var relatedItem : UIView! {
        get{
            if _relatedItem == nil{
                _relatedItem = mainview
            }
            return _relatedItem
        }
        set (value) {
            _relatedItem = value
        }
    }
    
    func Related(to item : UIView) -> ConstraintsContainer{
        relatedItem = item
        return self
    }
    func Height(value : CGFloat)-> ConstraintsContainer{
        mainview.addConstraint(NSLayoutConstraint(item: targetItem, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: value))
        return self
    }
    func Width(value : CGFloat) -> ConstraintsContainer{
        mainview.addConstraint(NSLayoutConstraint(item: targetItem, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: value))
        return self
    }
    func Leading(value : CGFloat)-> ConstraintsContainer{
        return AddComplex(from: .LeadingMargin, to: .LeadingMargin, value: value)
    }
    func Top(value : CGFloat)-> ConstraintsContainer{
        return  AddComplex(from: .Top, to: .Top, value: value)
    }
    func Trailing(value : CGFloat)-> ConstraintsContainer{
        return AddComplex(from: .TrailingMargin, to: .TrailingMargin, value: value)
    }
    func Bottom(value : CGFloat)-> ConstraintsContainer{
        return AddComplex(from: .Bottom, to: .Bottom, value: value)
    }
    func CenterX(value : CGFloat)-> ConstraintsContainer{
        return AddComplex(from: .CenterX, to: .CenterX, value: value)
    }
    func CenterY(value : CGFloat)-> ConstraintsContainer{
        return AddComplex(from: .CenterY, to: .CenterY, value: value)
    }
    func AddComplex (from from: NSLayoutAttribute ,to : NSLayoutAttribute ,value : CGFloat) -> ConstraintsContainer{
        mainview.addConstraint(NSLayoutConstraint(item: targetItem, attribute: from, relatedBy: .Equal, toItem: relatedItem, attribute: to, multiplier: 1.0, constant: value))
        return self
    }
}
extension UIView {
    func Constraints(forTarget target: UIView) -> ConstraintsContainer {
        let container = ConstraintsContainer()
        container.mainview = self
        container.targetItem = target
        return container
    }
    func addSubViews(items : [UIView])  {
        for item in items{
            item.addSubview(item)
        }
    }
}

