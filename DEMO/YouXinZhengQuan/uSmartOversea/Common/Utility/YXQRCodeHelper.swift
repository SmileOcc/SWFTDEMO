//
//  YXQRCodeHelper.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXQRCodeHelper: NSObject {
    
    // 晒单分享链接
    @objc public class func appQRString(shareId: String, bizid: String) -> String {
        let qrBaseString = YXH5Urls.YX_QR_BASE_STRING_URL()
        return qrBaseString
    }
    
    /**
     *  根据地址生成指定大小的UIImage
     *
     *  @param string 生成图片的地址
     *  @param width  图片宽度
     */
    class func qrCodeImage(with string: String, width: CGFloat = 500) -> UIImage? {
        
        if string.count > 0,
            let qrImage = qrCodeLowQualityImage(with: string),
            let image = qrCodeHDImage(with: qrImage, size: width) {
            return image
        }
        return nil
    }
    
    /**
     *  根据地址生成指定大小的CIImage
     *
     *  @param string 地址
     */
    private class func qrCodeLowQualityImage(with string: String) -> CIImage? {
        
        let data = string.data(using: .utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setDefaults()
            filter.setValue(data, forKey: "inputMessage")
            
            //设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
            /*
             * L: 7%
             * M: 15%
             * Q: 25%
             * H: 30%
             */
            filter.setValue("H", forKey: "inputCorrectionLevel")
            if let output = filter.outputImage {
                return output
            }
        }
        return nil
    }
    
    /**
     *  根据CIImage生成指定大小的UIImage
     *
     *  @param image CIImage
     *  @param size  图片宽度
     */
    private class func qrCodeHDImage(with image: CIImage, size: CGFloat) -> UIImage? {
        
        let integral: CGRect = image.extent.integral
        let proportion: CGFloat = min(size/integral.width, size/integral.height)
        
        let width = integral.width * proportion
        let height = integral.height * proportion
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        
        let context = CIContext(options: nil)
        if let bitmapImage: CGImage = context.createCGImage(image, from: integral),
            let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0) {
            bitmapRef.interpolationQuality = CGInterpolationQuality.none
            bitmapRef.scaleBy(x: proportion, y: proportion);
            bitmapRef.draw(bitmapImage, in: integral);
            
            if let image: CGImage = bitmapRef.makeImage() {
                return UIImage(cgImage: image)
            }
        }
        
        return nil
    }
    
}
