//
//  PaymentListModel.m
//  Dezzal
//
//  Created by 7FD75 on 16/8/6.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "PaymentListModel.h"

@interface PaymentListModel ()

@property (nonatomic, strong, readwrite) NSMutableArray *iconSizeList;

@end

@implementation PaymentListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"offer_message" : [OfferMessage class],
             @"pay_desc_list" : [PaymentIconModel class]
             };
}

-(BOOL)isPayPalPayment
{
    if ([[self.pay_code lowercaseString] containsString:@"paypal"]) {
        return YES;
    }
    return NO;
}

-(BOOL)isCodePayment
{
    if ([[self.pay_code lowercaseString] containsString:@"cod"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isOnlinePayment
{
    if ([[self.pay_code lowercaseString] containsString:@"pay_online"]) {
        return YES;
    }
    return NO;
}


-(void)setPayIconImageList:(NSArray*)payIconImageList
{
    _payIconImageList = payIconImageList;
}

-(NSMutableArray *)iconSizeList
{
    if (!_iconSizeList) {
        _iconSizeList = [[NSMutableArray alloc] init];
    }
    return _iconSizeList;
}

@end

@implementation OfferMessage

@end

@implementation PaymentIconModel

@end
