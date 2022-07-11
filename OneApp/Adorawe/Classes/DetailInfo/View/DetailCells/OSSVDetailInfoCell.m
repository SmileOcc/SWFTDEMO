//
//  OSSVDetailInfoCell.m
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailInfoCell.h"
#import "UIView+WhenTappedBlocks.h"
#import "OSSVAccountsManager.h"
#import "Adorawe-Swift.h"

@interface OSSVDetailInfoCell ()
<
OSSVDetailsHeaderInforViewDelegate
>
{
    double _passTime;
}

@end

@implementation OSSVDetailInfoCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self.bgView addSubview:self.activityBgImgView];
        [self.bgView addSubview:self.activityView];
        [self.bgView addSubview:self.goodsInforView];
        [self.bgView addSubview:self.colorSizeView];
        
        [self.activityView addSubview:self.newPersonView];
        [self.activityView addSubview:self.normalActivityView];
        [self.activityView addSubview:self.flashActivityView];
        
        
        [self.normalActivityView addSubview:self.activityWaterMarkPriceL];
        [self.flashActivityView addSubview:self.flashMarketPriceLabel];
        [self.flashActivityView addSubview:self.flashStateLabel];
        [self.flashActivityView addSubview:self.flastScitviytStateView];
        [self.flashActivityView addSubview:self.flashImageArrow];
        [self.flashActivityView addSubview:self.flashShopPriceLabel];
        [self.flashActivityView addSubview:self.flashBuyTipLabel];
        [self.flashActivityView addSubview:self.timeLabel];
        [self.flashActivityView addSubview:self.millisecond];
        
        [self.newPersonView addSubview:self.personBackgroundImage];
        [self.newPersonView addSubview:self.personleftImage];
        [self.newPersonView addSubview:self.personLab];
        [self.newPersonView addSubview:self.personRightImage];
        [self.newPersonView addSubview:self.personTapBtn];
    
        [self.activityBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            if (APP_TYPE == 3) {
                make.top.mas_equalTo(self.bgView.mas_top).offset(12);
                make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
                make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
            }else{
                make.top.mas_equalTo(self.bgView.mas_top);
                make.leading.trailing.mas_equalTo(self.bgView);
            }
            make.height.mas_equalTo(54);
        }];
        
        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.top.mas_equalTo(self.bgView.mas_top).offset(12);
                make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
                make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
            }else{
                make.top.mas_equalTo(self.bgView.mas_top);
                make.leading.trailing.mas_equalTo(self.bgView);
            }
           
            make.height.mas_equalTo(0);
        }];
        
        [self.newPersonView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(self.activityView);
            make.leading.trailing.top.mas_equalTo(self.activityView);
            make.bottom.mas_equalTo(self.activityView.mas_bottom).offset(8);
        }];
        
        [self.normalActivityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.activityView);
        }];
        
        [self.flashActivityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.activityView);
        }];
        
        ///////// 水印
        
        [self.activityWaterMarkPriceL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.normalActivityView.mas_leading).offset(14);
            make.bottom.mas_equalTo(self.normalActivityView.mas_bottom).offset(-6);
        }];
        
        /////////闪购
        [self.flashStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.flashActivityView.mas_leading).offset(14);
            make.top.mas_equalTo(self.flashActivityView.mas_top).offset(7);
        }];
        
        [self.flashMarketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.flashActivityView.mas_leading).offset(14);
            make.bottom.mas_equalTo(self.flashActivityView.mas_centerY).offset(-3);
        }];
        
        [self.flashShopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.flashStateLabel.mas_leading);
            make.top.mas_equalTo(self.flashMarketPriceLabel.mas_bottom).offset(2);;
        }];
        
        [self.flashImageArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.flashActivityView.mas_trailing).offset(-14);
            make.centerY.mas_equalTo(self.flashActivityView.mas_centerY).offset(-8);
        }];
        
        [self.flashBuyTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.flashActivityView.mas_leading).offset(14);
            make.bottom.mas_equalTo(self.flashActivityView.mas_bottom).offset(-8);
        }];
        
        [self.millisecond mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.flashImageArrow.mas_trailing);
            make.width.height.equalTo(@14);
            make.bottom.mas_equalTo(self.flashActivityView.mas_bottom).offset(-7);
        }];

        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.millisecond.mas_leading).offset(-2);
            make.centerY.mas_equalTo(self.millisecond.mas_centerY);
        }];
        
        [self.flastScitviytStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.flashMarketPriceLabel.mas_trailing).offset(2);
            make.centerY.mas_equalTo(self.flashMarketPriceLabel.mas_centerY);
            make.height.mas_equalTo(14);
        }];
        
        // 新人页
        [self.personBackgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        [self.personleftImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.newPersonView.mas_leading).offset(14);
            make.centerY.mas_equalTo(self.newPersonView.mas_centerY).offset(-4);
            make.width.height.mas_equalTo(0);
        }];
        [self.personRightImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.newPersonView.mas_trailing).offset(-14);
            make.centerY.mas_equalTo(self.newPersonView.mas_centerY).offset(-4);
            make.width.height.mas_equalTo(0);
        }];
        
        [self.personLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.personRightImage.mas_leading).offset(-12);
            make.centerY.mas_equalTo(self.newPersonView.mas_centerY).offset(-4);
            make.leading.mas_equalTo(self.personleftImage.mas_trailing).offset(4);
        }];
        
        [self.personTapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        //头部商品信息
        [self.goodsInforView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.activityView.mas_bottom);
            make.leading.trailing.mas_equalTo(self.bgView);
            make.height.mas_equalTo([OSSVDetailsHeaderInforView heightGoodsInforView:nil reviewInfo:nil]);
        }];
        
