//
//  ZFGoodsDetailGoodsInfoCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailGoodsInfoCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFLabel.h"
#import <Lottie/Lottie.h>
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "GoodsDetailModel.h"
#import "ZFRRPLabel.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFGoodsReviewStarsView.h"
#import "GoodsDetailsReviewsModel.h"
#import "ZFBTSManager.h"
#import <Lottie/Lottie.h>

@interface ZFGoodsDetailGoodsInfoCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *shopPriceLabel;
@property (nonatomic, strong) ZFRRPLabel            *marketPriceLabel;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) ZFLabel               *freeLabel;
@property (nonatomic, strong) UIView                *tagView;
@property (nonatomic, strong) BigClickAreaButton    *collectionButton;
@property (nonatomic, strong) UILabel               *collectionCountLabel;
@property (nonatomic, strong) UIView                *bottomLineView;
@property (nonatomic, strong) UIButton              *percentOffBtn;/** v3.6.0 折扣百分比 */
@property (nonatomic, strong) UIButton              *testBtn;// 测试按钮
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIView                    *startBgView;
@property (nonatomic, strong) ZFGoodsReviewStarsView    *starsView;
@property (nonatomic, strong) UIImageView               *arrowView;
@property (nonatomic, strong) LOTAnimationView          *giftAnimView;
@end

@implementation ZFGoodsDetailGoodsInfoCell

@synthesize cellTypeModel = _cellTypeModel;

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)collectionButtonAction:(UIButton *)sender {
    //防止重复点击
    //v4.5.0暂时用这个动画
//    [sender.imageView.layer addAnimation:[sender.imageView zfAnimationFavouriteScale] forKey:@"likeAnimation"];
    sender.userInteractionEnabled = NO;
    //取消点赞不需要动画
    BOOL showAnimView = !sender.selected;
    sender.selected = !sender.selected;
    
    // 请求点赞回调
    if (self.cellTypeModel.detailCellActionBlock) {
        self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, @(sender.selected), self.indexPath);
    }
    
    if (showAnimView) { //执行收藏动画
        
        @weakify(self)
        [self.giftAnimView playWithCompletion:^(BOOL animationFinished) {
            @strongify(self)
            sender.userInteractionEnabled = YES;
            [self.giftAnimView setAnimationNamed:@"ZZZZZ_goods_collect_end"];
            
            //震动反馈
            ZFPlaySystemQuake();
        }];

//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            sender.userInteractionEnabled = YES;//恢复点击状态
//            [self.collectionButton setImage:[UIImage imageNamed:@"goodsDetail_unLike"] forState:UIControlStateNormal];
//            [self.collectionButton setImage:[UIImage imageNamed:@"goodsDetail_like"] forState:UIControlStateSelected];
//        });
        
    } else { //取消收藏
        
        @weakify(self)
        [self.giftAnimView playWithCompletion:^(BOOL animationFinished) {
            @strongify(self)
            sender.userInteractionEnabled = YES;
            [self.giftAnimView setAnimationNamed:@"ZZZZZ_goods_collect"];

        }];
        
//        sender.userInteractionEnabled = YES;
//        [self.giftAnimView stop];
//        [self.collectionButton setImage:[UIImage imageNamed:@"goodsDetail_unLike"] forState:UIControlStateNormal];
//        [self.collectionButton setImage:[UIImage imageNamed:@"goodsDetail_like"] forState:UIControlStateSelected];
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.shopPriceLabel];
    [self.contentView addSubview:self.activityView];
    [self.contentView addSubview:self.marketPriceLabel];
    [self.contentView addSubview:self.percentOffBtn];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.tagView];
    [self.contentView addSubview:self.collectionCountLabel];
    [self.contentView addSubview:self.giftAnimView];
    [self.contentView addSubview:self.collectionButton];
    [self.contentView addSubview:self.bottomLineView];
    
    [self.contentView addSubview:self.startBgView];
    [self.startBgView addSubview:self.starsView];
    [self.startBgView addSubview:self.arrowView];
}

