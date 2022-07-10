//
//  UIKit+Extension.swift
//  SwiftStructure
//
//  Created by MountainZhu on 2019/8/21.
//  Copyright © 2019 Mountain. All rights reserved.
//

//使用说明
//使用view.x
//

import Foundation
import UIKit
import CoreText

public enum DrawLineLocation: NSInteger {
    case TopLocation = 1
    case LeftLocation
    case BottonLocation
    case RightLocation
}

public enum CornerRadiusType: NSInteger {
    case CornerRadiusTop = 1
    case CornerRadiusLeft
    case CornerRadiusBottom
    case CornerRadiusRight
    case CornerRadiusAll
}

public extension UIView {
    
    /// x
    var x: CGFloat {
        get { return frame.origin.x }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.x    = newValue
            frame                 = tempFrame
        }
    }
    
    /// y
    var y: CGFloat {
        get { return frame.origin.y }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.y    = newValue
            frame                 = tempFrame
        }
    }
    
    ///left
    var left: CGFloat {
        get { return frame.origin.x }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.x    = newValue
            frame                 = tempFrame
        }
    }
    
    ///right
    var right: CGFloat {
        get { return frame.origin.x + frame.size.width}
    }
    
    /// height
    var height: CGFloat {
        get { return frame.size.height }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.height = newValue
            frame                 = tempFrame
        }
    }
    
    /// width
    var width: CGFloat {
        get { return frame.size.width }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.width  = newValue
            frame = tempFrame
        }
    }
    
    /// top
    var top: CGFloat {
        get { return frame.origin.y }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.y    = newValue
            frame                 = tempFrame
        }
    }
    
    /// bottom
    var bottom: CGFloat {
        get { return frame.origin.y + frame.size.height}
    }
    
    /// size
    var size: CGSize {
        get { return frame.size }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size        = newValue
            frame                 = tempFrame
        }
    }
    
    /// centerX
    var centerX: CGFloat {
        get { return center.x }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.x            = newValue
            center                  = tempCenter
        }
    }
    
    /// centerY
    var centerY: CGFloat {
        get { return center.y }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.y            = newValue
            center                  = tempCenter;
        }
    }
    
    // MARK: 添加划线
    func drawLineLocation(location: DrawLineLocation, color: UIColor, inset: UIEdgeInsets) {
        var view = UIView()
        if (self.viewWithTag(location.rawValue) != nil) {
            view = self.viewWithTag(location.rawValue) ?? UIView()
        }
        view.tag = location.rawValue
        view.backgroundColor = color
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        switch location {
        case .TopLocation:
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.top, multiplier:1, constant:inset.top))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.leading, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.leading, multiplier:1, constant:inset.left))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.trailing, multiplier:1, constant:inset.right))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.height, relatedBy:NSLayoutConstraint.Relation.equal, toItem:nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier:1, constant:inset.bottom + 1))

            break
                
        case .LeftLocation:
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.top, multiplier:1, constant:inset.top))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.leading, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.leading, multiplier:1, constant:inset.left))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier:1, constant:inset.bottom))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.width, relatedBy:NSLayoutConstraint.Relation.equal, toItem:nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier:1, constant:inset.right + 1))
            
            break
        case .BottonLocation:
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.trailing, multiplier:1, constant:inset.right))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.leading, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.leading, multiplier:1, constant:inset.left))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier:1, constant:inset.bottom))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.height, relatedBy:NSLayoutConstraint.Relation.equal, toItem:nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier:1, constant:inset.top + 1))
            
            break
        case .RightLocation:
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.top, multiplier:1, constant:inset.top))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.trailing, multiplier:1, constant:inset.right))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy:NSLayoutConstraint.Relation.equal, toItem:self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier:1, constant:inset.bottom))
            self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.width, relatedBy:NSLayoutConstraint.Relation.equal, toItem:nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier:1, constant:inset.left + 1))
            
            break
        
        }
    }
    
    // MARK: 添加圆角
    func cornerRadiusType(sideType: CornerRadiusType, cornerRadius: CGFloat) {
        let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        var corners: UIRectCorner = []
        
        switch sideType {
        case .CornerRadiusTop:
            corners = [.topLeft, .topRight]
            break
            
        case .CornerRadiusLeft:
            corners = [.topLeft, .bottomLeft]
            break
            
        case .CornerRadiusBottom:
            corners = [.bottomLeft, .bottomRight]
            break
            
        case .CornerRadiusRight:
            corners = [.topRight, .bottomRight]
            break
            
        case .CornerRadiusAll:
            corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            break
        }
        
        let maskPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: cornerSize)

        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}

public protocol RegisterCellFromNib {}

extension RegisterCellFromNib {
    static var identifier: String { return "\(self)" }
    static var nib: UINib? { return UINib(nibName: "\(self)", bundle: nil) }
}

public extension UITableView {
    /// 注册 cell 的方法
    func HDregisterCell<T: UITableViewCell>(cell: T.Type) where T: RegisterCellFromNib {
        if let nib = T.nib { register(nib, forCellReuseIdentifier: T.identifier) }
        else { register(cell, forCellReuseIdentifier: T.identifier) }
    }
    
    /// 从缓存池池出队已经存在的 cell
    func HDdequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: RegisterCellFromNib {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }
}

public extension UICollectionView {
    /// 注册 cell 的方法
    func HDRegisterCell<T: UICollectionViewCell>(cell: T.Type) where T: RegisterCellFromNib {
        if let nib = T.nib { register(nib, forCellWithReuseIdentifier: T.identifier) }
        else { register(cell, forCellWithReuseIdentifier: T.identifier) }
    }
    
    /// 从缓存池池出队已经存在的 cell
    func HDDequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T where T: RegisterCellFromNib {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
    
    /// 注册头部
    func HDRegisterSupplementaryHeaderView<T: UICollectionReusableView>(reusableView: T.Type) where T: RegisterCellFromNib {
        // T 遵守了 RegisterCellOrNib 协议，所以通过 T 就能取出 identifier 这个属性
        if let nib = T.nib {
            register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier)
        } else {
            register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier)
        }
    }
    
    /// 获取可重用的头部
    func HDDequeueReusableSupplementaryHeaderView<T: UICollectionReusableView>(indexPath: IndexPath) -> T where T: RegisterCellFromNib {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
}

public extension UIImageView {
    /// 设置图片圆角
    func circleImage() {
        /// 建立上下文
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        /// 获取当前上下文
        let ctx = UIGraphicsGetCurrentContext()
        /// 添加一个圆，并裁剪
        ctx?.addEllipse(in: self.bounds)
        ctx?.clip()
        /// 绘制图像
        self.draw(self.bounds)
        /// 获取绘制的图像
        let image = UIGraphicsGetImageFromCurrentImageContext()
        /// 关闭上下文
        UIGraphicsEndImageContext()
        DispatchQueue.global().async {
            self.image = image
        }
    }
}

public extension UIImage {
    //设置颜色作为背景色
    static func imageFromColor(_ color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 10, height: 10)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsGetCurrentContext()
        return image!
    }
}
