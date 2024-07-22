//
//  ParentCell.m
//  ListPageViewController
//
//  Created by YW on 26/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryParentCell.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface CategoryParentCell ()
@property (nonatomic, strong) UIImageView   *categoryImgView;
@property (nonatomic, strong) YYLabel       *titleLabel;
@end

@implementation CategoryParentCell
#pragma mark - Init Method
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSubViews];
        [self autoLayoutSubViews];
    }
    return self;
}

#pragma mark - Initialize
-(void)configureSubViews {
    self.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.categoryImgView];
    [self.contentView addSubview:self.titleLabel];
}

-(void)autoLayoutSubViews {
    [self.categoryImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat width = (KScreenWidth - 12 - 12 - 7) / 2;
        CGFloat height = 120 * ScreenWidth_SCALE;
        make.top.leading.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(width,height));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
    }];
}

#pragma mark - Setter
-(void)setModel:(CategoryNewModel *)model {
    _model = model;
    [self.categoryImgView yy_setImageWithURL:[NSURL URLWithString:model.cat_pic]
                                placeholder:[UIImage imageNamed:@"index_loading"]
                                     options:YYWebImageOptionAvoidSetImage
                                  completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                      if (image && stage == YYWebImageStageFinished) {
                                          self.categoryImgView.image = image;
                                      }
                                  }];
    
    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:model.cat_name];
    titleAttribute.yy_font = [UIFont boldSystemFontOfSize:20];
    titleAttribute.yy_color = ZFCOLOR(255, 255, 255, 1);
    titleAttribute.yy_alignment = NSTextAlignmentCenter;
    YYTextShadow *shadow = [YYTextShadow new];
    shadow.color = ZFCOLOR(0, 0, 0, 0.3);
    shadow.offset = CGSizeMake(0, 2);
    shadow.radius = 4;
    titleAttribute.yy_textShadow = shadow;
    self.titleLabel.attributedText = titleAttribute;
}

#pragma mark - Public Methods
+ (NSString *)setIdentifier {
    return @"ParentCell_identifier";
}

#pragma mark - Rewrite Methods
-(void)prepareForReuse {
    self.categoryImgView.image = nil;
}

#pragma mark - Getter
-(UIImageView *)categoryImgView {
    if (!_categoryImgView) {
        _categoryImgView = [[UIImageView alloc] init];
        _categoryImgView.userInteractionEnabled = YES;
        _categoryImgView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        _categoryImgView.clipsToBounds = YES;
    }
    return _categoryImgView;
}

- (YYLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[YYLabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 3;
        _titleLabel.preferredMaxLayoutWidth = (KScreenWidth - 12 - 12 - 7) / 2 - 24;
    }
    return _titleLabel;
}

@end

