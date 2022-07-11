//
//  STLShippingMethodCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVArrowCellModel.h"
#import "OSSVCartShippingModel.h"
#import "OSSVCouponModel.h"
#import "OSSVCartWareHouseModel.h"
#import "OSSVCartCheckModel.h"
#import "OSSVCoinModel.h"
#import "YYText.h"
#import "Adorawe-Swift.h"

@interface OSSVArrowCellModel ()

@end

@implementation OSSVArrowCellModel
@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.showSeparatorStyle = NO;
        self.depenDentModelList = [[NSMutableArray alloc] init];
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

-(void)setCellType:(ArrowCellType)cellType{
    _cellType = cellType;
}

-(void)setDataSourceModel:(NSObject *)dataSourceModel{
    _dataSourceModel = dataSourceModel;
    self.userInteractionEnabled = YES;
    
    if ([_dataSourceModel isKindOfClass:[OSSVCartShippingModel class]]) {
        //物流方式
        self.cellType = ArrowCellTypeNormal;
        OSSVCartShippingModel *shippModel = (OSSVCartShippingModel *)_dataSourceModel;
        self.titleContent = shippModel.shipName;
        self.detailContent = [[NSAttributedString alloc] initWithString:shippModel.shipDesc];
        if ([shippModel isCodShipping]) {
            ///cod指定物流不能再选择其他物流
            self.userInteractionEnabled = NO;
        }
        
    } else if ([_dataSourceModel isKindOfClass:[OSSVCoinModel class]]){
        //金币
        self.cellType = ArrowCellTypeExplain_Button;
        OSSVCoinModel *coinModel = (OSSVCoinModel *)_dataSourceModel;
        self.titleContent = STLLocalizedString_(@"Coins", nil);

        //可使用金币大于0
        if (STLToString(coinModel.coins).intValue > 0) {
//            self.coinContent = [NSString stringWithFormat:@"%@%@%@%@", STLToString(coinModel.coinText1),STLToString(coinModel.coins), STLToString(coinModel.coinText2),STLToString(coinModel.save)];
            
            self.coinSave = STLToString(coinModel.save);
            self.coinTitle1 = STLToString(coinModel.coinText1);
            self.coinTitle2 = STLToString(coinModel.coinText2);
            self.coinCount = STLToString(coinModel.coins);
            self.isDisableButton = NO;
        } else {
            self.coinSave = STLLocalizedString_(@"NoCoin", nil);
            self.isDisableButton =  YES;
        }
       
        
    } else if ([_dataSourceModel isKindOfClass:[OSSVCartCheckModel class]]){
        //优惠券
        self.cellType = ArrowCellTypeExplain_Detail;
        OSSVCartCheckModel *cartCheck = (OSSVCartCheckModel *)_dataSourceModel;
        self.titleContent = STLLocalizedString_(@"checkOutCoupon", nil);
        NSString *detailString = nil;
        NSDictionary *attribute = nil;
        NSMutableAttributedString *mutAttributeString = nil;
        
        if (cartCheck.usableCouponNum.integerValue == 0) {
            attribute = @{NSForegroundColorAttributeName : OSSVThemesColors.col_666666};
//            detailString = STLLocalizedString_(@"couponFromAccount", nil);
            detailString = STLToString(cartCheck.couponMsg);  //新增的优惠券返回文案
            mutAttributeString = [[NSMutableAttributedString alloc] initWithString:detailString];
//            mutAttributeString
            [mutAttributeString addAttributes:attribute range:NSMakeRange(0, detailString.length)];
            mutAttributeString.yy_font = [UIFont systemFontOfSize:14];
            
        } else if (cartCheck.coupon.save.length > 0) {
            
            NSString *saveValue = cartCheck.coupon.save;
            if (saveValue) {
                NSString *exChange = STLToString(cartCheck.fee_data.coupon_save_converted);
                
//                NSString *save = STLLocalizedString_(@"save", nil);
                NSString *format = OSSVSystemsConfigsUtils.isRightToLeftShow && !exChange.isContainArabic ? @"%@ -" : @"- %@";

                NSString *title = [NSString stringWithFormat:format, exChange];
//                NSRange range = [title rangeOfString:exChange];
                mutAttributeString = [[NSMutableAttributedString alloc] initWithString:title];

                mutAttributeString.yy_color = APP_TYPE == 3 ? OSSVThemesColors.col_9F5123 : OSSVThemesColors.col_B62B21;
                mutAttributeString.yy_font = [UIFont systemFontOfSize:14];
            }

        } else{
            detailString = STLToString(cartCheck.couponMsg);
            
//            detailString = [NSString stringWithFormat:@"%@ %@", cartCheck.usableCouponNum, STLLocalizedString_(@"coupons_available", nil)];
            mutAttributeString = [[NSMutableAttributedString alloc] initWithString:detailString];
            
            NSMutableAttributedString *tipIcon = [NSMutableAttributedString
                                                  yy_attachmentStringWithContent:[UIImage imageNamed:@"coupon_tips"]
                                                  contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(12, 12)
                                                  alignToFont:[UIFont boldSystemFontOfSize:10]
                                                  alignment:YYTextVerticalAlignmentCenter];;
            [tipIcon yy_appendString:@" "];
            [mutAttributeString insertAttributedString:tipIcon atIndex:0];
            mutAttributeString.yy_font = APP_TYPE == 3 ? [UIFont systemFontOfSize:12] : [UIFont boldSystemFontOfSize:10];
            mutAttributeString.yy_color = APP_TYPE == 3 ? OSSVThemesColors.col_9F5123 : OSSVThemesColors.col_B62B21;
            if (APP_TYPE == 3) {
                
                YYTextBorder *bg = [YYTextBorder borderWithFillColor:OSSVThemesColors.stlWhiteColor cornerRadius:0];
                bg.strokeWidth = 0.2; //边框线宽
                bg.strokeColor = OSSVThemesColors.col_9F5123;
                bg.lineStyle = YYTextLineStyleSingle;
                bg.insets = UIEdgeInsetsMake(-2, -4, -2, -2);
                mutAttributeString.yy_textBackgroundBorder = bg;

            } else {
                YYTextBorder *bg = [YYTextBorder borderWithFillColor:[UIColor colorWithHexString:@"#fbe9e9"] cornerRadius:0];
                bg.insets = UIEdgeInsetsMake(-2, -4, -2, -4);
                mutAttributeString.yy_textBackgroundBorder = bg;

            }
        }
        self.detailContent = [mutAttributeString copy];
        
    }else if ([_dataSourceModel isKindOfClass:[OSSVCartWareHouseModel class]]){
        //仓库头（下单页，商品信息头）
        self.cellType = ArrowCellTypeDetail;
        OSSVCartWareHouseModel *wareHouse = (OSSVCartWareHouseModel *)_dataSourceModel;
        if ([wareHouse.goodsList count]) {
            OSSVCartGoodsModel *goodsModel = wareHouse.goodsList[0];
            self.titleContent = goodsModel.warehouseName;
            NSString *itemsString =  @"";
            NSString *noShipItemsString =  @"";

            __block NSInteger noShipCount = 0;
            __block NSInteger hadShipCount = 0;
            [wareHouse.goodsList enumerateObjectsUsingBlock:^(OSSVCartGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.shield_status integerValue] == 1) {
                    noShipCount += obj.goodsNumber;
                } else {
                    hadShipCount += obj.goodsNumber;
                }
            }];
            
            if (hadShipCount > 1) {
                itemsString = [NSString stringWithFormat:@"%ld %@", (long)hadShipCount, STLLocalizedString_(@"checkOutItems", nil)];
            } else {
                itemsString = [NSString stringWithFormat:@"%ld %@", (long)hadShipCount, STLLocalizedString_(@"checkOutItem", nil)];
            }
            
            noShipItemsString = [NSString stringWithFormat:STLLocalizedString_(@"XXX_items_no_shipped", nil),[NSString stringWithFormat:@"%ld",(long)noShipCount]];
            self.detailContent = [[NSAttributedString alloc] initWithString:itemsString attributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_0D0D0D,NSFontAttributeName:[UIFont systemFontOfSize:12]}];
            
            if (noShipCount > 0) {
                self.subTip = [[NSAttributedString alloc] initWithString:noShipItemsString attributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_B62B21}];
            } else {
                self.subTip = nil;
            }
            

        }else{
            self.titleContent = @"";
//            NSString *itemsString = [NSString stringWithFormat:@"%@", STLLocalizedString_(@"checkOutItems", nil)];
            self.detailContent = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_666666}];
            self.subTip = nil;
        }
    }else{
        
        self.cellType = ArrowCellTypeNormal;
        self.titleContent = @"没找到类型";
    }
}

@end