//        if (APP_TYPE == 3) {
//            //属性暴露
//            [self.colorSizeViewVIV mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(self.goodsInforView.mas_bottom);
//                make.leading.trailing.mas_equalTo(self.bgView);
//                make.height.mas_equalTo(0);
//            }];
//        }else{
            //属性暴露
            [self.colorSizeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.goodsInforView.mas_bottom);
                make.leading.trailing.mas_equalTo(self.bgView);
                make.height.mas_equalTo(0);
            }];
//        }
        
        
        
    }
    return self;
}

+ (CGFloat)fetchSizeCellHeight:(OSSVDetailsListModel *)detailModel reviewModel:(OSSVReviewsModel *)reviewModel
{
//    OSSVDetailInfoCell *sizeCell = [[OSSVDetailInfoCell alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    [sizeCell updateDetailInfoModel:cellTypeModel recommend:YES];
//
//    [sizeCell layoutIfNeeded];
//    CGFloat calculateHeight = sizeCell.collectionView.contentSize.height;
    
    OSSVDetailsBaseInfoModel *goodsInforModel = detailModel.goodsBaseInfo;
    CGFloat activityH = 0;
    if (goodsInforModel && ([goodsInforModel isShowGoodDetailFlash] || goodsInforModel.goods_watermark.allKeys)) {
        activityH = 48;
    }else{
        // 是否显示新人礼
        if([OSSVDetailInfoCell isShowNewPersonView] && !(![OSSVNSStringTool isEmptyString:STLToString(goodsInforModel.specialId)] && [goodsInforModel.shop_price integerValue] == 0 )){
            //显示新人礼
            activityH = 34;
        }
    }

    CGFloat inforHeight = [OSSVDetailsHeaderInforView heightGoodsInforView:goodsInforModel reviewInfo:reviewModel];
    
    CGFloat colorSizeHeight = 174;
    if (APP_TYPE == 3) {
        colorSizeHeight = 189;
    }
    if (!goodsInforModel.isHasSizeItem || !goodsInforModel.isHasColorItem) {
        colorSizeHeight = 102;
        if (APP_TYPE == 3) {
            colorSizeHeight = 82;
            if (goodsInforModel.isHasColorItem) {
                colorSizeHeight = 104;
            }
        }
    }
    
    if (!goodsInforModel.isHasSizeItem && !goodsInforModel.isHasColorItem) {
        colorSizeHeight = 0;
    }

    if (goodsInforModel.GoodsSpecs.firstObject.isSelectSize && goodsInforModel.size_info.count > 0) {
        CGFloat height = [OSSVDetaailheaderColorSizeView getTipViewHeightWith:goodsInforModel];
        if (height > 0) {
            if (APP_TYPE == 3) {
                colorSizeHeight += height + 24;
            }else{
                colorSizeHeight += height + 8;
            }
        }
        
    }
    
    return inforHeight + activityH + colorSizeHeight;
}

