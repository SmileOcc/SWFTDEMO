//
//  SubLevelCell.m
//  ListPageViewController
//
//  Created by YW on 26/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategorySubLevelCell.h"
#import "CategoryNewModel.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface CategorySubLevelCell ()
@property (nonatomic, strong) UIImageView   *categoryImgView;
@property (nonatomic, strong) YYLabel       *describeLabel;
@end

@implementation CategorySubLevelCell
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
    [self.contentView addSubview:self.categoryImgView];
    [self.contentView addSubview:self.describeLabel];
    
}

-(void)autoLayoutSubViews {
    [self.categoryImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat width = (KScreenWidth - 12 - 12 - 15) / 3;
        CGFloat height = 100 * ScreenWidth_SCALE;
        make.top.leading.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(width,height));
    }];
    
    [self.describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryImgView.mas_bottom);
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(38);
    }];
}

#pragma mark - Setter
-(void)setModel:(CategoryNewModel *)model {
    _model = model;
    
    [self.categoryImgView yy_setImageWithURL:[NSURL URLWithString:model.cat_pic]
                                      placeholder:[UIImage imageNamed:@"view_all"]
                                           options:YYWebImageOptionAvoidSetImage
                                        completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                            if (image && stage == YYWebImageStageFinished) {
                                                self.categoryImgView.image = image;
                                            }
                                        }];

     self.describeLabel.text = model.cat_name;
    
    [self setNeedsDisplay];
}

#pragma mark - Public Methods
+ (NSString *)setIdentifier {
    return @"SubLevelCell_identifier";
}

#pragma mark - Rewrite Methods
-(void)prepareForReuse {
    self.categoryImgView.image = nil;
    self.describeLabel.text = nil;
}

#pragma mark - Getter
-(UIImageView *)categoryImgView {
    if (!_categoryImgView) {
        _categoryImgView = [[UIImageView alloc] init];
        _categoryImgView.userInteractionEnabled = YES;
        _categoryImgView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        _categoryImgView.contentMode = UIViewContentModeScaleAspectFill;
        _categoryImgView.clipsToBounds = YES;
    }
    return _categoryImgView;
}

-(YYLabel *)describeLabel {
    if (!_describeLabel) {
        _describeLabel = [YYLabel new];
        _describeLabel.textAlignment = NSTextAlignmentCenter;
        _describeLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        _describeLabel.numberOfLines = 0;
        _describeLabel.preferredMaxLayoutWidth = (KScreenWidth - 12 - 12 - 15) / 3 - 10;
        _describeLabel.font = [UIFont systemFontOfSize:14.0];
        _describeLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _describeLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        _describeLabel.displaysAsynchronously = YES;
        _describeLabel.fadeOnAsynchronouslyDisplay = YES;

    }
    return _describeLabel;
}

@end
