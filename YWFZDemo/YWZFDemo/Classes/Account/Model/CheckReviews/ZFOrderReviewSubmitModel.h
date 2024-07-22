//
//  ZFOrderReviewSubmitModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZFOrderReviewSubmitModel : NSObject
@property (nonatomic, copy)   NSString               *content;
@property (nonatomic, assign) CGFloat                avgRate;
@property (nonatomic, strong) NSMutableArray         *selectedPhotos;
@property (nonatomic, strong) NSMutableArray         *selectedAssets;
@property (nonatomic, assign) BOOL                   sync_community;//sync_community 默认时1，不同步为 0
@property (nonatomic, assign) NSInteger              overallid; //合适度
@end
