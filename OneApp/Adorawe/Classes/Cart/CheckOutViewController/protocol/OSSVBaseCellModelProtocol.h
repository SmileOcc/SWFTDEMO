//
//  OSSVBaseCellModelProtocol.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

///显示价格的类型 ex. Products Total, Shipping Cost ...
typedef NS_ENUM(NSInteger) {
    TotalDetailTypeNoromal,
    TotalDetailTypeProductTotal,           ///<单仓显示总价格
    TotalDetailTypeShippingCost,           ///<物流手续费
    TotalDetailTypeShippingInsurance,      ///<物流保险
    TotalDetailTypeCODCost,                ///<COD手续费
    TotalDetailTypeSave,                   ///<活动商品折扣
    TotalDetailTypeCoupon,                 ///<优惠券
    TotalDetailTypeYpoint,                 ///<积分
    TotalDetailTypeCODRounding,            ///<COD取整
    TotalDetailTypeTotal,                   ///<单仓的时候显示
    TotalDetailTypeDiscount,               ///<支付方式的折扣金额>
    TotalDetailTypeCoinSave                ///<金币优惠金额>
}TotalDetailType;

@protocol OSSVBaseCellModelProtocol <NSObject>

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL showSeparatorStyle;

+(NSString *)cellIdentifier;

-(NSString *)cellIdentifier;

@end
