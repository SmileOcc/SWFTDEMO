//
//  YXIAPManager.h
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/3/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Product : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) NSString *itunes_product_id;

@end

typedef NS_ENUM(NSInteger, YXIAPFailedCode) {
    /**
     *  参数错误
     */
    IAP_FAILEDCOED_PARAMERROR = -1,
    
    /**
     *  用户禁止应用内付费购买
     */
    IAP_FAILEDCOED_NORIGHT = -2,
    
    /**
     *  苹果返回错误信息
     */
    IAP_FAILEDCOED_APPLECODE = -3,

    /**
     *  无法获取产品信息，请重试
     */
    IAP_FAILEDCOED_CANNOTGETINFORMATION = -4,
    /**
     *  购买失败，请重试
     */
    IAP_FAILEDCOED_BUYFILED = -5,
    /**
     *  用户取消交易
     */
    IAP_FAILEDCOED_USERCANCEL = -6
    
};


@protocol YXIApRequestResultsDelegate <NSObject>

- (void)failedWithErrorCode:(NSInteger)errorCode andError:(NSString *)error; //失败

- (void)successWithResult:(NSDictionary<NSString *, id> * )result; //成功

@end

@interface YXIAPManager : NSObject


@property (nonatomic, weak)id<YXIApRequestResultsDelegate>delegate;

+ (YXIAPManager *)shared;


- (void)startManager;

- (void)stopManager;

- (void)requestProduct:(Product *)product;

- (void)removeReceiptWithOrderId:(NSString *)orderId;

- (void)checkIAPFiles;

@end

NS_ASSUME_NONNULL_END