- (void)updateDetailInfoModel:(OSSVDetailsListModel *)model recommend:(BOOL)hasRecommend{
    
    self.headerReviewModel = model.reviewsModel;
    self.hasRecommend = NO;
    self.model = model.goodsBaseInfo;
    
    OSSVDetailsBaseInfoModel *goodsInforModel = model.goodsBaseInfo;

    self.flashMarketPriceLabel.text = STLToString(goodsInforModel.market_price_converted);
    self.flashShopPriceLabel.text = STLToString(goodsInforModel.shop_price_converted);
    
    CGFloat activityH = 0;
    self.activityView.hidden = YES;
    self.newPersonView.hidden = YES;
    self.activityBgImgView.hidden = YES;
    self.flashActivityView.hidden = YES;
    self.normalActivityView.hidden = YES;
    self.flashStateLabel.hidden = YES;
    self.flashShopPriceLabel.hidden = YES;
    self.flashMarketPriceLabel.hidden = YES;
    self.flastScitviytStateView.hidden = YES;
    self.flashImageArrow.hidden = YES;
    self.flashBuyTipLabel.hidden = YES;
    
    for (OSSVSpecsModel *specModel in goodsInforModel.GoodsSpecs) {
        if ([specModel.spec_type integerValue] == 2) {
            goodsInforModel.isHasSizeItem = YES;
            break;
        }
    }
    
    // 折扣价
    NSString *discountStr = @"";
    
    if ([OSSVDetailInfoCell isShowNewPersonView] && !(![OSSVNSStringTool isEmptyString:STLToString(goodsInforModel.specialId)] && [goodsInforModel.shop_price integerValue] == 0 )) {
        activityH = 34;
        self.activityView.hidden = NO;
        self.newPersonView.hidden = NO;
        NSDictionary *goodsAdvDic = [OSSVAccountsManager sharedManager].goodsDetailBanner;
        NSDictionary *info = [goodsAdvDic objectForKey:@"info"];
        self.newPersonView.backgroundColor = [UIColor colorWithHexString:[info objectForKey:@"bg_color"]];
        [self.personBackgroundImage yy_setImageWithURL:[NSURL URLWithString:[info objectForKey:@"bg_img"]] placeholder:nil];
        [self.personleftImage yy_setImageWithURL:[NSURL URLWithString:[info objectForKey:@"fist_icon"]] placeholder:nil];
        [self.personRightImage yy_setImageWithURL:[NSURL URLWithString:[info objectForKey:@"end_icon"]] placeholder:nil];
        self.personLab.text = STLToString([info objectForKey:@"text"]);
        self.personLab.textColor = [UIColor colorWithHexString:[info objectForKey:@"text_color"]];
        
        if (!self.personleftImage.yy_imageURL || [OSSVNSStringTool isEmptyString: STLToString([info objectForKey:@"fist_icon"])]) {
            [self.personLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.personleftImage.mas_trailing);
            }];
            [self.personleftImage mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(0);
            }];
        }else{
            [self.personLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.personleftImage.mas_trailing).offset(4);
            }];
            [self.personleftImage mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(12);
            }];
        }
        
        if (!self.personRightImage.yy_imageURL || [OSSVNSStringTool isEmptyString: STLToString([info objectForKey:@"end_icon"])]) {
            [self.personLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.personRightImage.mas_leading);
            }];
            [self.personRightImage mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(0);
            }];
        }else{
            [self.personLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.personRightImage.mas_leading).offset(-12);
            }];
            [self.personRightImage mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(12);
            }];
        }
    }
    
    //根据活动价格来调整 pageLabel视图的位置--------商品活动水印根据数据来赋值和显示
    if (goodsInforModel.goods_watermark.allKeys) {
        activityH = 48;
        self.activityView.hidden = NO;
        self.activityBgImgView.hidden = NO;
        self.normalActivityView.hidden = NO;
        [self.activityBgImgView yy_setImageWithURL:[NSURL URLWithString:STLToString([goodsInforModel.goods_watermark objectForKey:@"mark_img"])] placeholder:nil];
        //mark_price
        self.activityWaterMarkPriceL.text = STLToString([goodsInforModel.goods_watermark objectForKey:@"mark_price_converted"]);
        self.newPersonView.hidden = YES;
    }
    
    // 0 > 闪购 > 满减
    if (goodsInforModel && [goodsInforModel isShowGoodDetailFlash]) {
        
        activityH = 48;
        self.activityView.hidden = NO;
        self.normalActivityView.hidden = YES;
        self.flashActivityView.hidden = NO;
        self.activityBgImgView.hidden = NO;
        self.flashImageArrow.hidden = NO;
        self.newPersonView.hidden = YES;
        NSString *labelStr = STLToString(goodsInforModel.flash_sale.label);
        self.labelStr = STLToString(labelStr);
        
        self.channelId = goodsInforModel.flash_sale.channel_id;
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        
        //活动状态  0未开始  1进行中  2已结束
        NSUInteger flashStatus = [goodsInforModel.flash_sale.active_status intValue];
        switch (flashStatus) {
            case 0:{

                self.flashStateLabel.hidden = NO;
                self.flashShopPriceLabel.hidden = NO;
                self.flashImageArrow.image =  [UIImage imageNamed: [OSSVSystemsConfigsUtils isRightToLeftShow] ? @"flash_tip_ar" : @"flash_tip_en"];
                self.activityBgImgView.image = [UIImage imageNamed: [OSSVSystemsConfigsUtils isRightToLeftShow] ? @"flash_pre_bgar" : @"flash_pre_bgen"];
                self.flashStateLabel.text = STLLocalizedString_(@"salePrice", nil);
                self.flashShopPriceLabel.text = STLToString(goodsInforModel.flash_sale.active_price_converted);
                
                self.timeLabel.textColor = [OSSVThemesColors stlWhiteColor];
                self.millisecond.backgroundColor = [OSSVThemesColors stlWhiteColor];
                self.millisecond.textColor = [OSSVThemesColors col_FF9318];
                
                [self.millisecond mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.trailing.equalTo(self.flashImageArrow.mas_trailing);
                    make.width.height.equalTo(@14);
                    make.bottom.mas_equalTo(self.flashActivityView.mas_bottom).offset(-7);
                }];

                [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.trailing.equalTo(self.millisecond.mas_leading).offset(-2);
                    make.centerY.mas_equalTo(self.millisecond.mas_centerY);
                }];
                
                [self.flashImageArrow mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.flashActivityView.mas_centerY).offset(-8);
                }];
                
