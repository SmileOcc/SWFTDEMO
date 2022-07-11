//
//  OSSVDetailsHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsHeaderView.h"
#import "SignViewController.h"
#import "AppDelegate+STLCategory.h"
// Model
#import "OSSVDetailsBaseInfoModel.h"
#import "OSSVDetailPictureArrayModel.h"
#import "OSSVNSStringTool.h"
#import "STLBannerScrollView.h"
#import "OSSVFindSimilarView.h"
#import "STLPhotoBrowserView.h"
#import "Adorawe-Swift.h"

#define kIPHONEX_TOP_SPACE44                   ((SCREEN_HEIGHT > 736.0)?44:0)

@interface OSSVDetailsHeaderView ()
<
STLBannerScrollViewDelegate
>
{
    NSInteger currentPage; // 记录滑动图片页码
}

@property (nonatomic, weak) OSSVDetailsBaseInfoModel       *model;

@property (nonatomic, strong) OSSVReviewsModel            *reviewsModel;
/** 传入图片封面*/
@property (nonatomic, strong) YYAnimatedImageView                 *coverImgView;
/** 图片*/
@property (nonatomic, strong) STLBannerScrollView                 *bannerScrollView;
/** 图片页码*/
@property (nonatomic, strong) UILabel                             *pageLabel;
@property (nonatomic, strong) JXPageControlScale                       *pageControl;
/**相似商品*/
@property (nonatomic, strong) OSSVFindSimilarView             *goodsFindSimilarView;
///折扣标
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView  *discountLbl;
///是否新品
@property (nonatomic,strong) UILabel *isNewLbl;
@end

@implementation OSSVDetailsHeaderView

-(void)dealloc {
    STLLog(@"%@", NSStringFromClass(self.class));
}

-(void)clearMemory{
    [self removeConstraints:self.constraints];
    [self.bannerScrollView removeFromSuperview];
    [self.coverImgView removeFromSuperview];
    [self.goodsFindSimilarView removeFromSuperview];
    self.coverImgView = nil;
    self.bannerScrollView = nil;
    self.goodsFindSimilarView = nil;
}


+ (OSSVDetailsHeaderView*)goodsDetailsHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[OSSVDetailsHeaderView class] forSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(OSSVDetailsHeaderView.class)];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(OSSVDetailsHeaderView.class) forIndexPath:indexPath];
}

#pragma mark - Returns the HeaderView height
+ (CGFloat)headerViewHeight {
    if (APP_TYPE == 3) {
        return SCREEN_WIDTH + kIPHONEX_TOP_SPACE44 - 7;
    }
    // 底部间隙 7
    return SCREEN_WIDTH + kIPHONEX_TOP_SPACE44 + 7;
}

- (OSSVReviewsModel *)reviewsModel {
    if (!_reviewsModel) {
        _reviewsModel = [[OSSVReviewsModel alloc] init];
    }
    return _reviewsModel;
}

#pragma mark - Initialize subView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [OSSVThemesColors col_F5F5F5];
        [self addSubview:self.bannerScrollView];
        [self addSubview:self.coverImgView];
        [self addSubview:self.goodsFindSimilarView];
        [self addSubview:self.pageLabel];
        [self addSubview:self.collectBtn];
        [self addSubview:self.shareBtn];
        [self addSubview:self.shareBgV];
        [self addSubview:self.pageControl];
        [self.shareBgV addSubview:self.shareImgV];
        [self addSubview:self.discountLbl];
        [self addSubview:self.isNewLbl];
        
        [self bringSubviewToFront:self.goodsFindSimilarView];
        [self makeConstraints];
        
        self.pageLabel.hidden = APP_TYPE == 3;
        self.pageControl.hidden = APP_TYPE != 3;
        
        //v 2.0.0
        [self hideShare];
        
        
    }
    return self;
}

