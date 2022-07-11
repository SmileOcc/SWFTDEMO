//
//  OSSVCategoryListsCCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryListsCCell.h"
#import "OSSVCategoriyDetailsGoodListsModel.h"
#import "STLCLineLabel.h"
#import "OSSVDetailsActivityFullReductionView.h"
//倒计时
#import "MZTimerLabel.h"
#import "OSSVGoodssPricesView.h"
#import "UIButton+STLCategory.h"

@interface OSSVCategoryListsCCell ()<MZTimerLabelDelegate>

@property (nonatomic, strong) YYAnimatedImageView   *contentImageView; // 内容图片
@property (nonatomic, strong) OSSVGoodssPricesView     *priceView; // 底部背景View
@property (nonatomic, strong) UIButton              *collecBtn; // 收藏按钮
//@property (nonatomic, strong) MZTimerLabel          *timeLabel;//倒计时
/////水印
@property (nonatomic, strong) YYAnimatedImageView   *activityTipImgView;
////折扣标 + 闪购标签
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;
@property (nonatomic,strong) UILabel *isNewLbl;
@end

#define COUNTDOWN_FORMAT 0

@implementation OSSVCategoryListsCCell

+ (OSSVCategoryListsCCell *)categoriesCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (void)dealloc {
    STLLog(@"-----dealloc");
//    if (_timeLabel && _timeLabel.superview) {//这里有内存泄漏，没释放
//        [_timeLabel removeFromSuperview];
//        _timeLabel = nil;
//    }
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _contentImageView = [[YYAnimatedImageView alloc] init];
        _contentImageView.userInteractionEnabled = YES;
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.clipsToBounds = YES;
        _contentImageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_contentImageView];
        [_contentImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.and.leading.and.trailing.mas_equalTo(@0);
        }];
        
        
        [self.contentView addSubview:self.activityStateView];

        if (APP_TYPE == 3) {
            [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.contentImageView.mas_leading).offset(6);
                make.top.mas_equalTo(self.contentImageView.mas_top).offset(6);
            }];
        } else {
            [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.contentImageView.mas_leading);
                make.top.mas_equalTo(self.contentImageView.mas_top);
            }];
        }
        
        
        _priceView = [[OSSVGoodssPricesView alloc] initWithFrame:CGRectZero isShowIcon:YES];
        _priceView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview: _priceView];
        [ _priceView mas_makeConstraints:^(MASConstraintMaker *make){
            make.bottom.and.leading.and.trailing.mas_equalTo(@0);
            make.height.mas_equalTo(@(kHomeCellBottomViewHeight));
            make.top.equalTo(_contentImageView.mas_bottom);
        }];
        

        _activityTipImgView = [YYAnimatedImageView new];
        _activityTipImgView.backgroundColor = [UIColor clearColor];
        [_contentImageView addSubview:_activityTipImgView];
        [_activityTipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(@0);
            make.bottom.equalTo(_contentImageView.mas_bottom);
            make.height.mas_equalTo(@(24*kScale_375));
        }];
        
        [self.contentView addSubview:self.collecBtn];
        [self.collecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentImageView.mas_bottom).offset(8);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-8);
        }];
        [self.collecBtn setEnlargeEdgeWithTop:8 right:8 bottom:10 left:10];
        
        [self.contentView addSubview:self.isNewLbl];
        
        CGSize size = [self.isNewLbl sizeThatFits:CGSizeMake(MAXFLOAT, 18)];
        if (APP_TYPE == 3) {
            [self.isNewLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView.mas_leading).offset(6);
                make.top.equalTo(self.contentView.mas_top).offset(6);
                make.height.equalTo(16);
                make.size.width.equalTo(size.width + 7);
            }];
        } else {
            [self.isNewLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.top.equalTo(self.contentView);
                make.height.equalTo(18);
                make.size.width.equalTo(size.width + 7);
            }];
        }
        

        
    }
    return self;
}


