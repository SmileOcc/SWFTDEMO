//
//  YXChartUtility.m
//  uSmartOversea
//
//  Created by rrd on 2018/8/10.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXKLineUtility.h"
#import "YXKLineConfigManager.h"

@implementation YXKLineUtility



+ (CAShapeLayer *)shapeLayerWithStokeColor:(UIColor *)strokeColor
                                 fillColor:(UIColor *)fillColor
                                 lineWidth:(CGFloat)lineWidth
                                   lineCap:(NSString *)lineCap
                                  lineJoin:(NSString *)NSString {
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
 
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.lineCap = kCALineCapSquare;
    shapeLayer.lineJoin = kCALineCapSquare;
    
    if (strokeColor) {
        shapeLayer.strokeColor = strokeColor.CGColor;
    }
    
    if (fillColor) {
        shapeLayer.fillColor = fillColor.CGColor;
    }
    
    
    return shapeLayer;
    
    
}



+ (CGFloat)getYCoordinateWithMaxPrice:(CGFloat)maxPrice
                             minPrice:(CGFloat)minPrice
                                price:(CGFloat)price
                             distance:(CGFloat)distance
                                zeroY:(CGFloat)zeroY {
    
    CGFloat priceDiv = maxPrice - minPrice;
    priceDiv = priceDiv == 0 ? 1 : priceDiv;
    CGFloat scale = distance / priceDiv;
    return zeroY - (price - minPrice) *scale;
    
}





+ (UIBezierPath *)getCandlePathWithCandleWidth:(CGFloat)candleWidth
                                  xCooordinate:(CGFloat)xCooordinate
                                         openY:(CGFloat)openY
                                        closeY:(CGFloat)closeY
                                         highY:(CGFloat)highY
                                          lowY:(CGFloat)lowY {
    
    if (YXKLineConfigManager.shareInstance.styleType == YXKlineStyleTypeOHLC) {

        UIBezierPath *path = [UIBezierPath bezierPath];
        //最高最低价
        [path moveToPoint:CGPointMake(xCooordinate, lowY)];
        [path addLineToPoint:CGPointMake(xCooordinate, highY)];
        //左侧开盘价
        [path moveToPoint:CGPointMake(xCooordinate-candleWidth/2, openY)];
        [path addLineToPoint:CGPointMake(xCooordinate, openY)];
        //右侧收盘价
        [path moveToPoint:CGPointMake(xCooordinate+candleWidth/2, closeY)];
        [path addLineToPoint:CGPointMake(xCooordinate, closeY)];

        [path closePath];
        return path;
    } else {
        CGFloat originY = closeY <= openY ? closeY : openY;

        CGRect rect = CGRectMake(xCooordinate-candleWidth/2, originY, candleWidth, fabs(openY-closeY));

        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];

        [path moveToPoint:CGPointMake(xCooordinate, originY)];
        [path addLineToPoint:CGPointMake(xCooordinate, highY)];

        [path moveToPoint:CGPointMake(xCooordinate, lowY)];
        [path addLineToPoint:CGPointMake(xCooordinate, originY+fabs(openY-closeY))];

        [path closePath];
        return path;
    }
}



+ (double)getYCoordinateWithMaxVolumn:(CGFloat)maxVolumn
                             minVolumn:(CGFloat)minVolumn
                                volume:(CGFloat)volume
                              distance:(CGFloat)distance
                                 zeroY:(CGFloat)zeroY {
    
    double volumnDiv = maxVolumn - minVolumn;
    volumnDiv = volumnDiv == 0 ? 1 : volumnDiv;
    double scale = distance / volumnDiv;
    return zeroY - (volume - minVolumn) *scale;
    
}



+ (UIBezierPath *)getVolumePathWithVoumeWidth:(CGFloat)volumeWidth
                                 xCooordinate:(CGFloat)xCooordinate
                                      volumeY:(CGFloat)volumeY
                                        zeroY:(CGFloat)zeroY {
    
    CGRect rect = CGRectMake(xCooordinate-volumeWidth/2, volumeY, volumeWidth, zeroY - volumeY);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path closePath];
    return path;
    
}

+ (UIBezierPath *)getRedMACDPathWith:(CGFloat)macdWith xCooordinate:(CGFloat)xCooordinate macdY:(CGFloat)macdY middleY:(CGFloat)middleY{
    
    CGRect rect = CGRectMake(xCooordinate-macdWith/2, macdY, macdWith, middleY - macdY);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path closePath];
    return path;
    
}

+ (UIBezierPath *)getGreenMACDPathWith:(CGFloat)macdWith xCooordinate:(CGFloat)xCooordinate macdY:(CGFloat)macdY middleY:(CGFloat)middleY{
  
    CGRect rect = CGRectMake(xCooordinate - macdWith/2, middleY, macdWith, middleY - macdY);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path closePath];
    return path;
    
}


+ (UIBezierPath *)getArrowPathWithOriginPoint:(CGPoint)originPoint targetPoint:(CGPoint)targetPoint upPoint:(CGPoint)upPoint downPoint:(CGPoint)downPoint {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:originPoint];
    [path addLineToPoint:targetPoint];
    
    [path moveToPoint:targetPoint];
    [path addLineToPoint:upPoint];
    
    [path moveToPoint:targetPoint];
    [path addLineToPoint:downPoint];
    
    return path;
    
}

+ (double)getPriceWithMaxPrice:(double)maxPrice minPrice:(double)minPrice currentY:(double)currentY distance:(double)distance zeroY:(double)zeroY{
    
    CGFloat priceDiv = maxPrice - minPrice;
    priceDiv = priceDiv == 0 ? 1 : priceDiv;
    CGFloat scale = distance / priceDiv;
    return maxPrice - (currentY - zeroY) / scale;
    
}

@end