#pragma mark - 约束
- (void)makeConstraints {

    [self.bannerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_top).mas_offset(APP_TYPE == 3 ? kIPHONEX_TOP_SPACE44 - 7 : kIPHONEX_TOP_SPACE44);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH));
    }];
    
    [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-17);
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(40);
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-18);
        make.height.mas_equalTo(18);
    }];

    [self.coverImgView mas_makeConstraints:   ^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_top).mas_offset(kIPHONEX_TOP_SPACE44);
        make.height.mas_equalTo(SCREEN_WIDTH);
    }];
    
    [self.collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-19);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.collectBtn.mas_top).offset(-12);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    [self.shareBgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.shareBtn);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];

    [self.shareImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.shareBgV);
        make.width.height.mas_equalTo(18);
    }];
    
    
    [self.goodsFindSimilarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bannerScrollView);
    }];
    
    [self.discountLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bannerScrollView.mas_top).offset(12);
        make.leading.equalTo(12);
        make.height.equalTo(18);
//        make.width.equalTo(0);
    }];
    
    CGFloat width = [self.isNewLbl sizeThatFits:CGSizeMake(MAXFLOAT, 18)].width + 8;
    [self.isNewLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.height.equalTo(self.discountLbl);
        make.width.equalTo(width);
    }];
    
    [self showShareRuleJudge];
}

// 分享按钮动效规则
- (void)showShareRuleJudge{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDate *defaultDate = [defaults objectForKey:kGoodsDetailTime];
//    if (!defaultDate) {
//        // 不存在
//        [self changeFirstDayViewedStatus];
//    }else{
//        if ([self judgeCurrentDayViewedWithDate:defaultDate]) {
//            // 非首日访问（也就是同一天）
//            [self returnDefaultStatus];
//        }else{
//            // 首日访问
//            [self changeFirstDayViewedStatus];
//        }
//    }
    NSDate *installDate = [AppDelegate getAppInstallOrUpdateTime];
    if (installDate && [self judgeCurrentDayViewedWithDate:installDate]) {
        [self returnDefaultStatus];
    }else{
        [self changeFirstDayViewedStatus];
    }
}

// 非首日访问状态
- (void)changeFirstDayViewedStatus{
    self.shareBtn.hidden = YES;
    self.shareImgV.hidden = NO;
    self.shareBgV.hidden = NO;
//    [self performSelector:@selector(returnDefaultStatus) withObject:nil afterDelay:4];
    
    [self hideShare];
}

// 恢复默认状态
- (void)returnDefaultStatus{
    self.shareImgV.hidden = YES;
    self.shareBgV.hidden = YES;
    self.shareBtn.hidden = NO;
    
    [self hideShare];

}

// 判断当天是否是首日访问
- (BOOL)judgeCurrentDayViewedWithDate:(NSDate *)defaultDate{
    return [[NSCalendar currentCalendar] isDate:defaultDate inSameDayAsDate:[NSDate date]];
}

- (void)updateDetailInfoModel:(OSSVDetailsListModel *)model recommend:(BOOL)hasRecommend{
    
    if (model) {
        self.userInteractionEnabled = YES;
    }
    self.bannerScrollView.configureImageWidth = model.goodsImageWidth;
    self.model = model.goodsBaseInfo;
}
#pragma mark
#pragma mark - Set Model