//                // 由于有缓存问题 所以采用自己算 1.4.4
//                double current = [[self exchangTimeStrapWithDate:[NSDate date]] doubleValue];
//                double start = goodsInforModel.flash_sale.flash_start_time;
                
//                double endTime = fabs(start - current);
                
                double endTime = [STLToString(goodsInforModel.flash_sale.expire_time) doubleValue];
                
                if (endTime > 0) {
                    //将日期转换成时间戳
                    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue]*1000 +endTime*1000;
                    self.timeInterval = timeSp;

                }
            }
                break;
            case 1: {
                
                
                if ([goodsInforModel.flash_sale.is_can_buy isEqualToString:@"1"]) {
                    //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
                    discountStr = goodsInforModel.flash_sale.active_discount;
                    self.flastScitviytStateView.hidden = NO;
                    self.flashShopPriceLabel.hidden = NO;
                    self.flashMarketPriceLabel.hidden = NO;
                    
                    self.flashShopPriceLabel.text = STLToString(goodsInforModel.flash_sale.active_price_converted);
                    [self.flastScitviytStateView updateState:STLActivityStyleNormal discount:discountStr];
                    self.flastScitviytStateView.activityNormalView.backgroundColor = [OSSVThemesColors stlWhiteColor];
                    self.flastScitviytStateView.activityNormalView.discountLabel.textColor = [OSSVThemesColors col_FF9318];
                    self.flashImageArrow.image = [UIImage imageNamed: [OSSVSystemsConfigsUtils isRightToLeftShow] ? @"flash_tip_ar" : @"flash_tip_en"];
                    self.activityBgImgView.image = [UIImage imageNamed: [OSSVSystemsConfigsUtils isRightToLeftShow] ? @"flash_bgar" : @"flash_bgen"];

                    self.timeLabel.textColor = [OSSVThemesColors stlWhiteColor];
                    self.millisecond.backgroundColor = [OSSVThemesColors stlWhiteColor];
                    self.millisecond.textColor = [OSSVThemesColors col_FF9318];
                    
                    [self.millisecond mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.trailing.equalTo(self.flashImageArrow.mas_trailing);
                        make.width.height.equalTo(@14);
                        make.bottom.mas_equalTo(self.flashActivityView.mas_bottom).offset(-7);
                    }];

                    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.trailing.equalTo(self.millisecond.mas_leading).offset(-2);
                        make.centerY.mas_equalTo(self.millisecond.mas_centerY);
                    }];
                    
                    [self.flashImageArrow mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.centerY.mas_equalTo(self.flashActivityView.mas_centerY).offset(-8);
                    }];
                    
                } else {
                    //sold_out 1 卖光了、限购了
                    self.timeLabel.textColor = [OSSVThemesColors col_6C6C6C];
                    self.millisecond.backgroundColor = [OSSVThemesColors col_6C6C6C];
                    self.millisecond.textColor = [OSSVThemesColors stlWhiteColor];
                    
                    UIImage *arrowImage = [UIImage imageNamed: [OSSVSystemsConfigsUtils isRightToLeftShow] ? @"flash_tip_ar" : @"flash_tip_en"];
                    self.flashImageArrow.image = [arrowImage imageWithColor:[OSSVThemesColors col_6C6C6C]];
                    self.flashBuyTipLabel.text = STLToString(goodsInforModel.flash_sale.buy_notice);
                    self.flashBuyTipLabel.hidden = NO;
                    self.activityBgImgView.image = [UIImage stl_createImageWithColor:[OSSVThemesColors col_FFFAEA]];

                    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.mas_equalTo(self.flashActivityView.mas_leading).offset(14);
                        make.top.mas_equalTo(self.flashActivityView.mas_top).offset(8);
                    }];
                    
                    [self.millisecond mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.mas_equalTo(self.timeLabel.mas_trailing).offset(2);
                        make.width.height.equalTo(@14);
                        make.centerY.mas_equalTo(self.timeLabel.mas_centerY);
                    }];
                    
                    [self.flashImageArrow mas_updateConstraints:^(MASConstraintMaker *make) {
                        
                        if (APP_TYPE == 3) {
                            make.centerY.mas_equalTo(self.flashActivityView.mas_centerY).offset(-8);
                        }else{
                            make.centerY.mas_equalTo(self.flashActivityView.mas_centerY);
                        }
                    }];
                   
                }
                
                // 由于有缓存问题 所以采用自己算 1.4.4
                double current = [[self exchangTimeStrapWithDate:[NSDate date]] doubleValue];
                double end = goodsInforModel.flash_sale.flash_end_time;
                
                double endTime = fabs(end - current);// 时间戳是毫秒
                
