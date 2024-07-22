//
//  ZFTrackingListModel.h
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZFTrackingListModel : NSObject
@property (nonatomic, copy) NSString        *ondate;
@property (nonatomic, copy) NSString        *status;
@property (nonatomic, assign) NSInteger     trackTime;  //用于排序的时间戳
@property (assign, nonatomic, readonly)CGFloat height;
@end