- (void)setCoverImageUrl:(NSString *)coverImageUrl {
    //隐藏封面
//    if (_coverImageUrl != coverImageUrl && [coverImageUrl hasPrefix:@"http"]) {
//        _coverImageUrl = coverImageUrl;
//        self.coverImgView.hidden = false;
//        [self.coverImgView yy_setImageWithURL:[NSURL URLWithString:_coverImageUrl]
//                                  placeholder:[UIImage imageNamed:@"placeholder_pdf"]
//                                      options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
//                                   completion:nil];
//    }
    self.coverImgView.hidden = YES;
}
#pragma mark -----数据赋值
- (void)setModel:(OSSVDetailsBaseInfoModel *)model {
    if (!model) { return; }

    _model = model;
    
    self.pageLabel.hidden = YES;
    self.pageControl.hidden = YES;
    self.pageLabel.text = nil;
    // 图片处理
    NSMutableArray *imgUrls = [[NSMutableArray alloc] init];
    // 图片数据
    if (!STLJudgeEmptyArray(_model.pictureListArray)) {
        self.pageLabel.hidden = NO || APP_TYPE == 3;
        self.pageControl.hidden = NO || APP_TYPE != 3;
        self.pageLabel.text = [NSString stringWithFormat:@"%li/%lu",(long)currentPage + 1,(unsigned long)_model.pictureListArray.count];
        self.pageControl.numberOfPages = _model.pictureListArray.count;
        self.pageControl.currentPage = currentPage;
        [_model.pictureListArray enumerateObjectsUsingBlock:^(OSSVDetailPictureArrayModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [imgUrls addObject:STLToString(obj.goodsBigImg)];
        }];
    }
    
//    UIImage *defaultImage = [UIImage imageNamed:@"loading_product"];
    //self.bannerScrollView.placeHoldImage = [cellTypeModel.placeHoldImage isKindOfClass:[UIImage class]] ? cellTypeModel.placeHoldImage : defaultImage;
    
    // 不同颜色的商品切换时滚动到第一张
//    BOOL scrollToFirst = [self.bannerScrollView.placeHoldImage isEqual:defaultImage];
    [self.bannerScrollView refreshImageUrl:imgUrls
                  scrollToFirstIndex:true animated:false];
    
    self.goodsFindSimilarView.hidden = YES;
    if ([model.shield_status integerValue] == 1) {
        self.goodsFindSimilarView.hidden = NO;
        self.goodsFindSimilarView.tipLabel.text = STLToString(model.shield_tips);
    }
    
    // 是否收藏
    self.collectBtn.hidden = NO;
    self.collectBtn.selected = model.isCollect;
    self.isCollect = model.isCollect;

    NSString *collectImgName = model.isCollect ? @"goods_liked18" : @"goods_like18";
    [self.collectBtn setImage:[UIImage imageNamed:collectImgName] forState:UIControlStateNormal];
    
    
    if (APP_TYPE == 3){
        NSString *discountStr = STLToString(model.discount);
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            discountStr = [NSString stringWithFormat:@"-%@%%",discountStr];
        } else {
            discountStr = [NSString stringWithFormat:@"-%@%%",discountStr];
        }
    //    self.discountLbl.text = discountStr;
    //    CGFloat w = [self.discountLbl sizeThatFits:CGSizeMake(MAXFLOAT, 18)].width;
    //    [self.discountLbl mas_updateConstraints:^(MASConstraintMaker *make) {
    //        make.width.equalTo(w + 8);
    //    }];
        self.discountLbl.hidden = YES;
        if ([model.showDiscountIcon isEqualToString:@"0"] || [OSSVNSStringTool isEmptyString:model.goodsDiscount] || [model.goodsDiscount isEqualToString:@"0"]) {
            
        } else {// 价格
            self.discountLbl.hidden = NO;
            [self.discountLbl updateState:STLActivityStyleNormal discount:STLToString(model.goodsDiscount)];
        }
        
        
        //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
        // 0 > 闪购 > 满减
        if (STLIsEmptyString(model.specialId) && model.flash_sale &&  [model.flash_sale.is_can_buy isEqualToString:@"1"] && [model.flash_sale.active_status isEqualToString:@"1"]) {
            self.discountLbl.hidden = NO;
            [self.discountLbl updateState:STLActivityStyleFlashSale discount:STLToString(model.flash_sale.active_discount)];
        }
        
        self.isNewLbl.hidden =![model isShowGoodDetailNew];
    }
}

#pragma mark - STLBannerScrollViewDelegate
/**
 点击Banner回调
 */
- (void)bannerScrollView:(STLBannerScrollView *)view showImageViewArray:(NSArray *)showImageViewArray didSelectItemAtIndex:(NSInteger)index {
    
    if (self.bannerScrollView.imageUrlArray.count > index) {
        [GATools logEventWithName:@"window_map_click"
                      screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.model.goodsTitle)]
                           action:[NSString stringWithFormat:@"%@_%li",STLToString(self.model.goodsTitle),(long)index]];
    }

    
    if (STLJudgeEmptyArray(self.model.pictureListArray)) return;
    NSArray<OSSVDetailPictureArrayModel*> *pictures = [[NSArray alloc] initWithArray:self.model.pictureListArray];
    NSMutableArray *tempBrowseImageArr = [NSMutableArray array];

    [pictures enumerateObjectsUsingBlock:^(OSSVDetailPictureArrayModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            STLPhotoGroupItem *showItem = [STLPhotoGroupItem new];
            if (showImageViewArray.count > idx) {
                showItem.thumbView = showImageViewArray[idx];
            }
            NSURL *url = [NSURL URLWithString:obj.goodsBigImg];
            showItem.largeImageURL = url;
            [tempBrowseImageArr addObject:showItem];
        }
    }];

    if (tempBrowseImageArr.count > index && tempBrowseImageArr.count > 0) {
        
        STLPhotoBrowserView *groupView = [[STLPhotoBrowserView alloc]initWithGroupItems:tempBrowseImageArr];
        groupView.showDismiss = YES;
        
        @weakify(self)
        groupView.dismissCompletion = ^(NSInteger currentPage) {
            @strongify(self)
            [self.bannerScrollView scrollToIndexBanner:currentPage animated:NO];
        };
        
        UIViewController *superCtrl = self.viewController;
        if (APP_TYPE == 3) {
            [groupView presentFromImageView:[showImageViewArray[index] superview].superview.superview toContainer:superCtrl.navigationController.view animated:YES completion:nil];
        }else{
            [groupView presentFromImageView:showImageViewArray[index] toContainer:superCtrl.navigationController.view animated:YES completion:nil];
        }
        
    }
    
   
}

