//
//  OSSVPayTotalTableViewCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVPayTotalTableViewCell.h"
#import "OSSVCartWareHouseModel.h"
#import "OSSVCartPaymentModel.h"
#import "YYText.h"

@interface OSSVPayTotalTableViewCell()
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@end

@implementation OSSVPayTotalTableViewCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [contentView addSubview:self.totalLabel];
        [contentView addSubview:self.arrowImageView];
        
        [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(contentView);
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading);
            make.height.mas_offset(40).priorityHigh();
        }];
        
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(contentView.mas_trailing).mas_offset(-CheckOutCellLeftPadding);
            make.centerY.mas_equalTo(contentView);
            make.width.height.mas_offset(24);
        }];
        
        [self addBottomLine:CellSeparatorStyle_LeftRightInset];
        
        [self addContentViewTap:@selector(showOrHiddenDetail)];
    }
    return self;
}

#pragma mark - target

-(void)showOrHiddenDetail{
    if (self.delegate && [self.delegate respondsToSelector:@selector(STLPrdTotalDidClick:)]) {
        STLPayTotalCellModel *model = self.model;
        model.isShowingDetail = !model.isShowingDetail;
        [self arrowAnimate:model.isShowingDetail];
        [self.delegate STLPrdTotalDidClick:self.model];
    }
}

-(void)arrowAnimate:(BOOL)open{
    if (open) {
        [UIView animateWithDuration:.3 animations:^{
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }else{
        [UIView animateWithDuration:.3 animations:^{
            self.arrowImageView.transform = CGAffineTransformIdentity;
        }];
    }
}

#pragma mark - setter and getter

-(void)setModel:(STLPayTotalCellModel *)model{
    _model = model;

    if (model.isHiddenCell) {
        self.arrowImageView.hidden = YES;
        self.totalLabel.hidden = YES;
        [self isHiddenBottomLine:YES];
        self.userInteractionEnabled = NO;
        [self.totalLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(1).priorityHigh();
        }];
    }else{
        self.arrowImageView.hidden = NO;
        self.totalLabel.hidden = NO;
        [self isHiddenBottomLine:NO];
        self.userInteractionEnabled = YES;
        [self.totalLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(40).priorityHigh();
        }];
        NSString *localizedTotal = STLLocalizedString_(@"SubTotal", nil);
        self.totalLabel.text = [NSString stringWithFormat:@"%@:%@%@",localizedTotal,
                                model.dataSourceModel.checkOutModel.currencyInfo.symbol,
                                model.totalPrice];
        [self arrowAnimate:model.isShowingDetail];
    }
}

-(UILabel *)totalLabel
{
    if (!_totalLabel) {
        _totalLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _totalLabel;
}

-(UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"arrow_down"];
            imageView;
        });
    }
    return _arrowImageView;
}

@end

#pragma mark - prd cell model

@implementation STLPayTotalCellModel
@synthesize indexPath = _indexPath;
@synthesize totalPrice = _totalPrice;
@synthesize showSeparatorStyle = _showSeparatorStyle;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dependModelList = [[NSMutableArray alloc] init];
        self.index = -1;
    }
    return self;
}

#pragma mark - protocol