//                double endTime = [STLToString(goodsInforModel.flash_sale.expire_time) doubleValue];
                if (endTime > 0) {
                    //将日期转换成时间戳
                    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue]*1000 +endTime*1000;
                    self.timeInterval = timeSp;

                }
            }
                break;
            default:
                
                break;
        }
    }
    
    [self.activityView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(activityH);
    }];
    
    // 商品信息
    CGFloat inforHeight = [OSSVDetailsHeaderInforView heightGoodsInforView:_model reviewInfo:self.headerReviewModel];
    [self.goodsInforView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(inforHeight);
    }];
    
    [self.goodsInforView updateHeaderGoodsInfor:_model reviewInfo:self.headerReviewModel];
    

    CGFloat sizeColorHeight = 174;
    if (APP_TYPE == 3) {
        sizeColorHeight = 189;
    }
    
    for (OSSVSpecsModel *specModel in goodsInforModel.GoodsSpecs) {
        if ([specModel.spec_type integerValue] == 2 && specModel.brothers.count > 0) {
            goodsInforModel.isHasSizeItem = YES;
        }
        if ([specModel.spec_type integerValue] == 1 && specModel.brothers.count > 0) {
            goodsInforModel.isHasColorItem = YES;
        }
    }
    if (!goodsInforModel.isHasSizeItem || !goodsInforModel.isHasColorItem) {
        sizeColorHeight = 102;
        if (APP_TYPE == 3) {
            sizeColorHeight = 82;
            if (goodsInforModel.isHasColorItem) {
                sizeColorHeight = 104;
            }
        }
    }
    
    if (!goodsInforModel.isHasSizeItem && !goodsInforModel.isHasColorItem) {
        sizeColorHeight = 0;
    }

    
    
    if (goodsInforModel.GoodsSpecs.firstObject.isSelectSize && goodsInforModel.size_info.count > 0) {
        CGFloat height = [OSSVDetaailheaderColorSizeView getTipViewHeightWith:goodsInforModel];
        if (height > 0) {
           
            if (APP_TYPE == 3) {
                sizeColorHeight += height + 24;
            }else{
                sizeColorHeight += height + 8;
            }
        }
    }

    [self.colorSizeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(sizeColorHeight);
    }];
    
    [self.colorSizeView layoutIfNeeded];
    [self.colorSizeView setBaseModel:goodsInforModel];
    
    
    
    ///
    if (APP_TYPE == 3) {
        self.flastScitviytStateView.hidden = YES;
    }


}
#pragma mark - OSSVDetailsHeaderInforViewDelegate