- (void)zfAutoLayoutView {
    CGFloat maxWidth = (KScreenWidth-148)/2;
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.height.mas_equalTo(24);
        make.width.mas_lessThanOrEqualTo(maxWidth);
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(20);
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
    }];
    
    [self.marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.shopPriceLabel).offset(2);
        make.leading.mas_equalTo(self.shopPriceLabel.mas_trailing).offset(8);
        make.height.mas_equalTo(24);
        make.width.mas_lessThanOrEqualTo(maxWidth);
    }];
    
    [self.collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.marketPriceLabel.mas_centerY);
        make.trailing.offset(-12);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.giftAnimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.marketPriceLabel.mas_centerY);
        make.trailing.offset(-16);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    
    
    [self.collectionCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.giftAnimView);
        make.top.mas_equalTo(self.giftAnimView.mas_bottom).offset(-5);
        make.height.mas_equalTo(15);
    }];
    
    [self.percentOffBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shopPriceLabel.mas_bottom).offset(10);
        make.leading.offset(16);
        make.height.mas_equalTo(16);
    }];
    
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.percentOffBtn);
        make.leading.mas_equalTo(self.percentOffBtn.mas_trailing).offset(4);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shopPriceLabel.mas_bottom).offset(10);
        make.leading.offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
        make.leading.trailing.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(8);
    }];
    
///===============================================================================
    [self.startBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.shopPriceLabel.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.starsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.mas_equalTo(self.startBgView);
        make.size.mas_equalTo(CGSizeMake(95, 20));
    }];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.starsView.mas_trailing).offset(5);
        make.centerY.mas_equalTo(self.starsView.mas_centerY);
        make.trailing.mas_equalTo(self.startBgView.mas_trailing);
    }];
}

#pragma mark - setter
- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    
    //V5.5.0商详优化Bts实验: 有评论星级才显示
    _startBgView.hidden = YES;
    self.collectionButton.hidden = NO;
    self.collectionCountLabel.hidden = NO;
    self.giftAnimView.hidden = NO;
    
    ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIosxaddbag defaultPolicy:kZFBts_A];
    if (![btsModel.policy isEqualToString:kZFBts_A]) {
        
        self.collectionButton.hidden = YES;
        self.collectionCountLabel.hidden = YES;
        self.giftAnimView.hidden = YES;

        NSString *rateAVG = cellTypeModel.detailModel.rateAVG;
        if (!ZFIsEmptyString(rateAVG)) {
            self.startBgView.hidden = NO;
            self.starsView.rateAVG = [NSString stringWithFormat:@"%lf", rateAVG.floatValue];
        }

    } else {
        
        self.collectionButton.userInteractionEnabled = YES;
        if ([self.cellTypeModel.detailModel.is_collect isEqualToString:@"1"]) {
            self.collectionButton.selected = YES;
            [self.giftAnimView setAnimationNamed:@"ZZZZZ_goods_collect_end"];

        } else {
            self.collectionButton.selected = NO;
            [self.giftAnimView setAnimationNamed:@"ZZZZZ_goods_collect"];
        }
    }
