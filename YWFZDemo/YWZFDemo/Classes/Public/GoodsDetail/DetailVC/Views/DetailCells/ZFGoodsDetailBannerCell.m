//
//  ZFGoodsDetailBannerCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailBannerCell.h"
#import "ZFNewBannerScrollView.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "GoodsDetailModel.h"
#import "YYPhotoBrowseView.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "BigClickAreaButton.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFThemeManager.h"
#import "ZFBTSManager.h"
#import <Lottie/Lottie.h>


@interface ZFGoodsDetailBannerCell ()<ZFBannerScrollViewDelegate>
@property (nonatomic, strong) UIButton              *countLabel;
@property (nonatomic, strong) ZFNewBannerScrollView *bannerView;
@property (nonatomic, strong) BigClickAreaButton    *collectionButton;
@property (nonatomic, strong) UIView                *leftHoledSliderView;

@property (nonatomic, strong) LOTAnimationView      *giftAnimView;

@end

@implementation ZFGoodsDetailBannerCell

@synthesize cellTypeModel = _cellTypeModel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - SetData

- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;

    UIImage *defaultImage = [UIImage imageNamed:@"loading_product"];
    self.bannerView.placeHoldImage = [cellTypeModel.placeHoldImage isKindOfClass:[UIImage class]] ? cellTypeModel.placeHoldImage : defaultImage;
    
    // 不同颜色的商品切换时滚动到第一张
    BOOL scrollToFirst = [self.bannerView.placeHoldImage isEqual:defaultImage];
    
    [self.bannerView refreshImageUrl:self.cellTypeModel.detailModel.bannerPicturesUrlArray
                  scrollToFirstIndex:scrollToFirst];
    
    [self didShowScrollViewPageAtIndex:0];
    
    //V5.5.0优化实验
    ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIosxaddbag defaultPolicy:kZFBts_A];
    self.collectionButton.hidden = [btsModel.policy isEqualToString:kZFBts_A];
    self.giftAnimView.hidden = [btsModel.policy isEqualToString:kZFBts_A];
    
    if (!self.giftAnimView.isHidden) {
        self.collectionButton.userInteractionEnabled = YES;
        if ([self.cellTypeModel.detailModel.is_collect isEqualToString:@"1"]) {
            self.collectionButton.selected = YES;
            
            [self.giftAnimView setAnimationNamed:@"ZZZZZ_goods_collect_end"];
        } else {
            self.collectionButton.selected = NO;
            [self.giftAnimView setAnimationNamed:@"ZZZZZ_goods_collect"];
        }
    }
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
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
        infoDict[@"isSelected"] = @(sender.selected);
        infoDict[@"indexPath"] = self.indexPath;
        infoDict[@"isCollectionType"] = @(1);
        self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, infoDict, nil);
    }
    
    if (showAnimView) { //执行点赞动画
        @weakify(self)
        [self.giftAnimView playWithCompletion:^(BOOL animationFinished) {
            @strongify(self)
            sender.userInteractionEnabled = YES;
            [self.giftAnimView setAnimationNamed:@"ZZZZZ_goods_collect_end"];
            ZFPlaySystemQuake();
        }];
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            sender.userInteractionEnabled = YES;//恢复点击状态
//            [self.collectionButton setImage:[UIImage imageNamed:@"goodsDetail_unLike"] forState:UIControlStateNormal];
//            [self.collectionButton setImage:[UIImage imageNamed:@"goodsDetail_like"] forState:UIControlStateSelected];
//            [self.giftAnimView stop];
//        });
    } else {
        
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


#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    [self.contentView addSubview:self.bannerView];
    [self.contentView addSubview:self.leftHoledSliderView];
    [self.contentView addSubview:self.countLabel];
    [self.contentView addSubview:self.giftAnimView];
    [self.contentView addSubview:self.collectionButton];
}

- (void)zfAutoLayoutView {
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth-2, kDetailBannerHeight));
    }];
    
    [self.leftHoledSliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(15, kDetailBannerHeight));
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        make.height.mas_equalTo(20);
    }];
    
    [self.collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.centerY.mas_equalTo(self.countLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.giftAnimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.collectionButton);
        make.centerX.mas_equalTo(self.collectionButton);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
}

