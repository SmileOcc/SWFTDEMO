//
//  UIImageCategory.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics


extension UIImage {
//    public func drawCorner(InRect rect:CGRect,cornerRadius:CGFloat) -> UIImage {
//        let bezierPath = UIBezierPath.init(roundedRect: rect, cornerRadius: cornerRadius)
//        //UIGraphicsBeginImageContext(rect.size)
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
////        CGContext.addPath(UIGraphicsGetCurrentContext(),bezierPath.cgPath)
////        CGContext.clip(UIGraphicsGetCurrentContext())
////        self.draw(in: rect)
////
////        CGContext.drawPath(<#T##CGContext#>)
//    }
    
    // 扩展 UIImage 的 init 方法，获得渐变效果
    convenience init(gradientColors:[UIColor], size:CGSize = CGSize(width: 10, height: 10) )
    {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = gradientColors.map {(color: UIColor) -> AnyObject? in
            color.cgColor
        } as NSArray
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)
        // 第二个参数是起始位置，第三个参数是终止位置
        context!.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: 0), options: CGGradientDrawingOptions(rawValue: 0))
        if let temp = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
            self.init(cgImage: temp)
        } else {
            self.init()
        }
        
        UIGraphicsEndImageContext()
    }
    
    /// 渐变色变图片 color的透明度为0 也能用
    /// - Parameters:
    ///   - gradientColors: colors
    ///   - size: size description
    ///   - isHorizontal: isHorizontal description
    @objc convenience init(gradientColors:[UIColor], size:CGSize = CGSize(width: 10, height: 10) , isHorizontal: Bool){
        if gradientColors.count == 0 {
            self.init()
            return
        }
        let gradientLayer: CAGradientLayer = CAGradientLayer()
       
        if isHorizontal {
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        }else{
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        }
        let colors = gradientColors.map {(color: UIColor) -> AnyObject? in
            return color.cgColor } as NSArray
        gradientLayer.colors = colors as? [Any]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, gradientLayer.isOpaque, 0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
       
        if let temp = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
            self.init(cgImage: temp)
        } else {
            self.init()
        }
        
    }
}


extension UIImage {
    
    var sensitiveInfo:String {
       return "https://m.usmart8.com"
    }
    
    @objc func hasSensitiveQRCode() -> Bool {

        var hasSensitive = false
        
        if let targetImage = self.cgImage {
            
            let result = targetImage.ciImage().recognizeQRCode(options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            if result.isEmpty {
                if let grayscaleImage = targetImage.grayscale {
                    let doubleCheckResult =  grayscaleImage.ciImage().recognizeQRCode( options: [CIDetectorAccuracy: CIDetectorAccuracyLow] )
                    for messege in doubleCheckResult {
                        let flag = messege.hasPrefix(self.sensitiveInfo) || messege.hasPrefix(YXUrlRouterConstant.staticResourceBaseUrl())
                        if !flag {
                            hasSensitive = true
                            break
                        }
                    }
                }
                
            } else {
                
                for messege in result {
                    let flag = messege.hasPrefix(self.sensitiveInfo) || messege.hasPrefix(YXUrlRouterConstant.staticResourceBaseUrl())
                    if !flag  {
                        hasSensitive = true
                        break
                    }
                }
            }
            
        }
        return hasSensitive
    }
    
}

extension CGImage {
    
    func ciImage() -> CIImage {
        return CIImage(cgImage: self)
    }
    
    var grayscale: CGImage? {
        guard let context = CGContext(
            data: nil,
            width: self.width,
            height: self.height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * self.width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
            ) else {
                return nil
        }
        context.draw(self, in: CGRect(origin: .zero, size: CGSize(width: self.width, height: self.height)))
        return context.makeImage()
    }
}

extension CIImage {
    func recognizeQRCode(options: [String : Any]? = nil) -> [String] {
        var result = [String]()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)
        guard let features = detector?.features(in: self) else {
            return result
        }
        result = features.compactMap { feature in
            (feature as? CIQRCodeFeature)?.messageString
        }
        return result
    }
}