- (void)setModel:(OSSVCategoriyDetailsGoodListsModel *)model
{
    _model = model;
    [self.contentImageView yy_setImageWithURL:[NSURL URLWithString:model.goodsImageUrl]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                     progress:nil
                                    transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
//                                                    image = [image yy_imageByResizeToSize:CGSizeMake(kGoodsWidth, kGoodsWidth / model.goodsImageWidth * model.goodsImageHeight) contentMode:UIViewContentModeScaleAspectFit];
                                                    return image;
                                                }
                                   completion:nil];
    
    self.priceView.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
    
    [self.priceView price:STLToString(model.shop_price_converted)
                 originalPrice:STLToString(model.market_price_converted)
                   activityMsg:STLToString(model.tips_reduction)
                activityHeight:model.goodsListFullActitityHeight
                    title:STLToString(model.goodsTitle)];
    
    [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(model.goodsListPriceHeight);
    }];
    self.activityStateView.hidden = YES;
    
    if (APP_TYPE == 3) {
        self.priceView.originalPriceLabel.hidden = YES;
    }
    // 是否显示 折扣icon, 同时防止后台返回莫名其妙 cutOffRate 数据过来
    BOOL isDiscount = [model.show_discount_icon integerValue] && [model.cutOffRate integerValue] > 0 && [model.cutOffRate integerValue] < 100;
    if (isDiscount)
    {
        
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(model.cutOffRate)];
        if (APP_TYPE == 3) {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.priceView.originalPriceLabel.hidden = NO;

        } else {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
    }
    
    //////折扣标 闪购标
    BOOL isFlashSale = model.flash_sale && [model.flash_sale isOnlyFlashActivity];
    if (isFlashSale) {
        if (APP_TYPE == 3) {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.priceView.originalPriceLabel.hidden = NO;

        } else {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
        self.priceView.priceLabel.text = STLToString(model.flash_sale.active_price_converted);
        
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(model.flash_sale.active_discount)];
    }
    
    if (!isDiscount && !isFlashSale){
        self.isNewLbl.hidden = model.is_new != 1;
    }
    
    ///商品水印图片
    NSString *markImgUrlStr = STLToString(model.markImgUrl);
    if (markImgUrlStr.length) {
        self.activityTipImgView.hidden = NO;
        [self.activityTipImgView yy_setImageWithURL:[NSURL URLWithString:markImgUrlStr] placeholder:nil];
    }else {
        self.activityTipImgView.hidden = YES;
    }
    
    // 收藏
    if (_model.is_collect) {
        self.collecBtn.selected = YES;
    }else{
        self.collecBtn.selected = NO;
    }

//#if COUNTDOWN_FORMAT
//    if (model.isDailyDeal)
//    {
//        _timerView.hidden = NO;
//    }
//    else
//    {
//        _timerView.hidden = YES;
//    }
//#else
//    if (model.isDailyDeal)
//    {
//        _timeLabel.hidden = NO;
//        _timerView.hidden = NO;
//        [self.timeLabel setCountDownTime:model.leftTime];
//        [self.timeLabel start];
//    }
//    else
//    {
//        _timerView.hidden = YES;
//        _timeLabel.hidden = YES;
//    }
//#endif
}


+ (CGFloat)categoryListCCellRowHeightForListModel:(OSSVCategoriyDetailsGoodListsModel *)model {
    
    if (model.goods_img_w > 0) {
        
        CGFloat fullHeight = model.goodsListPriceHeight;
        
        //满减活动
        if (!(model.flash_sale && [model.flash_sale isOnlyFlashActivity]) && !model.hadHandlePriceHeight) {
            model.hadHandlePriceHeight = YES;
            CGFloat activityHeight = [OSSVGoodssPricesView activithHeight:model.tips_reduction contentWidth:kGoodsWidth];
            fullHeight = [OSSVGoodssPricesView contentHeight:activityHeight];
            model.goodsListPriceHeight = fullHeight;
            model.goodsListFullActitityHeight = activityHeight;
        }
        
        if (model.goods_img_w == 0 || model.goods_img_h == 0) {
            return kGoodsWidth * 4.0 / 3.0 + fullHeight;
        }
        
        return kGoodsWidth / model.goods_img_w * model.goods_img_h + fullHeight;
    }
    return 0.01;
}

