//
//  OSSVCouponCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCouponCellModel.h"

@implementation OSSVCouponCellModel
@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.showSeparatorStyle = NO;
    }
    return self;
}

#pragma mark - protocol

+(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

#pragma mark - setter and getter

-(void)setCouponModel:(OSSVCouponModel *)couponModel{
    _couponModel = couponModel;
    
    if ([OSSVNSStringTool isEmptyString:_couponModel.code]) {
        ///为空的时候
        self.inputUserInteractionEnabled = YES;
        self.status = ApplyButtonStatusApply;
        self.codeText = @"";
    }else{
        self.inputUserInteractionEnabled = NO;
        self.status = ApplyButtonStatusClear;
        self.codeText = couponModel.code;
    }
}

@end

#pragma mark - STLCouponSaveCellModel

@interface STLCouponSaveCellModel ()
@property (nonatomic, copy, readwrite) NSAttributedString *attriSaveValue;

@end

@implementation STLCouponSaveCellModel
@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.showSeparatorStyle = NO;
    }
    return self;
}

#pragma mark - protocol

+(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

-(void)setCheckModel:(OSSVCartCheckModel *)checkModel{
    _checkModel = checkModel;
    
    ///转换优惠券金额
    NSString *saveValue = checkModel.coupon.save;
    if (saveValue) {
//        NSString *price = [ExchangeManager changeRateModel:_checkModel.currencyInfo transforPrice:saveValue priceType:PriceType_Coupon];
//        NSString *exChange = [ExchangeManager appenSymbol:_checkModel.currencyInfo price:price];
        NSString *exChange = STLToString(checkModel.fee_data.coupon_save_converted);
        NSString *save = STLLocalizedString_(@"save", nil);
        NSString *title = [NSString stringWithFormat:@"%@: %@",save, exChange];
        NSRange range = [title rangeOfString:exChange];
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:title];
        [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} range:NSMakeRange(0, title.length)];
        [attriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_B62B21} range:range];
        self.attriSaveValue = attriString;
    }
}

@end