- (ZFNewBannerScrollView *)bannerView {
    if (!_bannerView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, kDetailBannerHeight);
        _bannerView = [[ZFNewBannerScrollView alloc] initWithFrame:rect];
        _bannerView.delegate = self;
        _bannerView.placeHoldImage = [UIImage imageNamed:@"loading_product"];
        _bannerView.showPageControl = NO;
    }
    return _bannerView;
}

- (UIButton *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UIButton alloc] initWithFrame:CGRectZero];
        _countLabel.backgroundColor = ZFC0x000000_05();
        _countLabel.titleLabel.textColor = [UIColor whiteColor];
        _countLabel.titleLabel.font = [UIFont systemFontOfSize:14];
        [_countLabel setContentEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
        _countLabel.layer.cornerRadius = 10;
        _countLabel.layer.masksToBounds = YES;
    }
    return _countLabel;
}

- (BigClickAreaButton *)collectionButton {
    if (!_collectionButton) {
        _collectionButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
//        _collectionButton.backgroundColor = [ZFCOLOR_WHITE colorWithAlphaComponent:0.5];
//        [_collectionButton setImage:[UIImage imageNamed:@"goodsDetail_unLike"] forState:UIControlStateNormal];
//        [_collectionButton setImage:[UIImage imageNamed:@"goodsDetail_like"] forState:UIControlStateSelected];
        [_collectionButton addTarget:self action:@selector(collectionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        _collectionButton.clickAreaRadious = 64;
//        _collectionButton.layer.cornerRadius = 18;
//        _collectionButton.layer.masksToBounds = YES;
        _collectionButton.hidden = YES; //V5.5.0优化实验
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

/// 在有些页面上添加一个透明视图到控制器.View上让事件传递到顶层, 使其能够侧滑返回
- (UIView *)leftHoledSliderView {
    if (!_leftHoledSliderView) {
        _leftHoledSliderView = [[UIView alloc] init];
        _leftHoledSliderView.backgroundColor = [UIColor clearColor];
    }
    return _leftHoledSliderView;
}

#pragma mark - <ZFBannerScrollViewDelegate>

- (void)bannerScrollView:(ZFNewBannerScrollView *)view showImageViewArray:(NSArray *)showImageViewArray didSelectItemAtIndex:(NSInteger)index
{
    if (!ZFJudgeNSArray(self.cellTypeModel.detailModel.pictures)) return;
    NSArray<GoodsDetailPictureModel*> *pictures = [[NSArray alloc] initWithArray:self.cellTypeModel.detailModel.pictures];
    NSMutableArray *tempBrowseImageArr = [NSMutableArray array];

    [pictures enumerateObjectsUsingBlock:^(GoodsDetailPictureModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            YYPhotoGroupItem *showItem = [YYPhotoGroupItem new];
            if (showImageViewArray.count > idx) {
                showItem.thumbView = showImageViewArray[idx];
            }
            NSURL *url = [NSURL URLWithString:obj.wp_image];
            showItem.largeImageURL = url;
            [tempBrowseImageArr addObject:showItem];
        }
    }];

    if (tempBrowseImageArr.count > index && tempBrowseImageArr.count > 0) {
        // 点击大图回调
        if (self.cellTypeModel.detailCellActionBlock) {
            NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
            infoDict[@"indexPath"] = self.indexPath;
            infoDict[@"isShowImageType"] = @(1);
            self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, infoDict, nil);
        }
        
        YYPhotoBrowseView *groupView = [[YYPhotoBrowseView alloc] initWithGroupItems:tempBrowseImageArr];
        groupView.blurEffectBackground = NO;
        @weakify(self)
        groupView.dismissCompletion = ^(NSInteger currentPage) {
            @strongify(self)
            [self.bannerView scrollToIndexBanner:currentPage animated:NO];
        };
        [groupView presentFromImageView:showImageViewArray[index] toContainer:self.window animated:YES completion:nil];
    }
}

- (void)didShowScrollViewPageAtIndex:(NSInteger)index {
    NSString *countTitle = [NSString stringWithFormat:@"%ld/%ld", (index+1), self.cellTypeModel.detailModel.bannerPicturesUrlArray.count];
    [self.countLabel setTitle:countTitle forState:UIControlStateNormal];
}

@end
