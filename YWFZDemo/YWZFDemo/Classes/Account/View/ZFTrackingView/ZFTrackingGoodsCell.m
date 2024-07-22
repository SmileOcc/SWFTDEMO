//
//  ZFTrackingGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFTrackingGoodsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFTrackingGoodsModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+LayoutMethods.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFTrackingGoodsCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UIView        *bgView;
@property (nonatomic, strong) UIImageView   *goodsImageView;
@property (nonatomic, strong) UILabel       *detailLabel;
@property (nonatomic, strong) UILabel       *countLabel;
@end

@implementation ZFTrackingGoodsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self zfInitView];
        [self zfAutoLayoutView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.goodsImageView];
    [self.bgView addSubview:self.detailLabel];
    [self.bgView addSubview:self.countLabel];
    
}

- (void)zfAutoLayoutView {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(0);
        make.trailing.bottom.equalTo(self.contentView).offset(0);
    }];
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat width = 60;
        CGFloat height = 80 * ScreenWidth_SCALE;
        make.leading.top.equalTo(self.bgView).offset(12);
        make.size.mas_equalTo(CGSizeMake(width, height));
        make.bottom.mas_equalTo(self.bgView.mas_bottom).mas_offset(-12);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.goodsImageView.mas_trailing).offset(8);
        make.top.equalTo(self.goodsImageView.mas_top);
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.goodsImageView.mas_trailing).offset(8);
        make.bottom.equalTo(self.goodsImageView.mas_bottom);
    }];
}

#pragma mark - Public Methods
+ (NSString *)setIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Setter
- (void)setModel:(ZFTrackingGoodsModel *)model {
    _model = model;
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:model.goods_thumb]
                                    placeholder:ZFImageWithName(@"index_loading")
                                        options:YYWebImageOptionAvoidSetImage
                                     completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                         if (image && stage == YYWebImageStageFinished) {
                                             int width = image.size.width;
                                             int height = image.size.height;
                                             CGFloat scale = (height / width) / (self.goodsImageView.size.height / self.goodsImageView.size.width);
                                             if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                                                 self.goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
                                                 self.goodsImageView.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                                             } else { // 高图只保留顶部
                                                 self.goodsImageView.contentMode = UIViewContentModeScaleToFill;
                                                 self.goodsImageView.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                                             }
                                             self.goodsImageView.image = image;
                                         }
                                     }];
    
    self.detailLabel.text = ZFToString(model.goods_title);
    
    NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
    NSMutableAttributedString *symbolString = [[NSMutableAttributedString alloc]initWithString:@"x "];
    NSAttributedString *numberString = [[NSMutableAttributedString alloc]initWithString:ZFToString(model.goods_num)];
    [orginalAttributString appendAttributedString: symbolString];
    [orginalAttributString appendAttributedString: numberString];
    self.countLabel.attributedText = orginalAttributString;
    
}

#pragma mark - Getter
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    }
    return _bgView;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] init];
        
    }
    return _goodsImageView;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:14.0f];
        _detailLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.numberOfLines = 0;
        _detailLabel.preferredMaxLayoutWidth = KScreenWidth - 128;
    }
    return _detailLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = ZFCOLOR(51, 51, 51, 1);
    }
    return _countLabel;
}

@end
