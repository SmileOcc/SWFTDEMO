//
//  ZFGoodsDetailOutfitsCell.m
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailOutfitsCell.h"
#import "GoodsDetailModel.h"
#import "ZFGoodsDetailOutfitsItemCell.h"
#import "ZFPostDetailSimilarGoodsCell.h"
#import "ZFLocalizationString.h"
#import "ZFGoodsDetailShowExploreAOP.h"

#import "UIView+ZFViewCategorySet.h"
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsDetailOutfitsModel.h"
#import "ZFGoodsDetailEnumDefiner.h"

static NSString *const kZFZFGoodsDetailShowExploreCellIdentifier = @"kZFZFGoodsDetailShowExploreCellIdentifier";

@interface ZFGoodsDetailOutfitsCell() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView                            *topLineLabel;
@property (nonatomic, strong) UILabel                           *titleLabel;
@property (nonatomic, strong) UICollectionView                  *collectionView;
@property (nonatomic, copy)   NSString                          *pageName; /**统计来源页面名*/
@property (nonatomic, strong) NSArray<ZFGoodsDetailOutfitsModel *> *outfitsModelArray;
@property (nonatomic, strong) ZFGoodsDetailShowExploreAOP       *analyticsAOP;
@end

@implementation ZFGoodsDetailOutfitsCell

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
    if ([self.outfitsModelArray isEqual:cellTypeModel.detailModel.outfitsModelArray]) return;
    
    self.outfitsModelArray = cellTypeModel.detailModel.outfitsModelArray;
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.outfitsModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsDetailOutfitsItemCell *outfitsCell = [ZFGoodsDetailOutfitsItemCell outfitsCellWith:collectionView forIndexPath:indexPath];
    outfitsCell.outfitsModel = self.outfitsModelArray[indexPath.row];
    
    @weakify(self);
    outfitsCell.itemButtonBlock = ^(ZFGoodsDetailOutfitsModel *outfitsModel) {
        @strongify(self);
        if (self.cellTypeModel.detailCellActionBlock) {
            self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, @(ZFOutfits_ItemButtonActionType), indexPath);
        }
    };
    return outfitsCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(110, 154);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellTypeModel.detailCellActionBlock) {
        self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, @(ZFOutfits_TouchImageActionType), indexPath);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.topLineLabel];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.topLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.height.mas_equalTo(8);
        make.leading.trailing.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLineLabel.mas_bottom).offset(14);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(14);
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(154);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLabel.text = ZFLocalizedString(@"Outfits", nil);
    }
    return _titleLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *_flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 8;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
        _collectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = NO;
    }
    return _collectionView;
}

- (UIView *)topLineLabel {
    if (!_topLineLabel) {
        _topLineLabel = [[UIView alloc] init];
        _topLineLabel.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    }
    return _topLineLabel;
}

- (ZFGoodsDetailShowExploreAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFGoodsDetailShowExploreAOP alloc] init];
    }
    return _analyticsAOP;
}
@end

