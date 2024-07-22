//
//  ZFOrderAddressCell.h
//  ZZZZZ
//
//  Created by YW on 17/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFAddressInfoModel;
@interface ZFOrderAddressCell : UITableViewCell

@property (nonatomic, strong) ZFAddressInfoModel   *addressModel;

+ (NSString *)queryReuseIdentifier;

@end