//=================================================================
    
    self.shopPriceLabel.text = [ExchangeManager transforPrice:cellTypeModel.detailModel.shop_price];
    
    YWLog(@"刷新商详页面价格===%@===%d", self.shopPriceLabel.text, cellTypeModel.detailModel.cache_cdn);
    if ((ZFIsEmptyString(cellTypeModel.detailModel.manzeng_id) && [AccountManager sharedManager].appShouldRequestCdn) && !cellTypeModel.detailModel.detailCdnPortSuccess) {
        self.activityView.hidden = NO;
        [self.activityView startAnimating];
        self.shopPriceLabel.hidden = YES;
        self.marketPriceLabel.hidden = YES;
        
    } else {
        self.activityView.hidden = YES;
        [self.activityView stopAnimating];
        self.shopPriceLabel.hidden = NO;
        
        if ([cellTypeModel.detailModel showMarketPrice]) {
            self.shopPriceLabel.textColor = ZFC0xFE5269();
            self.marketPriceLabel.hidden = NO;
        } else {
            self.shopPriceLabel.textColor = ZFCOLOR(45, 45, 45, 1);
            self.marketPriceLabel.hidden = YES;
        }
    }
    
    NSString *marketPrice = [ExchangeManager transforPrice:cellTypeModel.detailModel.market_price];
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:marketPrice attributes:attribtDic];
    self.marketPriceLabel.attributedText = attribtStr;
    
    [self.freeLabel removeFromSuperview];
    if (!ZFIsEmptyString(cellTypeModel.detailModel.manzeng_id)) {
        [self.contentView addSubview:self.freeLabel];
        [self.freeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.shopPriceLabel);
            if (self.marketPriceLabel.isHidden) {
                make.leading.mas_equalTo(self.shopPriceLabel.mas_trailing).offset(7);
            } else {
                make.leading.mas_equalTo(self.marketPriceLabel.mas_trailing).offset(7);
            }
        }];
    }
    
    self.titleLabel.text = cellTypeModel.detailModel.goods_name;
    self.collectionButton.selected = [cellTypeModel.detailModel.is_collect boolValue];
    self.collectionCountLabel.textColor = [cellTypeModel.detailModel.is_collect boolValue] ? ZFC0xFE5269() : ZFC0x999999();
    self.collectionCountLabel.text = cellTypeModel.detailModel.like_count;
    YWLog(@"商详商品点赞数===%@",cellTypeModel.detailModel.like_count);
    
    // 是否显示分期付款标
    BOOL showInstalmentTags = (!ZFIsEmptyString(cellTypeModel.detailModel.instalmentModel.per) && !ZFIsEmptyString(cellTypeModel.detailModel.instalmentModel.instalments));
    
    // 如果返回了分期付款标，其他的标不管是什么都不显示
    if (!showInstalmentTags && [cellTypeModel.detailModel.promote_zhekou floatValue] >= 50.0) {
        self.percentOffBtn.hidden = NO;
        [self.percentOffBtn setTitle:[NSString stringWithFormat:@"%@%% %@", cellTypeModel.detailModel.promote_zhekou,ZFLocalizedString(@"CartOrderInfo_ShippingMethodSubCell_Cell_OFF", nil)] forState:UIControlStateNormal];
        
        [self.percentOffBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.shopPriceLabel.mas_bottom).offset(10);
            make.leading.offset(16);
        }];
        [self.percentOffBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        
        [self.tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.percentOffBtn);
            make.leading.mas_equalTo(self.percentOffBtn.mas_trailing).offset(4);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.height.mas_equalTo(16);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.percentOffBtn.mas_bottom).offset(10);
            make.leading.offset(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        }];
        
    } else {
        self.percentOffBtn.hidden = YES;
        [self.percentOffBtn setTitle:@"" forState:UIControlStateNormal];
        
        UIView *tmpView = nil;
        CGFloat tagViewX = 16;
        if (showInstalmentTags) {//显示巴西分期付款标
            tmpView = self.tagView;
            tagViewX = 12;
        } else {
            tmpView = (cellTypeModel.detailModel.tagsArray.count > 0) ? self.tagView : self.shopPriceLabel;
        }
        [self.tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.shopPriceLabel.mas_bottom).offset(10);
            make.leading.offset(tagViewX);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.height.mas_equalTo(16);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(tmpView.mas_bottom).offset(8);
            make.leading.offset(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        }];
    }
    
    self.tagView.hidden = YES;
    //优先显示巴西分期付款标,其他标(清仓标 COD, APP, ONLY, SALE)都不展示
    if (showInstalmentTags) {
        ZFGoodsTagModel *tagModel = cellTypeModel.detailModel.instalmentModel.instalmentTagModel;
        if (tagModel) {
            self.tagView.hidden = NO;
            [self configureTagView:@[tagModel]];
        }
    } else {
        if (cellTypeModel.detailModel.tagsArray.count > 0) {
            self.tagView.hidden = NO;
            [self configureTagView:cellTypeModel.detailModel.tagsArray];
        }
    }
    [self.contentView layoutIfNeeded];
}

- (void)configureTagView:(NSArray<ZFGoodsTagModel *> *)tagsArray {
    CGFloat tagWidth                = 0.0f;
    CGFloat tagHorizontalMargin     = 4.0f;
    CGFloat labelInsetMargin        = 8.0f;
    CGFloat tagVerticalMargin       = 2.0f;
    CGFloat tagHeight               = 16.0f;
    NSInteger count = tagsArray.count;
    BOOL  isNewLine;
    
    // 判断宽度
    for (ZFGoodsTagModel *tagModel in tagsArray) {
        tagWidth += [self calculateTitleSizeWithString:tagModel.tagTitle].width + labelInsetMargin;
        tagWidth += (tagsArray.count - 1) * tagHorizontalMargin;
    }
    isNewLine = tagWidth > KScreenWidth - 117 ? YES : NO;
    ZFLabel *lastTagLabel = nil;
    
    for (int i = 0; i < count; ++i) {
        ZFGoodsTagModel *tagModel = tagsArray[i];
        ZFLabel *tagLabel =  [self configureTagLabelWithText:tagModel.tagTitle
                                                       color:tagModel.tagColor
                                                    fontSize:tagModel.fontSize
                                                 borderColor:tagModel.borderColor];
        [self.tagView addSubview:tagLabel];
        [tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(tagHeight);
            if (i == 0) {
                make.leading.top.mas_equalTo(self.tagView);
                if (i == count - 1) {
                    make.bottom.mas_equalTo(self.tagView);
                }
            } else {
                if (i == count - 1 && isNewLine) {
                    make.leading.bottom.mas_equalTo(self.tagView);
                    make.top.equalTo(lastTagLabel.mas_bottom).offset(tagVerticalMargin);
                } else {
                    make.top.mas_equalTo(self.tagView);
                    make.leading.mas_equalTo(lastTagLabel.mas_trailing).offset(tagHorizontalMargin);
                    make.trailing.lessThanOrEqualTo(self.tagView); // 右边不超出
                    make.bottom.mas_equalTo(self.tagView);
                }
            }
        }];
        lastTagLabel = tagLabel;
    }
}