- (void)didShowScrollViewPageAtIndex:(NSInteger)index {
    currentPage = index;
    self.pageLabel.text = [NSString stringWithFormat:@"%li/%lu",(long)currentPage+1,(unsigned long)_model.pictureListArray.count];
    self.pageControl.numberOfPages = _model.pictureListArray.count;
    self.pageControl.currentPage = currentPage;
    if (self.bannerScrollView.imageUrlArray.count > index) {
        [GATools logEventWithName:@"window_map_display"
                      screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.model.goodsTitle)]
                           action:[NSString stringWithFormat:@"%@_%li",STLToString(self.model.goodsTitle),(long)index]];
    }
    
}

- (void)collectAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(OSSVDetailsHeaderViewDidClick:)]) {
        [self.delegate OSSVDetailsHeaderViewDidClick:GoodsDetailsHeaderEventCollect];
    }
}

- (void)shareAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(OSSVDetailsHeaderViewDidClick:)]) {
        [self.delegate OSSVDetailsHeaderViewDidClick:GoodsDetailsHeaderEventShare];
    }
}

- (void)gifTapAction:(UITapGestureRecognizer *)tap{
    if (self.delegate && [self.delegate respondsToSelector:@selector(OSSVDetailsHeaderViewDidClick:)]) {
        [self.delegate OSSVDetailsHeaderViewDidClick:GoodsDetailsHeaderEventShare];
    }
}

- (void)hideShare {
    self.shareImgV.hidden = YES;
    self.shareBtn.hidden = YES;
    self.shareBgV.hidden = YES;
}

#pragma mark - Lazyload

- (STLBannerScrollView *)bannerScrollView {
    if (!_bannerScrollView) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
        _bannerScrollView = [[STLBannerScrollView alloc] initWithFrame:rect];
        _bannerScrollView.delegate = self;
        _bannerScrollView.placeHoldImage = [UIImage imageNamed:@"placeholder_big3_4"];
        _bannerScrollView.showPageControl = NO;
    }
    return _bannerScrollView;
}

- (YYAnimatedImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[YYAnimatedImageView alloc] init];
        _coverImgView.backgroundColor = OSSVThemesColors.col_F5F5F5;
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImgView.userInteractionEnabled = YES;
        _coverImgView.hidden = true;
    }
    return _coverImgView;
}

- (OSSVFindSimilarView *)goodsFindSimilarView {
    if (!_goodsFindSimilarView) {
        _goodsFindSimilarView = [[OSSVFindSimilarView alloc] initWithFrame:CGRectZero];
        _goodsFindSimilarView.hidden = YES;
        @weakify(self)
        _goodsFindSimilarView.similarBlock = ^{
            @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(OSSVDetailsHeaderViewDidClick:)]) {
                [self.delegate OSSVDetailsHeaderViewDidClick:GoodsDetailsHeaderEventGoodsSimilar];
            }
        };
    }
    return _goodsFindSimilarView;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _pageLabel.backgroundColor = [OSSVThemesColors col_0D0D0D:0.3];
        _pageLabel.textColor = OSSVThemesColors.col_FFFFFF;
        _pageLabel.font = [UIFont systemFontOfSize:12];
        _pageLabel.layer.cornerRadius = 9;
        _pageLabel.layer.masksToBounds = YES;
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.hidden = YES;
    }
    return _pageLabel;
}