- (void)detailsHeaderInforView:(OSSVDetailsHeaderInforView *)goodsInforView cointTip:(BOOL)flag {
    if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:coinsTip:)]) {
        [self.stlDelegate OSSVDetialCell:self coinsTip:YES];
    }
}
- (void)detailsHeaderInforView:(OSSVDetailsHeaderInforView *)goodsInforView review:(BOOL)flag {
    
    if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:reiveMore:)]) {
        [self.stlDelegate OSSVDetialCell:self reiveMore:YES];
    }
}

- (void)detailsHeaderInforView:(OSSVDetailsHeaderInforView *)goodsInforView showMoreTitle:(BOOL)flag {
    if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:titleShowAll:)]) {
        [self.stlDelegate OSSVDetialCell:self titleShowAll:flag];
    }
}

#pragma mark -- banner 点击
- (void)personTapAction{
    NSDictionary *goodsAdvDic = [OSSVAccountsManager sharedManager].goodsDetailBanner;
    if (STLJudgeNSDictionary(goodsAdvDic)) {
        OSSVAdvsEventsModel *evntModel = [OSSVAdvsEventsModel yy_modelWithDictionary:goodsAdvDic];
        evntModel.actionType = [[goodsAdvDic objectForKey:@"page_type"] integerValue];
        [OSSVAdvsEventsManager advEventTarget:[OSSVAdvsEventsManager gainTopViewController] withEventModel:evntModel];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kGoodsDetailDisplayBanner];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [GATools logGoodsActivityActionWithEventName:@"promotion_entrance"
                                              action:[NSString stringWithFormat:@"Promotion_%@",evntModel.name]
                                         screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.model.goodsTitle)]];
    }
}



#pragma Mark - setter
- (OSSVDetailsHeaderInforView *)goodsInforView {
    if (!_goodsInforView) {
        _goodsInforView = [[OSSVDetailsHeaderInforView alloc] initWithFrame:CGRectZero];
        _goodsInforView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _goodsInforView.delegate = self;
        if (APP_TYPE == 3) {
            
        } else {        
            _goodsInforView.layer.cornerRadius = 6;
            _goodsInforView.layer.masksToBounds = YES;
        }
    }
    return _goodsInforView;
}

- (OSSVDetaailheaderColorSizeView *)colorSizeView {
    if (!_colorSizeView) {
        _colorSizeView = [[OSSVDetaailheaderColorSizeView alloc] initWithFrame:CGRectZero];
        _colorSizeView.backgroundColor = [UIColor clearColor];
    }
    return _colorSizeView;
}

- (UIView *)activityView {
    if (!_activityView) {
        _activityView = [[UIView alloc] initWithFrame:CGRectZero];
        _activityView.backgroundColor = [UIColor clearColor];
        _activityView.hidden = YES;
    }
    return _activityView;
}

- (UIView *)newPersonView{
    if (!_newPersonView) {
        _newPersonView = [[UIView alloc] initWithFrame:CGRectZero];
        _newPersonView.backgroundColor = [UIColor clearColor];
    }
    return _newPersonView;
}

- (UIView *)normalActivityView {
    if (!_normalActivityView) {
        _normalActivityView = [[UIView alloc] initWithFrame:CGRectZero];
        _normalActivityView.backgroundColor = [UIColor clearColor];
    }
    return _normalActivityView;
}

- (UIView *)flashActivityView {
    if (!_flashActivityView) {
        _flashActivityView = [[UIView alloc] initWithFrame:CGRectZero];
        _flashActivityView.backgroundColor = [UIColor clearColor];
        @weakify(self)
        [_flashActivityView whenTapped:^{
            @strongify(self)
            if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:activityFlash:)]) {
                [self.stlDelegate OSSVDetialCell:self activityFlash:STLToString(self.model.flash_sale.channel_id)];
            }
        }];
    }
    return _flashActivityView;
}
//活动水印、闪购背景
- (YYAnimatedImageView*)activityBgImgView {
    if (!_activityBgImgView) {
        _activityBgImgView = [YYAnimatedImageView new];
        _activityBgImgView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        _activityBgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _activityBgImgView.hidden = YES;
        _activityBgImgView.layer.masksToBounds = YES;
    }
    return _activityBgImgView;
}
//活动价格
- (UILabel *)activityWaterMarkPriceL {
    if (!_activityWaterMarkPriceL) {
        _activityWaterMarkPriceL = [UILabel new];
        _activityWaterMarkPriceL.textColor = [OSSVThemesColors stlWhiteColor];
        _activityWaterMarkPriceL.font = [UIFont boldSystemFontOfSize:18];
    }
    return _activityWaterMarkPriceL;
}


