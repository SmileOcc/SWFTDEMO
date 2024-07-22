//
//  ZFNativeGoodsItemView.m
//  ZZZZZ
//
//  Created by YW on 13/4/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFListGoodsNumberHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

#ifdef __IPHONE_11_0
@implementation ZFCustomLayer
- (CGFloat) zPosition {
    return 0;
}
@end
#endif

@interface  ZFListGoodsNumberHeaderView()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel *itemLabel;
@property (nonatomic, strong) YYAnimatedImageView *bgImageView;
@end

@implementation ZFListGoodsNumberHeaderView

+ (ZFListGoodsNumberHeaderView *)headWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFListGoodsNumberHeaderView class] forSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([self class])];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.clipsToBounds = YES;
    }
    return self;
}

#ifdef __IPHONE_11_0
+ (Class)layerClass {
    return [ZFCustomLayer class];
}
#endif

#pragma mark - Setter
- (void)setItem:(NSString *)item {
    _item = item;
    self.itemLabel.text = item;
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    self.itemLabel.font = ZFFontBoldSize(20);
    self.itemLabel.textColor = ZFCOLOR(255, 255, 255, 1);
    
    if ([imageUrl hasPrefix:@"http"]) {
        [self.bgImageView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
                                placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                     options:YYWebImageOptionAvoidSetImage
                                  completion:nil];
    } else {
        self.bgImageView.image = ZFImageWithName(imageUrl) ? : ZFImageWithName(@"account_orderScuuessPushIcon");
    }
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.itemLabel];
}

- (void)zfAutoLayoutView {
    [self.itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - getter
- (UILabel *)itemLabel {
    if (!_itemLabel) {
        _itemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _itemLabel.textAlignment = NSTextAlignmentCenter;
        _itemLabel.font = [UIFont systemFontOfSize:12];
        _itemLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _itemLabel.text = @"";
    }
    return _itemLabel;
}

- (YYAnimatedImageView *)bgImageView {
    if(!_bgImageView){
        _bgImageView = [[YYAnimatedImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_bgImageView];
        [self insertSubview:_bgImageView atIndex:0];
        
        [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
        }];
    }
    return _bgImageView;
}

@end
