//
//  ZFCommunityAlbumCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityAlbumCCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ExchangeManager.h"
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "PYAblum.h"

@interface ZFCommunityAlbumCCell()
<
ZFInitViewProtocol
>

@property (nonatomic,assign) long imageID;

@end

@implementation ZFCommunityAlbumCCell

+ (ZFCommunityAlbumCCell *)albumPhotoCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFCommunityAlbumCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityAlbumCCell class])];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityAlbumCCell class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    [self.contentView addSubview:self.addPhotoImageView];
    [self.contentView addSubview:self.photoImageView];
    [self.contentView addSubview:self.markSelectView];
    [self.contentView addSubview:self.selectButton];
}

- (void)zfAutoLayoutView {
    
    [self.addPhotoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.markSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
        make.top.mas_equalTo(self.mas_top).offset(8);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

- (void)actionSelect:(UIButton *)sender {
    if (self.selectBlock) {
        self.selectBlock(self.assetModel);
    }
}
#pragma mark - Property Method

- (void)setCameraImage:(UIImage *)image {
    self.addPhotoImageView.image = image;
    self.photoImageView.hidden = YES;
    self.markSelectView.hidden = YES;
    self.selectButton.hidden = YES;
    self.addPhotoImageView.hidden = NO;
}


- (void)showSelectMaskView:(BOOL)isShow {
    self.markSelectView.hidden = !isShow;
}
- (void)setAssetModel:(PYAssetModel *)assetModel {
    _assetModel = assetModel;
    
    
    self.selectButton.hidden = NO;
    self.photoImageView.hidden = NO;
    self.addPhotoImageView.hidden = YES;
    
    __weak typeof(self)weakSelf = self;
    __weak typeof([PYAblum defaultAblum])ablum = [PYAblum defaultAblum];
    if (!assetModel.delicateImage) {
        [ablum getAssetWithImageWidth:self.imageWidth andModel:assetModel andBlock:^(PYAssetModel *assetFirstModel) {
            if (weakSelf.imageID == assetFirstModel.imageRequestID) {
                [weakSelf setDataWithImage:assetModel];
                [weakSelf setDataWithButton:assetFirstModel];
//                [weakSelf setData:assetFirstModel];
            }
        } andBlock:^(PYAssetModel *assetLastModel) {
            if (weakSelf.imageID == assetLastModel.imageRequestID) {
                [weakSelf setDataWithImage:assetModel];
                [weakSelf setDataWithButton:assetLastModel];
//                [weakSelf setData:assetLastModel];
            }
        }];
    }
    
    self.imageID = assetModel.imageRequestID;
    [self setDataWithImage:assetModel];
    [self setDataWithButton:assetModel];
    
}

- (void)setDataWithImage:(PYAssetModel *)model {
    if (model.delicateImage) {
        self.photoImageView.image = model.delicateImage;
    }else{
        self.photoImageView.image = model.degradedImage;
    }
}

- (void)setDataWithButton:(PYAssetModel *)model {
    NSString *title = [NSString stringWithFormat:@"%ld",(long)model.orderNumber];
    if (model.orderNumber <= 0) {
        title = @"";
    }
    [self.selectButton setTitle:title forState:UIControlStateNormal];
    self.selectButton.transform = CGAffineTransformInvert(self.selectButton.transform);
    self.selectButton.selected = model.isSelected;
    [self changeButtonStatus:self.selectButton];
    
}

- (void)changeButtonStatus: (UIButton *)button {
    if (button.selected) {
        button.backgroundColor = ZFC0xFE5269();
    }else{
        button.backgroundColor = ZFC0x000000_04();
    }
}

- (UIImageView *)addPhotoImageView {
    if (!_addPhotoImageView) {
        _addPhotoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _addPhotoImageView.hidden = YES;
        _addPhotoImageView.contentMode = UIViewContentModeCenter;
        _addPhotoImageView.backgroundColor = ZFC0x2D2D2D();

    }
    return _addPhotoImageView;
}
- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.layer.masksToBounds = YES;
    }
    return _photoImageView;
}


- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton addTarget:self action:@selector(actionSelect:) forControlEvents:UIControlEventTouchUpInside];
        _selectButton.layer.cornerRadius = 10;
        _selectButton.layer.borderColor = ZFC0xFFFFFF().CGColor;
        _selectButton.layer.borderWidth = 1;
        _selectButton.backgroundColor = ZFC0x000000_04();
        [_selectButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        _selectButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _selectButton;
}

- (UIView *)markSelectView {
    if (!_markSelectView) {
        _markSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.imageWidth, self.imageWidth)];
        _markSelectView.backgroundColor = ZFC0xFE5269_A(0.2);
        _markSelectView.layer.borderWidth = 2;
        _markSelectView.layer.borderColor = ZFC0xFE5269().CGColor;
    }
    return _markSelectView;
}
@end
