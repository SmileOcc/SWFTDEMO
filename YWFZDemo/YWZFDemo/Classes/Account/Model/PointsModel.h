//
//  PointsModel.h
//  Dezzal
//
//  Created by YW on 18/8/11.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PointsModel : NSObject
@property (nonatomic, copy)   NSString * adddate; // 添加时间
@property (nonatomic, assign) CGFloat    income;  // 增加积分数
@property (nonatomic, assign) CGFloat    outgo;   // 消费积分数
@property (nonatomic, assign) CGFloat    balance; // 余额
@property (nonatomic, copy)   NSString * note;    // 积分增加或减少说明
@end
