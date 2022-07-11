//
//  DiscoveryOneBannerView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveyOneAdvsView.h"
#import "OSSVAdvsEventsModel.h"

@interface OSSVDiscoveyOneAdvsView ()

@end

@implementation OSSVDiscoveyOneAdvsView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageButton];
        
        [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(@0);
            make.height.mas_equalTo(45 *DSCREEN_WIDTH_SCALE);
        }];
    }
    return self;
}

- (void)didTapOneBannerViewAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapOneBannerViewActionWithModel:)]) {
        [self.delegate tapOneBannerViewActionWithModel:_model];
    }
}

#pragma mark - LazyLoad

- (void)setModel:(OSSVAdvsEventsModel *)model {
    
    _model = model;
    [self.imageButton yy_setBackgroundImageWithURL:[NSURL URLWithString:model.imageURL]
                                          forState:UIControlStateNormal
                                       placeholder:[UIImage imageNamed:@"small_placeholder"]
                                           options:YYWebImageOptionShowNetworkActivity
                                           manager:nil
                                          progress:nil
                                         transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                        image = [image yy_imageByResizeToSize:CGSizeMake(SCREEN_WIDTH, 45 *DSCREEN_WIDTH_SCALE)  contentMode:UIViewContentModeScaleAspectFill];
                                                        return image;
                                                    }
                                        completion:nil];
}

- (UIButton *)imageButton {
    if (!_imageButton) {
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imageButton setAdjustsImageWhenHighlighted:NO];
        [_imageButton addTarget:self action:@selector(didTapOneBannerViewAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageButton;
}


@end
