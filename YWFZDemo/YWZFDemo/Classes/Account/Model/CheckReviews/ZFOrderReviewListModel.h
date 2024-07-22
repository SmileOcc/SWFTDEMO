//
//  ZFOrderReviewListModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFOrderReviewModel.h"
#import "ZFOrderSizeModel.h"
#import <YYModel/YYModel.h>

@interface ZFOrderReviewListSizeModel : NSObject

@property (nonatomic, strong) NSArray <ZFOrderSizeModel *>*waist;
@property (nonatomic, strong) NSArray <ZFOrderSizeModel *>*height;
@property (nonatomic, strong) NSArray <ZFOrderSizeModel *>*hips;
@property (nonatomic, strong) NSArray <ZFOrderSizeModel *>*bust;

@end

@interface ZFOrderReviewListModel : NSObject <YYModel>

@property (nonatomic, strong) NSMutableArray<ZFOrderReviewModel *>  *result;
@property (nonatomic, strong) ZFOrderReviewListSizeModel            *size;

@end
