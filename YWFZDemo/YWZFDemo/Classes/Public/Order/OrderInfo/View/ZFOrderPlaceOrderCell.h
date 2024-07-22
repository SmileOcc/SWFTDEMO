//
//  ZFOrderPlaceOrderCell.h
//  ZZZZZ
//
//  Created by YW on 22/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFOrderPlaceOrderCell : UITableViewCell

+ (NSString *)queryReuseIdentifier;

@property (nonatomic, assign) BOOL   isFastPay;

- (void)placeOrderButtonCanTouch:(BOOL)state;

@end
