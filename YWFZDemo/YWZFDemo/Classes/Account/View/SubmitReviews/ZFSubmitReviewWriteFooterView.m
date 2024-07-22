

//
//  ZFSubmitReviewWriteFooterView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSubmitReviewWriteFooterView.h"
#import "ZFInitViewProtocol.h"
#import "ZFSubmitReviewAddImageCell.h"
#import "ZFSubmitReviewAddImageTipsView.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "SystemConfigUtils.h"

static NSString *const kZFSubmitReviewAddImageCellIdentifier = @"kZFSubmitReviewAddImageCellIdentifier";
static NSString *const kZFSubmitReviewAddImageTipsViewIdentifier = @"kZFSubmitReviewAddImageTipsViewIdentifier";

@interface ZFSubmitReviewWriteFooterView() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout            *flowLayout;
@property (nonatomic, strong) UICollectionView                      *collectionView;
@property (nonatomic, strong) UIView                                *lineView;
@property (nonatomic, strong) UIButton                              *agreePostButton;
@property (nonatomic, strong) UILabel                               *tipsLabel;
@property (nonatomic, strong) UIView                                *bottomLineView;
@property (nonatomic, strong) UIButton                              *submitButton;
@property (nonatomic, strong) UILabel                               *pointTipsLabel;
@end

@implementation ZFSubmitReviewWriteFooterView
#pragma mark - init methods
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)submitButtonAction:(UIButton *)sender {
    if (self.submitReviewSubmitCompletionHandler) {
        self.submitReviewSubmitCompletionHandler();
    }
}

- (void)agreePostButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.submitReviewSyncCommunityCompletionHandler) {
        self.submitReviewSyncCommunityCompletionHandler(sender.selected);
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosArray.count == 0 ? 1 : self.photosArray.count == 3 ? 3 : self.photosArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFSubmitReviewAddImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFSubmitReviewAddImageCellIdentifier forIndexPath:indexPath];
    if (self.photosArray.count < 3) {
        if (indexPath.item == self.photosArray.count) {
            cell.type = SubmitReviewAddImageTypeAdd;
        } else {
            cell.image = self.photosArray[indexPath.item];
            cell.type = SubmitReviewAddImageTypeNormal;
        }
    } else {
        cell.image = self.photosArray[indexPath.item];
        cell.type = SubmitReviewAddImageTypeNormal;
    }
    @weakify(self);
    cell.submitReviewDeleteImageCompletionHandler = ^{
        @strongify(self);
        NSInteger index = indexPath.item;
        if (self.submitReviewDeletePhotoCompletionHandler) {
            self.submitReviewDeletePhotoCompletionHandler(index);
        }
        [self.collectionView reloadData];

    };
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
//        return nil;
//    }
//    ZFSubmitReviewAddImageTipsView *tipsView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kZFSubmitReviewAddImageTipsViewIdentifier forIndexPath:indexPath];
//
//    return tipsView;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.submitReviewChoosePhotosCompletionHandler) {
        self.submitReviewChoosePhotosCompletionHandler();
    }
}

#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (self.photosArray.count > 0) {
        return CGSizeZero;
    }
    return CGSizeMake(KScreenWidth - 44, 80);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.submitButton];
    [self.contentView addSubview:self.pointTipsLabel];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(80);
    }];
    
    [self.pointTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(10);
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(6);
        make.height.mas_offset(20);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(.5f);
        make.top.mas_equalTo(self.pointTipsLabel.mas_bottom).offset(10);
    }];
    
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.height.mas_equalTo(44);
    }];
}

#pragma mark - setter
- (void)setPhotosArray:(NSMutableArray *)photosArray {
    _photosArray = photosArray;
    [self.collectionView reloadData];
    [self.agreePostButton removeFromSuperview];
    [self.tipsLabel removeFromSuperview];
    [self.bottomLineView removeFromSuperview];
    self.agreePostButton.selected = !self.syncCommunity;
    if (_photosArray.count > 0) {
        [self.contentView addSubview:self.agreePostButton];
        [self.agreePostButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.centerY.mas_equalTo(self.lineView.mas_bottom).offset(24);
        }];
        [self.contentView addSubview:self.tipsLabel];
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.agreePostButton.mas_trailing).offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.agreePostButton);
        }];
        
        [self.contentView addSubview:self.bottomLineView];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.height.mas_equalTo(.5f);
            make.top.mas_equalTo(self.agreePostButton.mas_bottom).offset(15);
        }];
    }
}

#pragma mark - getter
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 16;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        _flowLayout.itemSize = CGSizeMake(80, 80);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor =  ZFCOLOR_WHITE;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.directionalLockEnabled = YES;
        _collectionView.scrollEnabled = NO;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
        [_collectionView registerClass:[ZFSubmitReviewAddImageCell class] forCellWithReuseIdentifier:kZFSubmitReviewAddImageCellIdentifier];
        [_collectionView registerClass:[ZFSubmitReviewAddImageTipsView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kZFSubmitReviewAddImageTipsViewIdentifier];
    }
    return _collectionView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _lineView;
}

- (UIButton *)agreePostButton {
    if (!_agreePostButton) {
        _agreePostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreePostButton setImage:[UIImage imageNamed:@"review_order_no"] forState:UIControlStateNormal];
        [_agreePostButton setImage:[UIImage imageNamed:@"review_order_done"] forState:UIControlStateSelected];
        _agreePostButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_agreePostButton setTitleColor:ZFCOLOR(153, 153, 153, 1.f) forState:UIControlStateNormal];
        [_agreePostButton addTarget:self action:@selector(agreePostButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _agreePostButton.selected = YES;
    }
    return _agreePostButton;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.text = ZFLocalizedString(@"OrderReviewAgreeToZMe", nil);
    }
    return _tipsLabel;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _bottomLineView;
}

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitButton.backgroundColor = ZFC0x2D2D2D();
        [_submitButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_submitButton setTitle:ZFLocalizedString(@"WriteReview_Submit", nil) forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _submitButton.contentEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 12);
        [_submitButton addTarget:self action:@selector(submitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

-(UILabel *)pointTipsLabel
{
    if (!_pointTipsLabel) {
        _pointTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont systemFontOfSize:12];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"ZFOrderReview_AddImageTips", nil);
            label;
        });
    }
    return _pointTipsLabel;
}

@end