+(NSString *)cellIdentifier
{
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier
{
    return NSStringFromClass(self.class);
}

#pragma mark - public method

-(void)handleTotalListDetailWithDataSoruce:(NSMutableArray *)dataSource
{
    if (self.indexPath.section > dataSource.count) {return;}
    NSMutableArray *dependTotalList = dataSource[self.indexPath.section];
    //////此处为什么是3 因为section开始会有一个 headCell, 一个商品cell, 还有一个totalcell
    NSRange removeRange = NSMakeRange(3, dependTotalList.count - 3);
    NSInteger length = removeRange.location + removeRange.length;
    if (length <= dependTotalList.count) {
        ///删除旧的小计详情
        [dependTotalList removeObjectsInRange:removeRange];
        ///加入新的小计详情，新的在 setDataSourceModel 方法中生成了
        [dependTotalList addObjectsFromArray:self.dependModelList];
    }
}

#pragma mark - setter and getter

-(void)setDataSourceModel:(OSSVCartOrderInfoViewModel *)dataSourceModel
{
    _dataSourceModel = dataSourceModel;
    
    NSString *formatStrminus = [OSSVSystemsConfigsUtils isRightToLeftShow] ? @"%@-" : @"-%@";
    NSString *formatStrAdd = [OSSVSystemsConfigsUtils isRightToLeftShow] ? @"%@+" : @"+%@";
    
    [self.dependModelList removeAllObjects];
    
    OSSVCartCheckModel *checkOutModel = dataSourceModel.checkOutModel;
    
    if (self.index == -1) {return;}
    
    OSSVCartWareHouseModel *wareHouseModel = checkOutModel.wareHouseList[self.index];
    if (wareHouseModel) {
        NSInteger startIdx = 3;         ///此处为什么是3 因为section开始会有一个 headCell, 一个商品cell, 还有一个totalcell
//        CGFloat totalPrice = 0.0;
        ///小计显示样式固定为
        /*
            Products Total
            Shipping Cost
            Shipping Insurance
            COD Cost
            Save
            Coupon
            Y Points
            COD Rounding
         */
        ///其中 Save Coupon Y Points COD Rounding 是高亮的
        OSSVTotalDetailCellModel *total = [[OSSVTotalDetailCellModel alloc] init];
        
        ///计算总价格
//        __block CGFloat priceValue = 0.0;
//        [wareHouseModel.goodsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            OSSVCartGoodsModel *model = obj;
//            priceValue += [ExchangeManager changeRateModel:dataSourceModel.checkOutModel.currencyInfo transforPrice:model.goodsPrice priceType:PriceType_ProductPrice].floatValue * model.goodsNumber;
//        }];
//        total.value = [[NSAttributedString alloc] initWithString:[ExchangeManager appenSymbol:dataSourceModel.checkOutModel.currencyInfo price:[NSString stringWithFormat:@"%.2f", priceValue]]
//                                                      attributes:[self attributesIsHighLight:NO]];
        total.type = TotalDetailTypeProductTotal;
        total.title = STLLocalizedString_(@"ProductsTotal", nil);
        total.value = [[NSAttributedString alloc] initWithString:STLToString(self.dataSourceModel.checkOutModel.fee_data.product_converted)
                                                      attributes:[self attributesIsHighLight:NO]];
        [self.dependModelList addObject:total];
        
        
//        totalPrice += priceValue;
        
        //////// v1.2.0 商品总额 满减 优惠券 支付优惠 运费 运费折扣
        
        //满减活动优惠金额
        if (wareHouseModel.activeSave && [self isZero:wareHouseModel.activeSave]) {
            OSSVTotalDetailCellModel *save = [[OSSVTotalDetailCellModel alloc] init];
            save.type = TotalDetailTypeSave;
            save.title = STLLocalizedString_(@"save", nil);
//            NSString *saveValue = [NSString stringWithFormat:@"%@", [ExchangeManager changeRateModel:dataSourceModel.checkOutModel.currencyInfo transforPrice:wareHouseModel.activeSave priceType:PriceType_Off]];
//            save.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"-%@",
//                                                                     [ExchangeManager appenSymbol:dataSourceModel.checkOutModel.currencyInfo price:saveValue]]
//                                                         attributes:[self attributesIsHighLight:YES]];
            
            save.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:formatStrminus,STLToString(self.dataSourceModel.checkOutModel.fee_data.active_save_converted)]
                                                         attributes:[self attributesIsHighLight:YES]];
            
            [self.dependModelList addObject:save];
            ///减去折扣价，后台返回的是商品原价
//            totalPrice -= saveValue.floatValue;
        }
        
        ///如果用户使用了coupon
        if (dataSourceModel.couponModel && [self isZero:wareHouseModel.couponSave]) {
            OSSVTotalDetailCellModel *coupon = [[OSSVTotalDetailCellModel alloc] init];
            coupon.type = TotalDetailTypeCoupon;
            coupon.title = STLLocalizedString_(@"checkOutCoupon", nil);
//            NSString *value = [ExchangeManager changeRateModel:dataSourceModel.checkOutModel.currencyInfo transforPrice:wareHouseModel.couponSave priceType:PriceType_Coupon];
//            coupon.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"-%@",
//                                                                       [ExchangeManager appenSymbol:dataSourceModel.checkOutModel.currencyInfo price:value]]
//                                                           attributes:[self attributesIsHighLight:YES]];
            
            coupon.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:formatStrminus,STLToString(self.dataSourceModel.checkOutModel.fee_data.coupon_save_converted)]
                                                           attributes:[self attributesIsHighLight:YES]];
            [self.dependModelList addObject:coupon];
//            totalPrice -= value.floatValue;
        }
        
        ///如果用户选择了ypoint
