//
//  ZFSearchMatchCollectionViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/12/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchMatchCollectionViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "SystemConfigUtils.h"
#import "JumpModel.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYAnimatedImageView.h>
#import "Constants.h"
#import "NSStringUtils.h"
#import "UIColor+ExTypeChange.h"

@interface ZFSearchMatchCollectionViewCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel                   *resultLabel;
@property (nonatomic, strong) YYAnimatedImageView       *hotImageView;
@end

@implementation ZFSearchMatchCollectionViewCell
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFC0xF7F7F7();
//    self.contentView.layer.borderColor = ZFCOLOR(221, 221, 221, 1.f).CGColor;
//    self.contentView.layer.borderWidth = .5f;
    self.contentView.layer.cornerRadius = 2;
    self.contentView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.hotImageView];
    [self.contentView addSubview:self.resultLabel];
}

- (void)zfAutoLayoutView {
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsZero);
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.hotImageView.image = nil;
    self.resultLabel.text = nil;
    self.resultLabel.textColor = ZFCOLOR(102, 102, 102, 1.f);
}

#pragma mark - setter
- (void)setModel:(JumpModel *)model {
    _model = model;
    
    self.resultLabel.textColor = [UIColor colorWithHexString:model.color defaultColor:ZFCOLOR(102, 102, 102, 1.f)];
    self.resultLabel.text = model.name;
    
    BOOL showHotImage = model.img_is_show;
    self.hotImageView.hidden = !showHotImage;
    if (showHotImage) {
        self.resultLabel.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        [self.hotImageView yy_setImageWithURL:[NSURL URLWithString:NullFilter(model.imgSrc)] placeholder:[UIImage imageNamed:@"hot"] options:kNilOptions completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            
        }];
        [self.hotImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.leading.mas_equalTo(5);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        [self.resultLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.hotImageView.mas_trailing).offset(2);
            make.top.trailing.bottom.mas_equalTo(0);
        }];
    } else {
        self.resultLabel.textAlignment = NSTextAlignmentCenter;
        [self.resultLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsZero);
        }];
    }
}

- (void)setShowHotImage:(BOOL)showHotImage {
    _showHotImage = showHotImage;
    self.hotImageView.hidden = !showHotImage;
    if (showHotImage) {
        self.resultLabel.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        [self.hotImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.leading.mas_equalTo(5);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        [self.resultLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.hotImageView.mas_trailing).offset(2);
            make.top.trailing.bottom.mas_equalTo(0);
        }];
    } else {
        self.resultLabel.textAlignment = NSTextAlignmentCenter;
        [self.resultLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsZero);
        }];
    }
}

- (void)setSearchKey:(NSString *)searchKey {
    _searchKey = searchKey;
    self.resultLabel.text = _searchKey;
}

#pragma mark - getter
- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _resultLabel.textColor = ZFCOLOR(102, 102, 102, 1.f);
        _resultLabel.font = [UIFont systemFontOfSize:14];
//        _resultLabel.layer.borderColor = ZFCOLOR(221, 221, 221, 1.f).CGColor;
//        _resultLabel.layer.borderWidth = .5f;
        _resultLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _resultLabel;
}

- (YYAnimatedImageView *)hotImageView {
    if (!_hotImageView) {
        _hotImageView = [[YYAnimatedImageView alloc] init];
        _hotImageView.contentMode = UIViewContentModeScaleAspectFit;
        _hotImageView.hidden = YES;
    }
    return _hotImageView;
}

@end