- (STLCLineLabel *)flashMarketPriceLabel {
    if (!_flashMarketPriceLabel) {
        _flashMarketPriceLabel = [[STLCLineLabel alloc] initWithFrame:CGRectZero];
        _flashMarketPriceLabel.font = [UIFont systemFontOfSize:10];
        _flashMarketPriceLabel.textColor = [OSSVThemesColors col_FFF0CC];
    }
    return _flashMarketPriceLabel;
}

- (UIImageView *)flashImageArrow {
    if (!_flashImageArrow) {
        _flashImageArrow = [[UIImageView alloc] init];
        _flashImageArrow.image = [UIImage imageNamed:@"flash_tip_en"];
    }
    return _flashImageArrow;
}

- (UILabel *)flashShopPriceLabel {
    if (!_flashShopPriceLabel) {
        _flashShopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _flashShopPriceLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _flashShopPriceLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _flashShopPriceLabel;
}

- (UILabel *)flashStateLabel {
    if (!_flashStateLabel) {
        _flashStateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _flashStateLabel.font = [UIFont systemFontOfSize:10];
        _flashStateLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _flashStateLabel.text = STLLocalizedString_(@"salePrice", nil);
        _flashStateLabel.hidden = YES;

    }
    return _flashStateLabel;
}

- (UILabel *)flashBuyTipLabel {
    if (!_flashBuyTipLabel) {
        _flashBuyTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _flashBuyTipLabel.font = [UIFont systemFontOfSize:12];
        _flashBuyTipLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _flashBuyTipLabel.hidden = YES;

    }
    return _flashBuyTipLabel;
}

- (OSSVDetailsHeaderActivityStateView *)flastScitviytStateView {
    if (!_flastScitviytStateView) {
        _flastScitviytStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
        _flastScitviytStateView.samllImageShow = NO;
        _flastScitviytStateView.fontSize = 10;
        _flastScitviytStateView.flashImageSize = 12;
        _flastScitviytStateView.activityNormalView.discountLabel.textColor = [OSSVThemesColors col_FF9318];
        _flastScitviytStateView.activityNormalView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _flastScitviytStateView.hidden = YES;
    }
    return _flastScitviytStateView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [OSSVThemesColors stlWhiteColor];
        [_timeLabel convertTextAlignmentWithARLanguage]; //自动适配阿语翻转
    }
    return _timeLabel;
}

- (UILabel *)millisecond {
    if (!_millisecond) {
        _millisecond = [UILabel new];
        _millisecond.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _millisecond.textColor = [OSSVThemesColors col_FF9318];
        _millisecond.font = [UIFont systemFontOfSize:12];
        _millisecond.textAlignment = NSTextAlignmentCenter;
    }
    return _millisecond;
}

- (YYAnimatedImageView *)personBackgroundImage{
    if (!_personBackgroundImage) {
        _personBackgroundImage = [YYAnimatedImageView new];
        _personBackgroundImage.backgroundColor = [OSSVThemesColors col_F5F5F5];
        _personBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        _personBackgroundImage.clipsToBounds = YES;
    }
    return _personBackgroundImage;
}

- (UILabel *)personLab{
    if (!_personLab) {
        _personLab = [UILabel new];
        _personLab.font = FontWithSize(12);
    }
    return _personLab;
}

