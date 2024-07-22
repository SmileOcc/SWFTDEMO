//
//  ZFOrderCurrentPaymentCell.h
//  ZZZZZ
//
//  Created by YW on 17/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFOrderCurrentPaymentCell : UITableViewCell

@property (nonatomic, copy) NSString   *currentPayment;

+ (NSString *)queryReuseIdentifier;

@end