- (ZFLabel *)configureTagLabelWithText:(NSString *)text
                                 color:(NSString *)color
                              fontSize:(NSInteger)fontSize
                           borderColor:(NSString *)borderColor {
    ZFLabel *tagLabel = [[ZFLabel alloc] init];
    tagLabel.textColor = [UIColor colorWithHexString:color];
    if (fontSize <= 10) {
        fontSize = 10;
    }
    tagLabel.font = [UIFont systemFontOfSize:fontSize];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    tagLabel.edgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
    tagLabel.text = text;
    if (ZFIsEmptyString(borderColor)) {
        borderColor = color;
    }
    tagLabel.layer.borderColor = [UIColor colorWithHexString:borderColor].CGColor;
    tagLabel.layer.borderWidth = 1.0f;
    return tagLabel;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string {
    CGFloat fontSize = 10.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 20)  options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}

// 测试功能:点击复制SKU
-(void)copyGoodSNClick:(UIGestureRecognizer *)sender {
    if ([YWLocalHostManager isDistributionOnlineRelease]) return;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        ((UIButton *)sender).hidden = YES;
    } else {
        [self showTestBtn:NO];
        self.testBtn.hidden = !self.testBtn.hidden;
    }
    NSString *title = [NSString stringWithFormat:@"%@-%@",self.cellTypeModel.detailModel.goods_sn, self.cellTypeModel.detailModel.goods_id];
    [UIPasteboard generalPasteboard].string = title;
    ShowToastToViewWithText(nil, [NSString stringWithFormat:@"%@复制成功",title]);
}

// 测试功能:点击复制SKU
- (void)showTestBtn:(BOOL)addTap {
    if ([YWLocalHostManager isOnlineRelease]) return;
    
    if (addTap) {
        if (![YWLocalHostManager isOnlineRelease]){
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(copyGoodSNClick:)];
            [_shopPriceLabel addGestureRecognizer:tapGesture];
            _shopPriceLabel.userInteractionEnabled = YES;
        }
    } else {
        if (self.testBtn) return;
        UIButton *testBtn = [[UIButton alloc] init];
        testBtn.frame = CGRectMake(150, 18, 150, 18);
        testBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        testBtn.layer.cornerRadius = 9;
        testBtn.layer.masksToBounds = YES;
        testBtn.hidden = YES;
        testBtn.titleLabel.font = ZFFontSystemSize(14);
        NSString *title = [NSString stringWithFormat:@"%@-%@",self.cellTypeModel.detailModel.goods_sn, self.cellTypeModel.detailModel.goods_id];
        [testBtn setTitle:title forState:(UIControlStateNormal)];
        [testBtn addTarget:self action:@selector(copyGoodSNClick:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.contentView addSubview:testBtn];
        self.testBtn = testBtn;
    }
}

#pragma mark - getter

/**
 *接口加cdn后, 商品实时信息没查出来前先显示转圈
 */
- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        [_activityView hidesWhenStopped];
        [_activityView startAnimating];
    }
    return _activityView;
}

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.backgroundColor = [UIColor whiteColor];
        _shopPriceLabel.textColor = ZFC0xFE5269();
        _shopPriceLabel.font = [UIFont boldSystemFontOfSize:24];
        _shopPriceLabel.adjustsFontSizeToFitWidth = YES;
        _shopPriceLabel.hidden = YES;
        
        if (![YWLocalHostManager isOnlineRelease]){
            [self showTestBtn:YES];
        }
    }
    return _shopPriceLabel;
}