- (EmitterButton *)collectBtn {
    if (!_collectBtn) {
        _collectBtn = [EmitterButton buttonWithType:UIButtonTypeCustom];
        [_collectBtn setImage:[UIImage imageNamed:@"goods_like18"] forState:UIControlStateNormal];
        _collectBtn.backgroundColor = [UIColor clearColor];
        [_collectBtn addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchDown];
        _collectBtn.backgroundColor = [OSSVThemesColors col_ffffff:0.8];
        _collectBtn.layer.borderWidth = 0.5;
        _collectBtn.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        _collectBtn.layer.cornerRadius = 16;
        _collectBtn.layer.masksToBounds = YES;
        _collectBtn.hidden = YES;
    }
    return _collectBtn;
}

- (UIButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBtn setImage:[UIImage imageNamed:@"goods_share"] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchDown];

        _shareBtn.backgroundColor = [OSSVThemesColors col_ffffff:0.8];
        _shareBtn.layer.borderWidth = 0.5;
        _shareBtn.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        _shareBtn.layer.cornerRadius = 16;
        _shareBtn.layer.masksToBounds = YES;
        _shareBtn.hidden = YES;
        _shareBtn.sensor_element_id = @"goods_detail_share_button";
    }
    return _shareBtn;
}

- (UIImageView *)shareImgV{
    if (!_shareImgV) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"share_earn" ofType:@"gif"];
        NSData *fileData = [NSData dataWithContentsOfFile:path];
        UIImage *customImg = [UIImage yy_imageWithSmallGIFData:fileData scale:1.0];
        _shareImgV = [UIImageView new];
        _shareImgV.image = customImg;
        _shareImgV.contentMode = UIViewContentModeScaleAspectFit;
        _shareImgV.userInteractionEnabled = YES;
    }
    return _shareImgV;
}

- (UIView *)shareBgV{
    if (!_shareBgV) {
        _shareBgV = [UIView new];
        _shareBgV.backgroundColor = [OSSVThemesColors.col_FFFFFF colorWithAlphaComponent:0.8];
        _shareBgV.layer.cornerRadius = 16;
        _shareBgV.layer.masksToBounds = YES;
        _shareBgV.userInteractionEnabled = YES;
        _shareBgV.layer.borderWidth = 0.5;
        _shareBgV.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        _shareBgV.sensor_element_id = @"goods_detail_share_button";

        UITapGestureRecognizer *shareGifTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gifTapAction:)];
        [_shareBgV addGestureRecognizer:shareGifTap];
        
    }
    return _shareBgV;
}

-(JXPageControlScale *)pageControl{
    if (!_pageControl) {
        _pageControl = [[JXPageControlScale alloc] init];
        _pageControl.userInteractionEnabled = false;
        _pageControl.activeColor = [OSSVThemesColors col_000000:1];
        _pageControl.inactiveColor = [OSSVThemesColors col_000000:0.3];
        _pageControl.activeSize = CGSizeMake(6, 6);
        _pageControl.inactiveSize = CGSizeMake(3, 3);
        if (OSSVSystemsConfigsUtils.isRightToLeftShow) {
            _pageControl.transform = CGAffineTransformMakeScale(-1, 1);
        }
        _pageControl.columnSpacing = 6;
        _pageControl.hidesForSinglePage = true;
    }
    return _pageControl;
}

-(OSSVDetailsHeaderActivityStateView *)discountLbl{
    if (!_discountLbl) {
        _discountLbl = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
//        _discountLbl.font = [UIFont systemFontOfSize:12];
//        _discountLbl.backgroundColor = OSSVThemesColors.col_FFFFFF;
//        _discountLbl.textColor = OSSVThemesColors.col_9F5123;
//        _discountLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _discountLbl;
}

-(UILabel *)isNewLbl{
    if (!_isNewLbl) {
        _isNewLbl = [UILabel new];
        _isNewLbl.font = [UIFont systemFontOfSize:10];
        _isNewLbl.backgroundColor = OSSVThemesColors.stlWhiteColor;
        _isNewLbl.textColor = OSSVThemesColors.col_26652C;
        _isNewLbl.text = STLLocalizedString_(@"new_goods_mark", nil).uppercaseString;
        _isNewLbl.textAlignment = NSTextAlignmentCenter;
        _isNewLbl.hidden = YES;
    }
    return _isNewLbl;
}


@end