+ (CGFloat)categoryListCCellRowHeightOneModel:(OSSVCategoriyDetailsGoodListsModel *)model twoModel:(OSSVCategoriyDetailsGoodListsModel *)twoModel{
    
    if (APP_TYPE == 3) {
        if (model.goods_img_w > 0) {
            
            CGFloat activityHeight = model.goodsListFullActitityHeight;
            CGFloat onefullHeight = model.goodsListPriceHeight;
            CGFloat oneMaxHeight = 0;
            //满减活动
            if (!(model.flash_sale && [model.flash_sale isOnlyFlashActivity]) && !model.hadHandlePriceHeight) {
                model.hadHandlePriceHeight = YES;
                activityHeight = [OSSVGoodssPricesView activithHeight:model.tips_reduction contentWidth:kGoodsWidth];
                onefullHeight = [OSSVGoodssPricesView contentHeight:activityHeight];
                model.goodsListPriceHeight = onefullHeight;
                model.goodsListFullActitityHeight = activityHeight;
            }
            
//            if (model.goods_img_w == 0 || model.goods_img_h == 0) {
                oneMaxHeight = kGoodsWidth + onefullHeight;
//            } else {
//                oneMaxHeight = kGoodsWidth / model.goods_img_w * model.goods_img_h + onefullHeight;
//            }
            
            CGFloat twofullHeight = 0;
            CGFloat twoMaxHeight = 0;
            if (twoModel) {
                twofullHeight = twoModel.goodsListPriceHeight;
                CGFloat twoActivityHeight = twoModel.goodsListFullActitityHeight;
                //满减活动
                if (!(twoModel.flash_sale && [twoModel.flash_sale isOnlyFlashActivity]) && !twoModel.hadHandlePriceHeight) {
                    twoModel.hadHandlePriceHeight = YES;
                    twoActivityHeight = [OSSVGoodssPricesView activithHeight:twoModel.tips_reduction contentWidth:kGoodsWidth];
                    twofullHeight = [OSSVGoodssPricesView contentHeight:twoActivityHeight];
                    twoModel.goodsListPriceHeight = twofullHeight;
                    twoModel.goodsListFullActitityHeight = twoActivityHeight;
                }
                
//                if (twoModel.goods_img_w == 0 || twoModel.goods_img_h == 0) {
                    twoMaxHeight = kGoodsWidth + twofullHeight;
//                } else {
//                    twoMaxHeight = kGoodsWidth / twoModel.goods_img_w * twoModel.goods_img_h + twofullHeight;
//                }
                
                if (twoMaxHeight > oneMaxHeight) {
                    model.goodsListPriceHeight = twofullHeight;
                    model.goodsListFullActitityHeight = twoActivityHeight;
                } else {
                    twoModel.goodsListPriceHeight = onefullHeight;
                    twoModel.goodsListFullActitityHeight = activityHeight;
                }
            }
            
            CGFloat maxFullHeight = MAX(oneMaxHeight, twoMaxHeight);
            return maxFullHeight;
        }
        return 0.01;
    }
    if (model.goods_img_w > 0) {
        
        CGFloat fullHeight = model.goodsListPriceHeight;
        
        //满减活动
        if (!(model.flash_sale && [model.flash_sale isOnlyFlashActivity]) && !model.hadHandlePriceHeight) {
            model.hadHandlePriceHeight = YES;
            CGFloat activityHeight = [OSSVGoodssPricesView activithHeight:model.tips_reduction contentWidth:kGoodsWidth];
            fullHeight = [OSSVGoodssPricesView contentHeight:activityHeight];
            model.goodsListPriceHeight = fullHeight;
            model.goodsListFullActitityHeight = activityHeight;
        }
        
        if (model.goods_img_w == 0 || model.goods_img_h == 0) {
            return kGoodsWidth * 4.0 / 3.0 + fullHeight;
        }
        
        return kGoodsWidth / model.goods_img_w * model.goods_img_h + fullHeight;
    }
    return 0.01;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.contentImageView yy_cancelCurrentImageRequest];
    self.contentImageView.image = nil;
    self.priceView.priceLabel.text = nil;
    self.priceView.originalPriceLabel.text = nil;
//    [self.timeLabel reset];
    self.isNewLbl.hidden = YES;

//    self.hourTimeView.flowTimeLeftLabel.text = nil;
//    self.hourTimeView.flowTimeRightLabel.text  = nil;
//    self.minuteTimeView.flowTimeLeftLabel.text = nil;
//    self.minuteTimeView.flowTimeRightLabel.text = nil;
//    self.secondTimeView.flowTimeLeftLabel.text  =  nil;
//    self.secondTimeView.flowTimeRightLabel.text  = nil;
}

#pragma mark -- MZTimerLabelDelegate

//- (NSString*)timerLabel:(MZTimerLabel *)timerLabel customTextToDisplayAtTime:(NSTimeInterval)time
//{
//    if([timerLabel isEqual:self.timeLabel])
//    {
//        int tmp_time = (int)time % (24 * 3600);
//        int second = (int)tmp_time  % 60;
//        int minute = ((int)tmp_time / 60) % 60;
//        int hours = tmp_time / 3600;
//        int days = time / 24 / 60 / 60 ;
//        if (days > 0)
//        {
//            return [NSString stringWithFormat:@"%02d day(s)  %02d : %02d : %02d",days,hours,minute,second];
//        }
//        else
//        {
//            return [NSString stringWithFormat:@"%02d : %02d : %02d",hours,minute,second];
//        }
//    }
//    else
//    {
//        return nil;
//    }
//}

- (void)collectAction:(UIButton *)sender{
    if (self.collectBlock) {
        self.collectBlock(_model);
    }
}

- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleVertical];
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
}

- (UIButton *)collecBtn{
    if (!_collecBtn) {
        _collecBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collecBtn setImage:[UIImage imageNamed:@"goods_like18"] forState:UIControlStateNormal];
        [_collecBtn setImage:[UIImage imageNamed:@"goods_liked18"] forState:UIControlStateSelected];
        [_collecBtn addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collecBtn;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
//    if (!_activityStateView.isHidden && _activityStateView.size.height > 0) {
        
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
//        } else {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
//        }
//    }
}

-(UILabel *)isNewLbl{
    if (!_isNewLbl) {
        _isNewLbl = [UILabel new];
        if (APP_TYPE == 3) {
            _isNewLbl.font = [UIFont systemFontOfSize:10];
            _isNewLbl.backgroundColor = OSSVThemesColors.stlWhiteColor;
            _isNewLbl.textColor = OSSVThemesColors.col_26652C;
        } else {
            _isNewLbl.font = [UIFont boldSystemFontOfSize:12];
            _isNewLbl.backgroundColor = OSSVThemesColors.col_60CD8E;
            _isNewLbl.textColor = UIColor.whiteColor;
        }
        _isNewLbl.text = STLLocalizedString_(@"new_goods_mark", nil).uppercaseString;
        _isNewLbl.textAlignment = NSTextAlignmentCenter;
        _isNewLbl.hidden = YES;
    }
    return _isNewLbl;
}


@end
