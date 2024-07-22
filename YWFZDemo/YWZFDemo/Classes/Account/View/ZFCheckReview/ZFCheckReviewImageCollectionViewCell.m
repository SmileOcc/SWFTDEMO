//
//  ZFCheckReviewImageCollectionViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/2/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCheckReviewImageCollectionViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"

@interface ZFCheckReviewImageCollectionViewCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *reviewImageView;
@end

@implementation ZFCheckReviewImageCollectionViewCell
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
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.reviewImageView];
}

- (void)zfAutoLayoutView {
    [self.reviewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter
- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    [self.reviewImageView yy_setImageWithURL:[NSURL URLWithString:_imageUrl]
                                 placeholder:[UIImage imageNamed:@"loading_cat_list"]];
}

#pragma mark - getter
- (UIImageView *)reviewImageView {
    if (!_reviewImageView) {
        _reviewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _reviewImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _reviewImageView;
}

@end