//        if (dataSourceModel.ypointModel && [self isZero:wareHouseModel.pointSave]) {
//            OSSVTotalDetailCellModel *ypoints = [[OSSVTotalDetailCellModel alloc] init];
//            ypoints.type = TotalDetailTypeYpoint;
//            ypoints.title = STLLocalizedString_(@"orderInfo_point", nil);
//
//            ///商品价格调整  后台功能暂时没有，还是APP换算
//            NSString *value = [ExchangeManager changeRateModel:dataSourceModel.checkOutModel.currencyInfo transforPrice:wareHouseModel.pointSave priceType:PriceType_Point];
//            ypoints.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"-%@",
//                                                                        [ExchangeManager appenSymbol:dataSourceModel.checkOutModel.currencyInfo price:value]]
//                                                            attributes:[self attributesIsHighLight:YES]];

//            ypoints.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"-%@",STLToString(self.dataSourceModel.checkOutModel.fee_data.point_save_converted)]
//                                                            attributes:[self attributesIsHighLight:YES]];
//            [self.dependModelList addObject:ypoints];
//            totalPrice -= value.floatValue;
//        }
        
        //用户使用了金币
//        if (dataSourceModel.checkOutModel.fee_data.coin_save_converted_symbol && dataSourceModel.checkOutModel.fee_data.coin.intValue > 0) {
        if (dataSourceModel.checkOutModel.fee_data.coin_save_converted_symbol && [dataSourceModel.checkOutModel.fee_data.coin_save floatValue] > 0) {
            OSSVTotalDetailCellModel *coinSave = [[OSSVTotalDetailCellModel alloc] init];
            coinSave.type = TotalDetailTypeCoinSave;
            coinSave.title = STLLocalizedString_(@"CoinsCost", nil);
            
            coinSave.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:formatStrminus,
                                                                         STLToString(self.dataSourceModel.checkOutModel.fee_data.coin_save_converted_symbol)]
                                                             attributes:[self attributesIsHighLight:YES]];
            
            [self.dependModelList addObject:coinSave];
        }
        
        ///COD cost 是否为0  并且选中了支付方式
        if (dataSourceModel.paymentModel.poundage && [self isZero:dataSourceModel.paymentModel.poundage] && dataSourceModel.paymentModel.isSelectedPayMent) {
            OSSVTotalDetailCellModel *codCost = [[OSSVTotalDetailCellModel alloc] init];
            
//            NSString *codCostValue = [ExchangeManager changeRateModel:dataSourceModel.checkOutModel.currencyInfo transforPrice:dataSourceModel.paymentModel.poundage priceType:PriceType_ShippingCost];
//            codCost.value = [[NSAttributedString alloc] initWithString:[ExchangeManager appenSymbol:dataSourceModel.checkOutModel.currencyInfo price:codCostValue]
//                                                            attributes:[self attributesIsHighLight:NO]];
            codCost.type = TotalDetailTypeCODCost;
            codCost.title = STLLocalizedString_(@"codCost", nil);
            CartCheckFreeDataModel *feeData = self.dataSourceModel.checkOutModel.fee_data;
            if (feeData.cod_regular_converted.length > 0 && feeData.cod_regular.floatValue > 0 && feeData.cod_regular.floatValue > feeData.cod.floatValue) {
                
                NSAttributedString *src = [[NSAttributedString alloc] initWithString:STLToString(feeData.cod_regular_converted)
                                                            attributes:[self attributesCenterLine]];
                NSAttributedString *activityStr = [[NSAttributedString alloc] initWithString:STLToString(feeData.cod_converted) attributes:[self attributesIsHighLight:true]];
                codCost.value = activityStr;
                codCost.centerLineValue = src;
            }else{
                NSAttributedString *activityStr = [[NSAttributedString alloc] initWithString:STLToString(feeData.cod_converted) attributes:[self attributesIsHighLight:false]];
                codCost.value = activityStr;
            }
            
          
            
            [self.dependModelList addObject:codCost];
//            totalPrice += codCostValue.floatValue;
        }
        
        //如果有支付折扣优惠金额
        if (wareHouseModel.disCountSave && [self isZero:wareHouseModel.disCountSave]) {
            OSSVTotalDetailCellModel *discountSave = [[OSSVTotalDetailCellModel alloc] init];
            discountSave.type = TotalDetailTypeDiscount;
            discountSave.title = STLLocalizedString_(@"disCountTitle", nil);
            
//            NSString *discountValue = [NSString stringWithFormat:@"%@", [ExchangeManager changeRateModel:dataSourceModel.checkOutModel.currencyInfo transforPrice:wareHouseModel.disCountSave priceType:PriceType_Off]];
//            discountSave.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"-%@",
//                                                                             [ExchangeManager appenSymbol:dataSourceModel.checkOutModel.currencyInfo price:discountValue]]
//                                                                 attributes:[self attributesIsHighLight:YES]];
            
            discountSave.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:formatStrminus,
                                                                             STLToString(self.dataSourceModel.checkOutModel.fee_data.pay_discount_save_converted)]
                                                                 attributes:[self attributesIsHighLight:YES]];
            
            [self.dependModelList addObject:discountSave];
