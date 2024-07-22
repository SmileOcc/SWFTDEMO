//
//  ZFAddressEditNameTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseEditAddressCell.h"

typedef NS_ENUM(NSInteger, ZFAddressNameType) {
    ZFAddressNameTypeFirstName = 0,
    ZFAddressNameTypeLastName = 1,
};

@interface ZFAddressEditNameTableViewCell : ZFBaseEditAddressCell

- (void)becomeFirstResponder;
@end
