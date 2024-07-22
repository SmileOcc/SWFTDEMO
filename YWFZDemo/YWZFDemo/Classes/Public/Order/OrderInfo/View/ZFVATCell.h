//
//  ZFVATCell.h
//  ZZZZZ
//
//  Created by YW on 6/1/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFOrderAmountDetailModel;

@interface ZFVATCell : UITableViewCell

+ (NSString *)queryReuseIdentifier;

@property (nonatomic, assign) BOOL                       isCod;

@property (nonatomic, strong) ZFOrderAmountDetailModel   *model;

@end