//            totalPrice -= discountValue.floatValue;
        }
        
        ///如果用户勾选了物流保险 ----打开运费保险
        if ([dataSourceModel.shippingInsurance isEqualToString:@"1"]) {
            OSSVTotalDetailCellModel *shippingInsurance = [[OSSVTotalDetailCellModel alloc] init];
            
            ///商品价格调整  后台功能暂时没有，还是APP换算
//            NSString *insuranceValue = [ExchangeManager changeRateModel:dataSourceModel.checkOutModel.currencyInfo transforPrice:wareHouseModel.insurance priceType:PriceType_Insurance];
//            shippingInsurance.value = [[NSAttributedString alloc] initWithString:[ExchangeManager appenSymbol:dataSourceModel.checkOutModel.currencyInfo price:insuranceValue]
//                                                                      attributes:[self attributesIsHighLight:NO]];
            shippingInsurance.type = TotalDetailTypeShippingInsurance;
            shippingInsurance.title = STLLocalizedString_(@"shipInsurance", nil);
            shippingInsurance.value = [[NSAttributedString alloc] initWithString:STLToString(self.dataSourceModel.checkOutModel.fee_data.shipping_insurance_converted_origin)
                                                                      attributes:[self attributesIsHighLight:NO]];
            if (APP_TYPE == 3) {
                [self.dependModelList addObject:shippingInsurance];
            }
//            totalPrice += insuranceValue.floatValue;
        }
        
        //新增判断，在未选择支付方式情况下，不展示和计算运费
        if (dataSourceModel.paymentModel.isSelectedPayMent) {
            dataSourceModel.shippingModel.shippingFee = dataSourceModel.shippingModel.shippingFee == nil ? @"0" : dataSourceModel.shippingModel.shippingFee;
            
//            NSString *shippingFeeValue = [ExchangeManager changeRateModel:dataSourceModel.checkOutModel.currencyInfo transforPrice:dataSourceModel.shippingModel.shippingFee priceType:PriceType_ShippingCost];
//            shippingCost.value = [[NSAttributedString alloc] initWithString:[ExchangeManager appenSymbol:dataSourceModel.checkOutModel.currencyInfo price:shippingFeeValue]
//                                                                 attributes:[self attributesIsHighLight:NO]];
            
            OSSVTotalDetailCellModel *shippingCost = [[OSSVTotalDetailCellModel alloc] init];
            shippingCost.type = TotalDetailTypeShippingCost;
            shippingCost.title = STLLocalizedString_(@"shipCost", nil);
            CartCheckFreeDataModel *feeData = self.dataSourceModel.checkOutModel.fee_data;
            if (feeData.shipping_regular_converted.length > 0 && feeData.shipping_regular.floatValue > 0 && feeData.shipping.floatValue < feeData.shipping_regular.floatValue) {
                NSAttributedString *src = [[NSAttributedString alloc] initWithString:STLToString(feeData.shipping_regular_converted)
                                                            attributes:[self attributesCenterLine]];
                NSAttributedString *activityStr = [[NSAttributedString alloc] initWithString:STLToString(feeData.shipping_converted) attributes:[self attributesIsHighLight:true]];
                shippingCost.value = activityStr;
                shippingCost.centerLineValue = src;
                
            }else{
                NSAttributedString *activityStr = [[NSAttributedString alloc] initWithString:STLToString(feeData.shipping_converted) attributes:[self attributesIsHighLight:false]];
                shippingCost.value = activityStr;
            }
            
            [self.dependModelList addObject:shippingCost];
            
//            totalPrice += shippingFeeValue.floatValue;
        }
        
        
        ///是否向上向下取整
        BOOL isFractions = dataSourceModel.paymentModel.fractions_type.integerValue == 1 || dataSourceModel.paymentModel.fractions_type.integerValue == 2;
        
        ///是否COD
        __block BOOL isCodRounding = NO;
        
        if ([dataSourceModel.paymentModel.payCode isEqualToString:@"Cod"]) {
            isCodRounding = YES;
        }
        
        ///最终计算价格 X 货币汇率比例
