//
//  DiscoveryThreeView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveyThreeView.h"

typedef NS_ENUM(NSUInteger, DiscoveryBottomButtonType) {
    DiscoveryBottomSupperDealsType = 2030,
    DiscoveryBottomNewInType = 2031,
    DiscoveryBottomBestSellersType = 2032
};

static const CGFloat kDiscoverHeaderBottomOfThreeViewsSpace = 2.0; // 底部View三者之间的距离

@interface OSSVDiscoveyThreeView ()

@end

@implementation OSSVDiscoveyThreeView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // Three sub Views
        [self addSubview:self.superDealsButton];
        [self addSubview:self.newinButton];
        [self addSubview:self.bestSellersButton];

        [self.superDealsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.equalTo(@0);
            make.height.mas_equalTo(180.0f* DSCREEN_WIDTH_SCALE);  
        }];
        
        [self.newinButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.mas_equalTo(@0);
            make.leading.equalTo(self.superDealsButton.mas_trailing).offset(kDiscoverHeaderBottomOfThreeViewsSpace);
            make.width.mas_equalTo(@(SCREEN_WIDTH /2.0 - kDiscoverHeaderBottomOfThreeViewsSpace / 2.0));
        }];
        
        [self.bestSellersButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.newinButton.mas_bottom).offset(kDiscoverHeaderBottomOfThreeViewsSpace);
            make.trailing.mas_equalTo(@0);
            make.leading.height.width.equalTo(self.newinButton);
            make.bottom.equalTo(self.superDealsButton.mas_bottom);
        }];

    }
    return self;
}


- (void)assginImageToButton:(UIButton *)button urlString:(NSString *)urlString size:(CGSize)size {
    [button yy_setBackgroundImageWithURL:[NSURL URLWithString:urlString]
                                forState:UIControlStateNormal
                             placeholder:[UIImage imageNamed:@"placeholder_pdf"]
                                 options:YYWebImageOptionShowNetworkActivity
                                 manager:nil
                                progress:nil
                               transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                            image = [image yy_imageByResizeToSize:size contentMode:UIViewContentModeScaleToFill];
                                            return image;
                                        }
                              completion:nil];
}

#pragma mark -
- (void)didTapThreeViewItemAction:(UIButton *)button {
    
    NSInteger index = button.tag - DiscoveryBottomSupperDealsType;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapThreeViewItemActionAtIndex:)]) {
        [self.delegate tapThreeViewItemActionAtIndex:index];
    }
}

#pragma mark - LazyLoad

- (void)setModelArray:(NSArray<OSSVAdvsEventsModel *> *)modelArray {
    
    for (OSSVAdvsEventsModel *model in modelArray) {
        NSInteger index = [modelArray indexOfObject:model];
        if (index == 0) {
            [self assginImageToButton:self.superDealsButton
                            urlString:model.imageURL
                                 size:CGSizeMake(SCREEN_WIDTH /2.0 - kDiscoverHeaderBottomOfThreeViewsSpace / 2.0,180.0f* DSCREEN_WIDTH_SCALE)];
        }
        else if (index == 1) {
            [self assginImageToButton:self.newinButton
                            urlString:model.imageURL
                                 size:CGSizeMake(SCREEN_WIDTH /2.0 - kDiscoverHeaderBottomOfThreeViewsSpace / 2.0,(180.0f* DSCREEN_WIDTH_SCALE/2 - kDiscoverHeaderBottomOfThreeViewsSpace )/ 2.0)];
        }
        else if (index == 2) {
            [self assginImageToButton:self.bestSellersButton
                            urlString:model.imageURL
                                 size:CGSizeMake(SCREEN_WIDTH /2.0 - kDiscoverHeaderBottomOfThreeViewsSpace / 2.0,(180.0f* DSCREEN_WIDTH_SCALE/2 - kDiscoverHeaderBottomOfThreeViewsSpace) / 2.0)];
            
        }
        
    }
}

- (UIButton *)superDealsButton {
    if (!_superDealsButton) {
        _superDealsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _superDealsButton.tag = DiscoveryBottomSupperDealsType;
        [_superDealsButton setAdjustsImageWhenHighlighted:NO];
        [_superDealsButton addTarget:self action:@selector(didTapThreeViewItemAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _superDealsButton;
}

- (UIButton *)newinButton {
    if (!_newinButton) {
        _newinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _newinButton.tag = DiscoveryBottomNewInType;
        [_newinButton setAdjustsImageWhenHighlighted:NO];
        [_newinButton addTarget:self action:@selector(didTapThreeViewItemAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _newinButton;
}

- (UIButton *)bestSellersButton {
    if (!_bestSellersButton) {
        _bestSellersButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bestSellersButton setAdjustsImageWhenHighlighted:NO];
        _bestSellersButton.tag = DiscoveryBottomBestSellersType;
        [_bestSellersButton addTarget:self action:@selector(didTapThreeViewItemAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bestSellersButton;
}

@end
