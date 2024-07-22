//
//  ZFOrderPaymentListCell.h
//  ZZZZZ
//
//  Created by YW on 18/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  PaymentListModel;
typedef void(^payMentListTapBlcok)(void);
@interface ZFOrderPaymentListCell : UITableViewCell

+ (NSString *)queryReuseIdentifier;

@property (nonatomic, strong) PaymentListModel  *paymentListmodel;
@property (nonatomic, assign) BOOL              isChoose;
@property (nonatomic, strong) UIView            *separatorLine;

@end


