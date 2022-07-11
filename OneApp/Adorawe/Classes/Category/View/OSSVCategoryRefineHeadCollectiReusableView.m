//
//  OSSVCategoryRefineHeadCollectiReusableView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryRefineHeadCollectiReusableView.h"

@implementation OSSVCategoryRefineHeadCollectiReusableView

+ (OSSVCategoryRefineHeadCollectiReusableView *)headWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[OSSVCategoryRefineHeadCollectiReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([self class])];
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

        [self addSubview:self.titleLabel];
        [self addSubview:self.arrowImageView];
        [self addSubview:self.countsView];
        [self.countsView addSubview:self.countsLabel];
        [self addSubview:self.evenButton];
        
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.countsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading).offset(-5);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(12);
        }];
        [self.countsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.countsView);
            make.height.mas_equalTo(14);
            make.centerY.mas_equalTo(self.countsView);
        }];
        
        [self.evenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        // 设置抗压缩优先级
        [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.titleLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];

        [self.countsView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.countsView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

        [self.countsLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.countsLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
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
    self.countsLabel.text = STLToString(countsString);
//    if (STLIsEmptyString(countsString)) {
//        self.countsView.hidden = YES;
//    } else{
//        self.countsView.hidden = NO;
//
//        NSString *s = self.countsLabel.text;
//        UIFont *font = [self.countsLabel font];
//        CGSize size = CGSizeMake(320,2000);
//        CGSize labelsize;
//
//        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//        [style setLineBreakMode:NSLineBreakByWordWrapping];
//
//        labelsize = [s boundingRectWithSize:size
//                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
//                                 attributes:@{ NSFontAttributeName:font, NSParagraphStyleAttributeName : style}
//                                    context:nil].size;
//
//        labelsize.width += 4;
//        [self.countsView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(ceilf(labelsize.width) > 14 ? ceilf(labelsize.width) : 14);
//        }];
//    }
    
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
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.font = [UIFont boldSystemFontOfSize:13];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
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
        _countsLabel.textColor = [OSSVThemesColors col_999999];
        _countsLabel.font = [UIFont systemFontOfSize:11];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _countsLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            _countsLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _countsLabel;
}

- (UIView *)countsView {
    if (!_countsView) {
        _countsView = [[UIView alloc] initWithFrame:CGRectZero];
//        _countsView.layer.cornerRadius = 7.0;
//        _countsView.layer.masksToBounds = YES;
        _countsView.backgroundColor = [OSSVThemesColors stlWhiteColor];
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
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_arrow_down"]];
    }
    return _arrowImageView;
}

@end
