//
//  ZFNoDataTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/7/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 为防止多Cell判断,UITableViewCell return nil 造成奔溃的View. 高度为0的Cell. */

@interface ZFNoDataTableViewCell : UITableViewCell

+ (NSString *)queryReuseIdentifier;

@end
