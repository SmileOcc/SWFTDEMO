//
//  ZFNativeCollectionHeaderView.m
//  ZZZZZ
//
//  Created by YW on 4/1/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNativeCollectionHeaderView.h"
#import "ZFThemeManager.h"
#import "Masonry.h"

@interface ZFNativeCollectionHeaderView ()
@property (nonatomic, strong) UILabel   *titleLabel;
@end

@implementation ZFNativeCollectionHeaderView

+ (ZFNativeCollectionHeaderView *)headWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFNativeCollectionHeaderView class] forSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([self class])];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZFCOLOR_WHITE;
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}


@end
