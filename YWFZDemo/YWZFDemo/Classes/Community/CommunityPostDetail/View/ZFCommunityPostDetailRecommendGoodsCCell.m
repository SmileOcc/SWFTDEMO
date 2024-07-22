//
//  ZFCommunityPostDetailRecommendGoodsCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/3/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostDetailRecommendGoodsCCell.h"
#import "ZFInitViewProtocol.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import <YYWebImage/YYWebImage.h>
#import "Constants.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFCommunityRemmondPageControl.h"
#import "SystemConfigUtils.h"
#import "ExchangeManager.h"

@interface ZFCommunityPostDetailRecommendGoodsCCell()<ZFInitViewProtocol,UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout    *flowLayout;
@property (nonatomic, strong) UICollectionView              *collectionView;

@property (nonatomic, strong) UIView                        *bottomView;
@property (nonatomic, strong) ZFCommunityRemmondPageControl *pageControl;
@property (nonatomic, strong) NSArray                       *pageArraysDatas;

@end

@implementation ZFCommunityPostDetailRecommendGoodsCCell

+ (NSString *)queryReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.pageArraysDatas = @[];
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)setSimilarSection:(ZFCommunityTopicDetailSimilarSection *)similarSection {
    _similarSection = similarSection;
    
    self.pageArraysDatas = @[];
    if (similarSection.goodsArray.count > 0) {
        
        NSInteger endPageCount = similarSection.goodsArray.count % 6;
        NSInteger aPage = endPageCount > 0 ? 1 : 0;
        NSInteger countsPage = similarSection.goodsArray.count / 6 + aPage;
        
        NSMutableArray *pageArraysDatas = [[NSMutableArray alloc] init];
        NSInteger startIndex = 0;
        NSInteger endIndex = 0;
        
        for (int i=0; i<countsPage; i++) {
            if (i == countsPage - 1) {
                endIndex = similarSection.goodsArray.count - i * 6;
            } else {
                endIndex = 6;
            }
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex,endIndex)];
            NSArray *itemArray = [[NSArray alloc] initWithArray:[similarSection.goodsArray objectsAtIndexes:indexes]];
            [pageArraysDatas addObject:itemArray];
            startIndex += 6;
        }
        self.pageArraysDatas = pageArraysDatas;
    }
    
    [self.pageControl updateDotHighColor:nil defaultColor:nil counts:self.pageArraysDatas.count currentIndex:0];

    NSInteger arIndex = self.similarSection.bottomSelectIndex;
    if ([SystemConfigUtils isRightToLeftShow] && self.pageArraysDatas.count > 1) {
        arIndex = self.pageArraysDatas.count - self.similarSection.bottomSelectIndex - 1;
    }
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(arIndex * KScreenWidth, 0) animated:NO];
    
    [self setNeedsLayout];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading);
        make.top.mas_equalTo(self.mas_top);
        make.trailing.mas_equalTo(self.mas_trailing);
        make.height.mas_equalTo(self.similarSection.itemSize.height - self.similarSection.bottomSpaceHeight);
        make.width.mas_equalTo(self.similarSection.itemSize.width);
    }];
    
    self.collectionView.scrollEnabled = self.pageArraysDatas.count > 1 ? YES : NO;
    self.bottomView.hidden = self.similarSection.bottomSpaceHeight > 0 ? NO : YES;
    [self.pageControl selectIndex:self.similarSection.bottomSelectIndex];
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self);
        make.height.mas_equalTo(self.similarSection.bottomSpaceHeight > 0 ? 30 : 0);
    }];
}


#pragma mark - Life Cycle

- (void)zfInitView {
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.bottomView];
    [self.bottomView addSubview:self.pageControl];
}

- (void)zfAutoLayoutView {
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self);
        make.height.mas_equalTo(30);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading);
        make.top.mas_equalTo(self.mas_top);
        make.trailing.mas_equalTo(self.mas_trailing);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-30);
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
    }];
}


#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pageArraysDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pageArraysDatas.count > indexPath.item) {
        ZFCommunityPostDetailRecommendGoodsItemCell *simallGoodCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityPostDetailRecommendGoodsItemCell class]) forIndexPath:indexPath];
        [simallGoodCell updateGoodArray:self.pageArraysDatas[indexPath.item]];
        @weakify(self)
        simallGoodCell.recommendClick = ^(ZFCommunityGoodsInfosModel *infosModel) {
            @strongify(self)
            if (self.recommendGoodsClick) {
                self.recommendGoodsClick(infosModel);
            }
        };
        return simallGoodCell;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.pageArraysDatas.count > indexPath.item) {
        return CGSizeMake(self.similarSection.itemSize.width, self.similarSection.itemSize.height - self.similarSection.bottomSpaceHeight);
    }
    return CGSizeZero;
}


// 两行之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

// 两个cell之间的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
       NSInteger arIndex = scrollView.contentOffset.x / KScreenWidth;
        if ([SystemConfigUtils isRightToLeftShow]) {
            arIndex = self.pageArraysDatas.count - arIndex - 1;
        }
        [self.pageControl selectIndex:arIndex];
        self.similarSection.bottomSelectIndex = arIndex;
    }
}


#pragma mark - Property Method

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
        [_collectionView registerClass:[ZFCommunityPostDetailRecommendGoodsItemCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityPostDetailRecommendGoodsItemCell class])];
    }
    return _collectionView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.hidden = YES;
    }
    return _bottomView;
}

- (ZFCommunityRemmondPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[ZFCommunityRemmondPageControl alloc] initWithFrame:CGRectZero];
        [_pageControl configeMaxWidth:14 minWidth:10 maxHeight:4 minHeight:4 limitCorner:2.5];
    }
    return _pageControl;
}
@end








