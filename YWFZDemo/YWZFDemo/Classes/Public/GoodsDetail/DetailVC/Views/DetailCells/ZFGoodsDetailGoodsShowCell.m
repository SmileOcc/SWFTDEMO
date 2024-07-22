//
//  ZFGoodsDetailGoodsShowCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailGoodsShowCell.h"
#import "GoodsDetailModel.h"
#import "ZFGoodsDetailShowListCell.h"
#import "ZFPostDetailSimilarGoodsCell.h"
#import "ZFLocalizationString.h"
#import "ZFGoodsDetailShowExploreAOP.h"

#import "UIView+ZFViewCategorySet.h"
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsDetailEnumDefiner.h"

static NSString *const kZFZFGoodsDetailShowExploreCellIdentifier = @"kZFZFGoodsDetailShowExploreCellIdentifier";

@interface ZFGoodsDetailGoodsShowCell() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView                            *topLineView;
@property (nonatomic, strong) UILabel                           *titleLabel;
@property (nonatomic, strong) UIImageView                       *arrowImageView;
@property (nonatomic, strong) UICollectionViewFlowLayout        *flowLayout;
@property (nonatomic, strong) UICollectionView                  *collectionView;
@property (nonatomic, copy) NSString                            *pageName; /**统计来源页面名*/
@property (nonatomic, strong) NSArray<GoodsShowExploreModel *> *showExploreModelArray;
@property (nonatomic, strong) ZFGoodsDetailShowExploreAOP       *analyticsAOP;
@end

@implementation ZFGoodsDetailGoodsShowCell

@synthesize cellTypeModel = _cellTypeModel;

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];
        [self zfInitView];
        [self zfAutoLayoutView];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - setter

- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    if ([self.showExploreModelArray isEqual:cellTypeModel.detailModel.showExploreModelArray]) return;

    self.showExploreModelArray = cellTypeModel.detailModel.showExploreModelArray;
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.showExploreModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GoodsShowExploreModel *showExploreModel = self.showExploreModelArray[indexPath.row];
    ZFGoodsDetailShowListCell *showsCell = [ZFGoodsDetailShowListCell ShowListCellWith:collectionView forIndexPath:indexPath];
    showsCell.model = showExploreModel;
    return showsCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = 90;
    CGFloat height = 120;
    CGFloat showHeight = (height + 16);
    return CGSizeMake(width, showHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    GoodsShowExploreModel *model = self.showExploreModelArray[indexPath.row];
    if (self.cellTypeModel.detailCellActionBlock) {
        self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, @(ZFShow_TouchImageAcAtionType), indexPath);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.topLineView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImageView];
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(8);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLineView.mas_bottom);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-(40+16));;
        make.height.mas_equalTo(kCellDefaultHeight);
    }];

    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
}

- (void)tagShowArrowAction {
    self.titleLabel.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        if (CGRectGetHeight(self.frame) == 188) {
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        } else {
            self.arrowImageView.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        self.titleLabel.userInteractionEnabled = YES;
        if (self.cellTypeModel.detailCellActionBlock) {
            self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, @(ZFShow_ArrowAcAtionType), nil);
        }
    }];
}

#pragma mark - getter

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLineView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    }
    return _topLineView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _titleLabel.text = ZFLocalizedString(@"MyStylePage_SubVC_Shows", nil);
//        @weakify(self)
//        [_titleLabel addTapGestureWithComplete:^(UIView * _Nonnull view) {
//            @strongify(self)
//            [self tagShowArrowAction];
//        }];
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        // 设计所暂时不要箭头
//        _arrowImageView.image = [UIImage imageNamed:@"size_arrow_right"];;
//        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 8;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = YES;
        _collectionView.alwaysBounceHorizontal = NO;
    }
    return _collectionView;
}

- (ZFGoodsDetailShowExploreAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFGoodsDetailShowExploreAOP alloc] init];
    }
    return _analyticsAOP;
}
@end

