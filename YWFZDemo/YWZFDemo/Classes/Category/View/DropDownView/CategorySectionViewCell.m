//
//  CategorySectionView.m
//  ListPageViewController
//
//  Created by YW on 6/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategorySectionViewCell.h"
#import "CategoryNewModel.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "UIImage+ZFExtended.h"

@interface CategorySectionViewCell ()
@property (nonatomic, strong)  YYLabel          *titleLabel;
@property (nonatomic, strong)  UIImageView      *arrowImgView;
@property (nonatomic, strong)  CALayer          *line;
@end

@implementation CategorySectionViewCell
#pragma mark - Init Method
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureSubViews];
        [self autoLayoutSubViews];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandPropertyTouch)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImgView];
    [self.layer addSublayer:self.line];
}

- (void)autoLayoutSubViews {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(20);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-20);
    }];
    
    self.line.frame = CGRectMake(0, 44 - MIN_PIXEL, KScreenWidth, MIN_PIXEL);
}

#pragma mark - Gesture Handle
- (void)expandPropertyTouch {
    _model.isOpen = !_model.isOpen;
    _model.isSelect = !_model.isSelect;
    if (self.categorySectionViewTouchHandler) {
        self.categorySectionViewTouchHandler(self.model);
    }
}

#pragma mark - Setter
- (void)setModel:(CategoryNewModel *)model {
    _model = model;
    self.titleLabel.text = model.cat_name;
    if ([model.is_child boolValue]) {
        self.arrowImgView.image = model.isOpen ? [UIImage imageNamed:@"search_list_minus"] : [UIImage imageNamed:@"search_list_plus"];
    }else{
        self.arrowImgView.image = model.isSelect ? [[UIImage imageNamed:@"refine_select"] imageWithColor:ZFC0xFE5269()] : nil;
    }
    [self setNeedsDisplay];
}

#pragma mark - Rewrite Methods
-(void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
    self.arrowImgView.image = nil;
}

#pragma mark - Public Methods
+ (NSString *)setIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Getter
- (YYLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [YYLabel new];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _titleLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    }
    return _titleLabel;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
    }
    return _arrowImgView;
}

- (CALayer *)line {
    if (!_line) {
        _line = [CALayer layer];
        _line.backgroundColor = ZFCOLOR(221, 221, 221, 1).CGColor;
        //v5.4.0 隐藏
        _line.hidden = YES;
    }
    return _line;
}

@end