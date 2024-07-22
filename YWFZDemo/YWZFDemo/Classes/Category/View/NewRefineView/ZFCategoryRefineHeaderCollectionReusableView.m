//
//  ZFCategoryRefineHeaderCollectionReusableView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryRefineHeaderCollectionReusableView.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "SystemConfigUtils.h"

@implementation ZFCategoryRefineHeaderCollectionReusableView

+ (ZFCategoryRefineHeaderCollectionReusableView *)headWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFCategoryRefineHeaderCollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([self class])];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}


//- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    
//    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
//    // 计算cell里面textfield的宽度
//    CGRect frame = [self.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.titleLabel.font,NSFontAttributeName, nil] context:nil];
//    
//    // 如果内容宽度 大于显示cell的宽度，显示会卡死
//    CGFloat maxW = 110;
//    if (frame.size.width >= maxW) {
//        frame.size.width = maxW;
//    }
//    
//    frame.size.width = CGRectGetWidth(self.superview.frame);
//    frame.size.height = 44;
//    // 重新赋值给属性集
//    attributes.frame = frame;
//    
//    return attributes;
//}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

//        self.backgroundColor = ZFCOLOR_RANDOM;
        [self addSubview:self.titleLabel];
        [self addSubview:self.arrowImageView];
        [self addSubview:self.countsView];
        [self.countsView addSubview:self.countsLabel];
        [self addSubview:self.evenButton];
        
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-40);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.countsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading).offset(-5);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(14);
        }];
        [self.countsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.countsView);
            make.height.mas_equalTo(14);
            make.top.mas_equalTo(self.countsView.mas_top);
        }];
        
        [self.evenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
    }
    return self;
}

- (void)actionEvent:(UIButton *)sender {
    if (self.arrowImageView.isHidden) {
        return;
    }
    if (self.tapBlock) {
        self.tapBlock();
    }
    self.isUp = !self.isUp;
    
    CGFloat angle = self.isUp ? -M_PI : 0;
    [UIView animateWithDuration:0.15 animations:^{
        self.arrowImageView.transform =  CGAffineTransformMakeRotation(angle);
    }];
}

- (void)updateArrowDirection:(BOOL)isUp {
    self.isUp = isUp;
    CGFloat angle = self.isUp ? -M_PI : 0;
    self.arrowImageView.transform =  CGAffineTransformMakeRotation(angle);
}

- (void)updateCountsString:(NSString *)countsString {
    self.countsLabel.text = ZFToString(countsString);
    if (ZFIsEmptyString(countsString)) {
        self.countsView.hidden = YES;
    } else{
        self.countsView.hidden = NO;
        
        NSString *s = self.countsLabel.text;
        UIFont *font = [self.countsLabel font];
        CGSize size = CGSizeMake(320,2000);
        CGSize labelsize;
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        
        labelsize = [s boundingRectWithSize:size
                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 attributes:@{ NSFontAttributeName:font, NSParagraphStyleAttributeName : style}
                                    context:nil].size;
        
        labelsize.width += 4;
        [self.countsView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(ceilf(labelsize.width) > 14 ? ceilf(labelsize.width) : 14);
        }];
    }
    
}

- (void)hideArrow:(BOOL)isHide {
    self.arrowImageView.hidden = isHide;

    if (isHide) {
        self.countsView.hidden = isHide;
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFC0x2D2D2D();
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _titleLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _titleLabel;
}

- (UILabel *)countsLabel {
    if (!_countsLabel) {
        _countsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countsLabel.textColor = ZFC0xFFFFFF();
        _countsLabel.font = [UIFont systemFontOfSize:9];
        _countsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countsLabel;
}

- (UIView *)countsView {
    if (!_countsView) {
        _countsView = [[UIView alloc] initWithFrame:CGRectZero];
        _countsView.layer.cornerRadius = 7.0;
        _countsView.layer.masksToBounds = YES;
        _countsView.backgroundColor = ZFC0xCCCCCC();
    }
    return _countsView;
}

- (UIButton *)evenButton {
    if (!_evenButton) {
        _evenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_evenButton addTarget:self  action:@selector(actionEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _evenButton;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"category_filter_arrow_down"]];
    }
    return _arrowImageView;
}
@end
