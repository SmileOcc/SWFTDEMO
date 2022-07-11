//
//  OSSVCouponCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVBaseCellModelProtocol.h"
#import "OSSVCouponModel.h"
#import "OSSVCartCheckModel.h"

typedef NS_ENUM(NSInteger) {
    ApplyButtonStatusApply,            ///<没有选择优惠券->未选择优惠券状态
    ApplyButtonStatusClear             ///<选择完优惠券->清除优惠券状态
}ApplyButtonStatus;

@interface OSSVCouponCellModel : NSObject<OSSVBaseCellModelProtocol>


@property (nonatomic, strong) OSSVCouponModel       *couponModel;

@property (nonatomic, assign) BOOL              inputUserInteractionEnabled;
@property (nonatomic, assign) ApplyButtonStatus status;
@property (nonatomic, copy) NSString            *codeText;

@end

@interface STLCouponSaveCellModel : NSObject<OSSVBaseCellModelProtocol>

@property (nonatomic, strong) OSSVCartCheckModel                *checkModel;

@property (nonatomic, copy, readonly) NSAttributedString    *attriSaveValue;

@end
