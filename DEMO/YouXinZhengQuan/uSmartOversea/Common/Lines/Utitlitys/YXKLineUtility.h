//
//  YXChartUtility.h
//  uSmartOversea
//
//  Created by rrd on 2018/8/10.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YXKLineUtility : NSObject


+ (CAShapeLayer *)shapeLayerWithStokeColor:(UIColor *)strokeColor
                                 fillColor:(UIColor *)fillColor
                                 lineWidth:(CGFloat)lineWidth
                                   lineCap:(NSString *)lineCap
                                  lineJoin:(NSString *)NSString;




/**
 得到对应价格的y坐标

 @param maxPrice 最大价格
 @param minPrice 最小价格
 @param price 当前价格
 @param distance 坐标纵向区域
 @param zeroY 原点纵坐标

 @return 返回对应坐标
 */
+ (CGFloat)getYCoordinateWithMaxPrice:(CGFloat)maxPrice
                             minPrice:(CGFloat)minPrice
                                price:(CGFloat)price
                             distance:(CGFloat)distance
                                zeroY:(CGFloat)zeroY;



/**
 根据坐标得到蜡烛路径

 @param candleWidth 蜡烛宽度
 @param xCooordinate x坐标
 @param openY 开盘y坐标
 @param closeY 收盘y坐标
 @param highY 最高价y坐标
 @param lowY 最低价y坐标
 @return 蜡烛路径
 */
+ (UIBezierPath *)getCandlePathWithCandleWidth:(CGFloat)candleWidth
                                  xCooordinate:(CGFloat)xCooordinate
                                         openY:(CGFloat)openY
                                        closeY:(CGFloat)closeY
                                         highY:(CGFloat)highY
                                          lowY:(CGFloat)lowY;


/**
 <#Description#>

 @param maxVolumn <#maxVolumn description#>
 @param minVolumn <#minVolumn description#>
 @param volume <#volume description#>
 @param distance <#distance description#>
 @param zeroY <#zeroY description#>
 @return <#return value description#>
 */
+ (double)getYCoordinateWithMaxVolumn:(CGFloat)maxVolumn
                             minVolumn:(CGFloat)minVolumn
                                volume:(CGFloat)volume
                              distance:(CGFloat)distance
                                 zeroY:(CGFloat)zeroY ;



/**
 <#Description#>

 @param volumeWidth <#volumeWidth description#>
 @param xCooordinate <#xCooordinate description#>
 @param volumeY <#volumeY description#>
 @param zeroY <#zeroY description#>
 @return <#return value description#>
 */
+ (UIBezierPath *)getVolumePathWithVoumeWidth:(CGFloat)volumeWidth
                                 xCooordinate:(CGFloat)xCooordinate
                                      volumeY:(CGFloat)volumeY
                                        zeroY:(CGFloat)zeroY ;





+ (UIBezierPath *)getRedMACDPathWith:(CGFloat)macdWith xCooordinate:(CGFloat)xCooordinate macdY:(CGFloat)macdY middleY:(CGFloat)middleY;


+ (UIBezierPath *)getGreenMACDPathWith:(CGFloat)macdWith xCooordinate:(CGFloat)xCooordinate macdY:(CGFloat)macdY middleY:(CGFloat)middleY;

/**
 
                                （upPoint）
  （originPoint）--（targetPoint）   >
                                （downPoint）
 
 @param originPoint            如图
 @param targetPoint
 @param upPoint
 @param downPoint



 
 */
+ (UIBezierPath *)getArrowPathWithOriginPoint:(CGPoint)originPoint
                                  targetPoint:(CGPoint)targetPoint
                                      upPoint:(CGPoint)upPoint
                                    downPoint:(CGPoint)downPoint;


+ (double)getPriceWithMaxPrice:(double)maxPrice minPrice:(double)minPrice currentY:(double)currentY distance:(double)distance zeroY:(double)zeroY;

@end