//        CGFloat transPrice = totalPrice;
        if (isCodRounding && dataSourceModel.paymentModel.isSelectedPayMent) {  //新增判断，支付方式是否有选中
            if (dataSourceModel.paymentModel.fractions_type.integerValue == 1) {
                ///向上取整
                OSSVTotalDetailCellModel *codRounding = [[OSSVTotalDetailCellModel alloc] init];
                codRounding.type = TotalDetailTypeCODRounding;
                [self.dependModelList addObject:codRounding];

//                CGFloat ceilfPrice = ceilf(transPrice);
//                CGFloat codroundPrice = fabs(transPrice - ceilfPrice);
                codRounding.title = STLLocalizedString_(@"Air_cargo_insurance",nil);
                codRounding.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:formatStrAdd,STLToString(self.dataSourceModel.checkOutModel.fee_data.cod_discount_converted)]
                                                                    attributes:[self attributesIsHighLight:YES]];
//                totalPrice = ceilfPrice;
            }else if (dataSourceModel.paymentModel.fractions_type.integerValue == 2){
                ///向下取整
                OSSVTotalDetailCellModel *codRounding = [[OSSVTotalDetailCellModel alloc] init];
                codRounding.type = TotalDetailTypeCODRounding;
                [self.dependModelList addObject:codRounding];

//                CGFloat floorPrice = floor(transPrice);
//                CGFloat codroundPrice = fabs(floorPrice - transPrice);
                codRounding.title = STLLocalizedString_(@"COD_discount",nil);
                codRounding.value = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:formatStrminus,STLToString(self.dataSourceModel.checkOutModel.fee_data.cod_discount_converted)]
                                                                    attributes:[self attributesIsHighLight:YES]];
//                totalPrice = floorPrice;
            }else{
//                totalPrice = transPrice;
            }
        }else{
//            totalPrice = transPrice;
        }

//        ///当只有一个仓库的时候，还有是COD支付时，还要展示一个total cell
//        if (dataSourceModel.paymentModel.isSelectedPayMent && [dataSourceModel.checkOutModel.wareHouseList count] == 1 && isCodRounding && isFractions) {
//            OSSVTotalDetailCellModel *total = [[OSSVTotalDetailCellModel alloc] init];
//            total.type = TotalDetailTypeTotal;
//            total.title = STLLocalizedString_(@"total", nil);
////            NSString *value = [NSString stringWithFormat:@"%.2f", totalPrice];
////            total.value = [[NSAttributedString alloc] initWithString:[ExchangeManager appenSymbol:dataSourceModel.checkOutModel.currencyInfo price:value]
////                                                          attributes:[self attributesIsHighLight:YES]];
//            total.value = [[NSAttributedString alloc] initWithString:STLToString(self.dataSourceModel.checkOutModel.fee_data.cod_discount_before_converted)
//                                                          attributes:[self attributesIsHighLight:YES]];
//            
//            [self.dependModelList addObject:total];
//        }

        NSInteger totalIdx = self.dependModelList.count;
        self.detailRange = NSMakeRange(startIdx, totalIdx);
        
//        self.totalPrice = [NSString stringWithFormat:@"%.2f", totalPrice];
    }
}

-(NSDictionary *)attributesIsHighLight:(BOOL)highLight
{
    NSDictionary *attributes = nil;
    if (highLight) {
        attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : APP_TYPE == 3 ? OSSVThemesColors.col_9F5123 : OSSVThemesColors.col_B62B21};
    }else{
        attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
    }
    return attributes;
}

-(NSDictionary *)attributesCenterLine
{
    return @{NSFontAttributeName : [UIFont systemFontOfSize:10],
             NSForegroundColorAttributeName : OSSVThemesColors.col_6C6C6C,
             NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle),
    };
}

///为0返回NO 不为0返回YES
-(BOOL)isZero:(NSString *)value
{
    if (value.floatValue > 0) {
        return YES;
    }
    return NO;
    ///<从字符串匹配数字
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+\\.{1}\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
//    NSTextCheckingResult *result = [regex firstMatchInString:value options:NSMatchingReportCompletion range:NSMakeRange(0, value.length)];
//    if (result) {
//        NSString *number = [value substringWithRange:result.range];
//        if (number.floatValue > 0) {
//            return YES;
//        }
//        return NO;
//    }
//    return NO;
    
//    NSString *regexString = @"[1-9]";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
//    BOOL match = [predicate evaluateWithObject:value];
//    return match;
}

@end

