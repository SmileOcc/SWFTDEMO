//
//  PostPhotoCell.m
//  ZZZZZ
//
//  Created by YW on 16/11/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityShowPostPhotoCell.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
@interface ZFCommunityShowPostPhotoCell ()
@end

@implementation ZFCommunityShowPostPhotoCell

+ (ZFCommunityShowPostPhotoCell *)postPhotoCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFCommunityShowPostPhotoCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityShowPostPhotoCell class])];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityShowPostPhotoCell class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _photoView = [[YYAnimatedImageView alloc] init];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.clipsToBounds = YES;
        _photoView.userInteractionEnabled = YES;
        [self.contentView addSubview:_photoView];
        [_photoView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.edges.equalTo(self.contentView);
        }];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.backgroundColor = [UIColor clearColor];
        [_deleteButton setBackgroundImage:[UIImage imageNamed:@"album_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [_photoView addSubview:_deleteButton];
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.trailing.equalTo(self.photoView);
            make.size.mas_equalTo(CGSizeMake(16, 16));
        }];
        
        [self.contentView addSubview:self.addImageView];
        [self.contentView addSubview:self.addLabel];
        
        [self.addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.top.mas_equalTo(self.contentView.mas_top).offset(16);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        
        [self.addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(6);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-6);
            make.top.mas_equalTo(self.addImageView.mas_bottom).offset(4);
        }];
        
        //添加长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveCollectionViewCell:)];
        [self addGestureRecognizer:longPress];
        
        self.contentView.layer.cornerRadius = 2;
        self.contentView.layer.masksToBounds = YES; 
    }
    return self;
}

-(void)moveCollectionViewCell:(UILongPressGestureRecognizer *)gesture {
    if (self.longPressBlock) {
        self.longPressBlock(gesture);
    }
}


- (void)setAssetModel:(PYAssetModel *)assetModel {
    _assetModel = assetModel;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.photoView.image = assetModel.originImage;
    self.photoView.hidden = NO;
    if (self.isNeedHiddenAddView) {
        self.photoView.hidden = YES;
    }
    self.deleteButton.hidden = NO;
    self.addImageView.hidden = YES;
    self.addLabel.hidden = YES;
    
    if (assetModel.screenshotImage) {
        self.photoView.image = assetModel.screenshotImage;
    } else if (assetModel.originImage) {
        self.photoView.image = assetModel.originImage;
    } else {
        self.photoView.image = assetModel.delicateImage ? assetModel.delicateImage : assetModel.degradedImage;
    }
}

- (void)setAddPhotoImage:(UIImage *)image {
    self.contentView.backgroundColor = ColorHex_Alpha(0xF2F2F2, 1.0);
    if (self.isNeedHiddenAddView) {
        self.contentView.backgroundColor = ZFC0xFFFFFF();
        self.addImageView.hidden = YES;
        self.addLabel.hidden = YES;
    } else {
        self.addImageView.hidden = NO;
        self.addLabel.hidden = NO;
    }
    self.photoView.hidden = YES;
    self.deleteButton.hidden = YES;
}


- (void)deletePhoto:(UIButton *)sender {
    if (self.deletePhotoBlock) {
        self.deletePhotoBlock(self.assetModel);
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.photoView.image = nil;
    self.photoView.hidden = NO;
    self.deleteButton.hidden = NO;
}


- (UIImageView *)addImageView {
    if (!_addImageView) {
        _addImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"album_add"]];
        _addImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _addImageView;
}

- (UILabel *)addLabel {
    if (!_addLabel) {
        _addLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addLabel.textColor = ZFC0xCCCCCC();
        _addLabel.font = [UIFont systemFontOfSize:12];
        _addLabel.textAlignment = NSTextAlignmentCenter;
        _addLabel.text = ZFLocalizedString(@"Community_AddPhoto", nil);
    }
    return _addLabel;
}
@end
