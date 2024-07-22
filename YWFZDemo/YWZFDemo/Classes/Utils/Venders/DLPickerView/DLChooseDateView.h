//
//  DLChooseDateView.h
//  YDGJ
//
//  Created by ydcq on 16/8/26.
//  Copyright © 2016年 Galaxy360. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLChooseDateView : UIView

/// 是否自动滑动 默认YES
@property (assign, nonatomic) BOOL isSlide;

/// 选中的时间， 默认是当前时间 2017-02-12 13:35
@property (copy, nonatomic) NSString *date;

/// 分钟间隔 默认5分钟
@property (assign, nonatomic) NSInteger minuteInterval;


+ (instancetype)showDateView:(id)title
                 cancelBlock:(void(^)(void))cancelBlock
                confirmBlock:(void(^)(NSString *date))confirmBlock;

@end