- (UIButton *)personTapBtn{
    if (!_personTapBtn) {
        _personTapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_personTapBtn addTarget:self action:@selector(personTapAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _personTapBtn;
}

- (YYAnimatedImageView *)personleftImage{
    if (!_personleftImage) {
        _personleftImage = [YYAnimatedImageView new];
        _personleftImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _personleftImage;
}

- (YYAnimatedImageView *)personRightImage{
    if (!_personRightImage) {
        _personRightImage = [YYAnimatedImageView new];
        _personRightImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _personRightImage;
}


//得到未来某个日期的时间戳，与当前时间戳相比，得到两者的时间差，生成定时器
- (void)setTimeInterval:(double)timeInterval {
    _timeInterval = timeInterval ;
 
    if (_timer) {
        [_timer invalidate];
    }
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    dataFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss.SSS";
    
    //获取当前系统的时间，并用相应的格式转换
    [dataFormatter stringFromDate:[NSDate date]];
    NSString *currentDayStr = [dataFormatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [dataFormatter dateFromString:currentDayStr];
    
    //结束的时间，也用相同的格式去转换
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000.0];
    NSString *deadlineStr = [dataFormatter stringFromDate:date];
    NSDate *deadlineDate = [dataFormatter dateFromString:deadlineStr];
    
    _timeInterval = [deadlineDate timeIntervalSinceDate:currentDate]*1000;
    
    if (_timeInterval != 0) {
        //时间间隔是100毫秒，也就是0.1秒
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
    }else{
        
    }
}

// 每间隔100毫秒定时器触发执行该方法
- (void)timerAction {
    [self getTimeFromTimeInterval:_timeInterval] ;
        // 当时间间隔为0时干掉定时器
    if (_timeInterval-_passTime <= 0 ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_GoodsDetailReloadData object:nil];
        [_timer invalidate] ;
        _timer = nil ;
        return;
    }
}


// 通过时间间隔计算具体时间(小时,分,秒,毫秒)
- (void)getTimeFromTimeInterval : (double)timeInterval {

    //1s=1000毫秒
    _passTime += 100.f;//毫秒数从0-9，所以每次过去100毫秒
    //天
    NSString *days  = [NSString stringWithFormat:@"%ld", (NSInteger)((timeInterval - _passTime)/1000/60/60/24)];
    //小时数
    NSString *hours = [NSString stringWithFormat:@"%ld", (NSInteger)((timeInterval-_passTime)/1000/60/60)%24];
    //分钟数
    NSString *minute = [NSString stringWithFormat:@"%ld", (NSInteger)((timeInterval-_passTime)/1000/60)%60];
    //秒数
    NSString *second = [NSString stringWithFormat:@"%ld", ((NSInteger)(timeInterval-_passTime))/1000%60];
    //毫秒数
    CGFloat sss = ((NSInteger)((timeInterval - _passTime)))%1000/100;
    
    
    NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
    
    if (hours.integerValue < 0) {
        hours = [NSString stringWithFormat:@"00"];
    }
    
    if (minute.integerValue < 0) {
        minute = [NSString stringWithFormat:@"00"];
    }
    if (second.integerValue < 0) {
        second = [NSString stringWithFormat:@"00"];
    }
   
    self.millisecond.text = [NSString stringWithFormat:@"%@",ss];
    if (sss < 0) {
        self.millisecond.text = [NSString stringWithFormat:@"0"];
    }
    if (days.integerValue < 1) {
        days = 0;
        self.timeLabel.text = [NSString stringWithFormat:@"%@ %@h:%@m:%@s", self.labelStr,hours, minute, second];

    } else {
        self.timeLabel.text = [NSString stringWithFormat:@"%@ %@d:%@h:%@m:%@s", self.labelStr,days,hours, minute, second];

    }

    
}

+ (BOOL)isShowNewPersonView{
    //v 2.0.0 强制隐藏
    [OSSVAccountsManager sharedManager].goodsDetailBanner = @{};
    
    BOOL isSelectedCloseBanner = [[NSUserDefaults standardUserDefaults] boolForKey:kGoodsDetailDisplayBanner];
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppFirtOpenBehindInstall"];
    BOOL isFirstDay = [self judgeCurrentDayViewedWithDate:date];
    NSDictionary *goodsAdvDic = [OSSVAccountsManager sharedManager].goodsDetailBanner;
    
    NSString *bannerID = [goodsAdvDic objectForKey:@"id"];
    NSString *oldBannerId = [[NSUserDefaults standardUserDefaults] objectForKey:kGoodsDetailDisplayBannerID];
    
    if (STLJudgeNSDictionary(goodsAdvDic)) {
        OSSVAdvsEventsModel *evntModel = [OSSVAdvsEventsModel yy_modelWithDictionary:goodsAdvDic];
        if (STLJudgeNSDictionary(evntModel.info)) {
            NSInteger firtDayView = [[evntModel.info objectForKey:@"first_day_view"] integerValue];
            BOOL isShow = (firtDayView == 1 && !isSelectedCloseBanner && isFirstDay) || (firtDayView == 0 && !isSelectedCloseBanner);
            
            if (isShow || ![bannerID isEqualToString:oldBannerId]) {
                return YES;
            }else{
                return NO;
            }
        }
    }
    
    return NO;
}

// 判断当天与某一天是否相同的时间
+ (BOOL)judgeCurrentDayViewedWithDate:(NSDate *)defaultDate{
    return [[NSCalendar currentCalendar] isDate:defaultDate inSameDayAsDate:[NSDate date]];
}

// 将时间转为时间戳
- (NSString *)exchangTimeStrapWithDate:(NSDate *)date{
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return timeSp;
}
@end
