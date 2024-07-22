//
//  ZFSizeSelectSizeTipsView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/24.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSizeSelectSizeTipsView.h"
#import "ZFInitViewProtocol.h"
#import "UILabel+HTML.h"
#import "ZFThemeManager.h"
#import "UIView+LayoutMethods.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "YYText.h"
#import "SystemConfigUtils.h"
#import "ZFSizeSelectSizeTipsTextCell.h"
#import "GoodsDetialSizeModel.h"

@interface ZFSizeSelectSizeTipsView() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) YYLabel           *tipsLabel;
@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) UIImageView       *scrollTipImageView;
@property (nonatomic, strong) UILabel           *unitLabel;
@property (nonatomic, strong) ZFSizeTipsArrModel *sizeTipsArrModel;
@end

@implementation ZFSizeSelectSizeTipsView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.clipsToBounds = YES;
    }
    return self;
}

+ (CGFloat)tipsCanCalculateWidth {
    return KScreenWidth - 2 * kSizeSelectLeftSpace - 2 * kSizeSelectSizeSpace;
}

+ (CGFloat)tipsTopBottomSpace {
    return 12 + 2 * kSizeSelectSizeSpace;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tipsLabel];
    [self addSubview:self.collectionView];
    [self addSubview:self.scrollTipImageView];
    [self addSubview:self.unitLabel];
}

- (void)zfAutoLayoutView {
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(12);
        make.leading.mas_equalTo(self.mas_leading).offset(kSizeSelectLeftSpace);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-kSizeSelectLeftSpace);
        //make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(12);
        make.leading.mas_equalTo(self.mas_leading).offset(kSizeSelectLeftSpace);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-kSizeSelectLeftSpace);
        make.height.mas_equalTo(56);
    }];
    
    [self.scrollTipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.collectionView.mas_bottom).offset(-4);
        make.trailing.mas_equalTo(self.collectionView.mas_trailing).offset(5);
        make.size.mas_equalTo(CGSizeMake(16, 20));
    }];
    
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(4);
        make.leading.trailing.mas_equalTo(self.tipsLabel);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self.sizeTipsArrModel isKindOfClass:[ZFSizeTipsArrModel class]]) {
        if (self.collectionView.contentSize.width > (KScreenWidth - kSizeSelectLeftSpace * 2)) {
            self.scrollTipImageView.hidden = NO;
        } else {
            self.scrollTipImageView.hidden = YES;
        }
    }
}

#pragma mark - setter
- (void)setSizeTipsArrModel:(ZFSizeTipsArrModel *)sizeTipsArrModel tipsInfo:(NSString *)tipsInfo
{
    if ([self.sizeTipsArrModel isEqual:sizeTipsArrModel]) return;
    self.sizeTipsArrModel = sizeTipsArrModel;
    
    CGFloat offsetY = 12;
    if ([sizeTipsArrModel isKindOfClass:[ZFSizeTipsArrModel class]]) {
        self.tipsLabel.text = @"";
        self.tipsLabel.hidden = YES;
        self.collectionView.hidden = NO;
        self.unitLabel.hidden = NO;
        self.unitLabel.text = ZFToString(sizeTipsArrModel.str_unit);
        [self.collectionView reloadData];
        offsetY = -8; // 此情况不显示时,只需要设置空值 顶部商详偏移即可
        
    } else {
        self.tipsLabel.hidden = NO;
        self.collectionView.hidden = YES;
        self.unitLabel.hidden = YES;
        self.unitLabel.text = @"";
        self.tipsLabel.text = ZFToString(tipsInfo);
        offsetY = 12;
    }
    [self.tipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(offsetY);
    }];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sizeTipsArrModel.tipsTextModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sizeTipsArrModel.tipsTextModelArray.count > indexPath.item) {
        ZFSizeSelectSizeTipsTextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFSizeSelectSizeTipsTextCell class]) forIndexPath:indexPath];
        cell.tipsTextModel = self.sizeTipsArrModel.tipsTextModelArray[indexPath.item];
        return cell;
    } else { // 防止异常
        return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sizeTipsArrModel.tipsTextModelArray.count > indexPath.item) {
        ZFSizeTipsTextModel *tipsTextModel = self.sizeTipsArrModel.tipsTextModelArray[indexPath.item];
        return CGSizeMake(tipsTextModel.titleWith, 56);
    } else { // 防止异常
        return CGSizeZero;
    }
}

#pragma mark - getter

- (YYLabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.backgroundColor = ZFCOLOR(247, 247, 247, 1);
        _tipsLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _tipsLabel.font = ZFFontSystemSize(12);
//        _tipsLabel.layer.borderColor = ZFCOLOR(236, 236, 236, 1).CGColor;
//        _tipsLabel.layer.borderWidth = 1.0;
        _tipsLabel.textContainerInset = UIEdgeInsetsMake(kSizeSelectSizeSpace, kSizeSelectSizeSpace, kSizeSelectSizeSpace, kSizeSelectSizeSpace);
        _tipsLabel.numberOfLines = 2;
        _tipsLabel.preferredMaxLayoutWidth = KScreenWidth - 16 *2;
    }
    return _tipsLabel;
}

- (UILabel *)unitLabel {
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _unitLabel.backgroundColor = [UIColor whiteColor];
        _unitLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _unitLabel.font = ZFFontSystemSize(12);
    }
    return _unitLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        //_collectionView.bounces = NO;
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[ZFSizeSelectSizeTipsTextCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFSizeSelectSizeTipsTextCell class])];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            self.collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
    }
    return _collectionView;
}

- (UIImageView *)scrollTipImageView {
    if (!_scrollTipImageView) {
        _scrollTipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_size_scroll_tip"]];
        _scrollTipImageView.hidden = YES;
    }
    return _scrollTipImageView;
}

@end