#pragma mark -

@implementation ZFCommunityPostDetailRecommendGoodsItemCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *tempView;
        CGFloat width = (KScreenWidth - 4 * 12) / 3.0;
        for (int i=0; i<6; i++) {
            
            ZFCommunityPostDetailRecommendGoodsItemView *itemView = [[ZFCommunityPostDetailRecommendGoodsItemView alloc] initWithFrame:CGRectZero goodsModel:nil];
            [itemView addTarget:self action:@selector(actionItem:) forControlEvents:UIControlEventTouchUpInside];
            itemView.tag = 201920 + i;
            itemView.hidden = YES;
            [self.contentView addSubview:itemView];
            if (i < 3) {
                if (tempView) {
                    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.mas_equalTo(tempView.mas_trailing).offset(12);
                        make.top.mas_equalTo(tempView.mas_top);
                        make.bottom.mas_equalTo(tempView.mas_bottom);
                        make.width.mas_equalTo(tempView.mas_width);
                    }];
                } else {
                    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.mas_equalTo(self.mas_leading).offset(12);
                        make.top.mas_equalTo(self.mas_top);
                        make.bottom.mas_equalTo(self.mas_centerY);
                        make.width.mas_equalTo(width);
                    }];
                }
            } else if (i <= 6) {
                if (i == 3) {
                    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.mas_equalTo(self.mas_leading).offset(12);
                        make.top.mas_equalTo(self.mas_centerY);
                        make.bottom.mas_equalTo(self.mas_bottom);
                        make.width.mas_equalTo(tempView.mas_width);
                    }];
                } else {
                    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.mas_equalTo(tempView.mas_trailing).offset(12);
                        make.top.mas_equalTo(tempView.mas_top);
                        make.bottom.mas_equalTo(tempView.mas_bottom);
                        make.width.mas_equalTo(tempView.mas_width);
                    }];
                }
            }
            tempView = itemView;
        }
    }
    return self;
}

- (void)updateGoodArray:(NSArray<ZFCommunityGoodsInfosModel *> *)goodsArray{
    
    self.backgroundColor = ZFC0xFFFFFF();

    NSArray *subViews = self.contentView.subviews;
    for (UIView *subView in subViews) {
        if ([subView isKindOfClass:[ZFCommunityPostDetailRecommendGoodsItemView class]]) {
            subView.hidden = YES;
        }
    }
    if (ZFJudgeNSArray(goodsArray)) {
        for (int i=0; i< goodsArray.count; i++) {
            ZFCommunityPostDetailRecommendGoodsItemView *itemView = [self viewWithTag:201920 + i];
            if (itemView) {
                itemView.hidden = NO;
                itemView.goodModel = goodsArray[i];
            }
        }
    }
}

- (void)actionItem:(ZFCommunityPostDetailRecommendGoodsItemView *)sender {
    if (self.recommendClick) {
        self.recommendClick(sender.goodModel);
    }
}
@end



@interface ZFCommunityPostDetailRecommendGoodsItemView()

@property (nonatomic, strong) UIImageView        *goodsImageView;
@property (nonatomic, strong) UILabel            *priceLabel;
@property (nonatomic, strong) UIButton           *similarTagButton;

@end

@implementation ZFCommunityPostDetailRecommendGoodsItemView

- (instancetype)initWithFrame:(CGRect)frame goodsModel:(ZFCommunityGoodsInfosModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.goodsImageView];
        [self addSubview:self.priceLabel];
        [self addSubview:self.similarTagButton];
        
        [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(self.goodsImageView.mas_width).multipliedBy(145.0 / 109.0);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.goodsImageView.mas_bottom).offset(8.0);
            make.height.mas_equalTo(14.0);
        }];
        
        [self.similarTagButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(6);
            make.trailing.offset(0);
            make.height.mas_equalTo(18);
        }];
        
        if (model) {
            self.goodModel = model;
        }
    }
    return self;
}

- (void)setGoodModel:(ZFCommunityGoodsInfosModel *)goodModel {
    _goodModel = goodModel;
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodModel.goodsImg]
                                placeholder:[UIImage imageNamed:@"community_loading_product"]];
    
    self.priceLabel.text = [ExchangeManager transforPrice:goodModel.shopPrice];

    self.similarTagButton.hidden = !goodModel.isSame;
}

#pragma mark - getter/setter
- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] init];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.layer.masksToBounds = YES;
    }
    return _goodsImageView;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font          = [UIFont boldSystemFontOfSize:14.0];
        _priceLabel.textColor     = [UIColor colorWithHex:0x2d2d2d];
    }
    return _priceLabel;
}

- (UIButton *)similarTagButton{
    if (!_similarTagButton) {
        _similarTagButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIEdgeInsets edge = UIEdgeInsetsMake(0, 10, 0, 0);
//        [_similarTagButton setBackgroundImage:[[UIImage imageNamed:@"topbg"] resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_similarTagButton setTitle:ZFLocalizedString(@"community_post_simalar", nil) forState:UIControlStateNormal];
        _similarTagButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_similarTagButton setTitleColor:ZFC0xFE5269() forState:UIControlStateNormal];
        _similarTagButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        _similarTagButton.layer.cornerRadius = 2.0f;
        _similarTagButton.layer.borderColor = ZFC0xFE5269().CGColor;
        _similarTagButton.layer.borderWidth = 1.0;
        _similarTagButton.backgroundColor = ZFC0xFFFFFF();
        _similarTagButton.hidden = YES;
    }
    return _similarTagButton;
}

@end
