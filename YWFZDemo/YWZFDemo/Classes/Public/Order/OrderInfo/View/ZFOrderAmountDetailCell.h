//
//  ZFOrderAmountDetailCell.h
//  ZZZZZ
//
//  Created by YW on 21/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFOrderAmountDetailModel;
@interface ZFOrderAmountDetailCell : UITableViewCell

+ (NSString *)queryReuseIdentifier;

@property (nonatomic, strong) ZFOrderAmountDetailModel   *model;
@end