- (ZFRRPLabel *)marketPriceLabel {
    if (!_marketPriceLabel) {
        _marketPriceLabel = [[ZFRRPLabel alloc] initWithFrame:CGRectZero];
        _marketPriceLabel.backgroundColor = [UIColor whiteColor];
        _marketPriceLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _marketPriceLabel.font = [UIFont systemFontOfSize:16];
        _marketPriceLabel.adjustsFontSizeToFitWidth = YES;
        _marketPriceLabel.hidden = YES;
    }
    return _marketPriceLabel;
}

-(UIButton *)percentOffBtn{
    if (!_percentOffBtn) {
        _percentOffBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _percentOffBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
        _percentOffBtn.backgroundColor = ZFCClearColor();
        _percentOffBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [_percentOffBtn setTitleColor:ZFC0xFE5269() forState:UIControlStateNormal];
        _percentOffBtn.layer.borderWidth = 1.0;
        _percentOffBtn.layer.borderColor = ZFC0xFE5269().CGColor;
    }
    return _percentOffBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.preferredMaxLayoutWidth = (KScreenWidth - 12 - 16 - 85);
    }
    return _titleLabel;
}

- (BigClickAreaButton *)collectionButton {
    if (!_collectionButton) {
        _collectionButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
//        _collectionButton.backgroundColor = [UIColor whiteColor];
//        _collectionButton.titleLabel.backgroundColor = [UIColor whiteColor];
//        [_collectionButton setImage:[UIImage imageNamed:@"goodsDetail_unLike"] forState:UIControlStateNormal];
//        [_collectionButton setImage:[UIImage imageNamed:@"goodsDetail_like"] forState:UIControlStateSelected];
        [_collectionButton addTarget:self action:@selector(collectionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        _collectionButton.clickAreaRadious = 64;
    }
    return _collectionButton;
}

// 收藏动画
- (LOTAnimationView *)giftAnimView {
    if(!_giftAnimView){
        _giftAnimView = [LOTAnimationView animationNamed:@"ZZZZZ_goods_collect"];
        _giftAnimView.loopAnimation = NO;
        _giftAnimView.userInteractionEnabled = NO;
    }
    return _giftAnimView;
}

- (UIView *)startBgView {
    if (!_startBgView) {
        _startBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _startBgView.hidden = YES;
        @weakify(self);
        [_startBgView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.cellTypeModel.detailCellActionBlock) {
                self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, nil, nil);
            }
        }];
    }
    return _startBgView;
}

- (ZFGoodsReviewStarsView *)starsView {
    if (!_starsView) {
        _starsView = [[ZFGoodsReviewStarsView alloc] initWithFrame:CGRectZero];
    }
    return _starsView;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowView.contentMode = UIViewContentModeScaleAspectFit;
        _arrowView.image = [UIImage imageNamed:@"size_arrow_right"];
        
        [_arrowView convertUIWithARLanguage];
    }
    return _arrowView;
}

- (UILabel *)collectionCountLabel {
    if (!_collectionCountLabel) {
        _collectionCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _collectionCountLabel.backgroundColor = [UIColor whiteColor];
        _collectionCountLabel.textColor = ZFC0x999999();
        _collectionCountLabel.font = [UIFont systemFontOfSize:10];
        _collectionCountLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _collectionCountLabel;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    }
    return _bottomLineView;
}

- (UIView *)tagView {
    if (!_tagView) {
        _tagView = [[UIView alloc] init];
        _tagView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _tagView;
}

- (ZFLabel *)freeLabel {
    if (!_freeLabel) {
        _freeLabel = [[ZFLabel alloc] init];
        _freeLabel.font = ZFFontSystemSize(10);
        _freeLabel.textColor = ZFCOLOR(255, 255, 255, 1);
        _freeLabel.textAlignment = NSTextAlignmentCenter;
        _freeLabel.backgroundColor = ZFCOLOR(255, 158, 53, 1);
        _freeLabel.text = ZFLocalizedString(@"free", nil);
        _freeLabel.edgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
        _freeLabel.layer.cornerRadius = 1.0;
    }
    return _freeLabel;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.shopPriceLabel.text = nil;
    self.marketPriceLabel.text = nil;
    [self.tagView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.titleLabel.text = nil;
    self.collectionButton.selected = NO;
    self.collectionCountLabel.text = nil;
}

@end
