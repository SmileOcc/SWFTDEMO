//
//  ZFTrackingGoodsCell.h
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFTrackingGoodsModel;

@interface ZFTrackingGoodsCell : UITableViewCell

@property (nonatomic, strong) ZFTrackingGoodsModel   *model;

+ (NSString *)setIdentifier;

@end
