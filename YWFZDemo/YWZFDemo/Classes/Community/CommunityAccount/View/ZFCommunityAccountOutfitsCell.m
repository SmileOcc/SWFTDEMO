


//
//  ZFCommunityAccountOutfitsCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountOutfitsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityOutfitsModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFCommunityAccountOutfitsCell () <ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView           *outfitsImageView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *creatByLabel;
@property (nonatomic, strong) BigClickAreaButton    *collectionButton;

@end

@implementation ZFCommunityAccountOutfitsCell
- (void)prepareForReuse {
    [super prepareForReuse];
    self.outfitsImageView.image = nil;
    self.titleLabel.text = nil;
    self.creatByLabel.text = nil;
    self.collectionButton.selected = NO;
}

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)addCollectionButtonAction:(UIButton *)sender {
    if (self.communityAccountOutfitsLikeCompletionHandler) {
        self.communityAccountOutfitsLikeCompletionHandler(self.model);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    
    [self.contentView addSubview:self.outfitsImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.creatByLabel];
    [self.contentView addSubview:self.collectionButton];
}

- (void)zfAutoLayoutView {
    [self.outfitsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(8);
        make.top.mas_equalTo(self.contentView.mas_top).offset(8);
        make.size.mas_equalTo(CGSizeMake(152 * ScreenWidth_SCALE, 152 * ScreenWidth_SCALE));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.outfitsImageView.mas_bottom).offset(16);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(8);
        make.trailing.mas_equalTo(self.collectionButton.mas_leading).offset(-4);
    }];
    
    [self.creatByLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(8);
        make.trailing.mas_equalTo(self.collectionButton.mas_leading).offset(-4);
    }];
    
    [self.collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.centerY.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
    }];
}

#pragma mark - setter
- (void)setModel:(ZFCommunityOutfitsModel *)model {
    _model = model;
    [self.outfitsImageView yy_setImageWithURL:[NSURL URLWithString:_model.picInfo[@"big_pic"]]
                                  placeholder:ZFImageWithName(@"loading_cat_list")];
    self.titleLabel.text = _model.reviewTitle;
    self.creatByLabel.text = [NSString stringWithFormat:@"by %@", _model.nikename];
    self.collectionButton.selected = [_model.liked boolValue];
}

#pragma mark - getter
- (UIImageView *)outfitsImageView {
    if (!_outfitsImageView) {
        _outfitsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _outfitsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _outfitsImageView.clipsToBounds = YES;
    }
    return _outfitsImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
    }
    return _titleLabel;
}

- (UILabel *)creatByLabel {
    if (!_creatByLabel) {
        _creatByLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _creatByLabel.font = [UIFont systemFontOfSize:12];
        _creatByLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
    }
    return _creatByLabel;
}

- (BigClickAreaButton *)collectionButton {
    if (!_collectionButton) {
        _collectionButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        _collectionButton.clickAreaRadious = 44;
        [_collectionButton setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
        [_collectionButton setImage:[UIImage imageNamed:@"collection_on"] forState:UIControlStateSelected];
        [_collectionButton addTarget:self action:@selector(addCollectionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collectionButton;
}

@end
