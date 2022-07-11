//
//  DiscoveryThreeModuleView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveyThreeModuleView.h"

static const NSInteger kDiscoverThreeModuleViewButtonTag = 2130;

@interface OSSVDiscoveyThreeModuleView ()

@property (nonatomic, strong) UIButton *moreImageButton;
@property (nonatomic, strong) UIButton *leftImageButton;
@property (nonatomic, strong) UIButton *middleImageButton;
@property (nonatomic, strong) UIButton *rightImageButton;

@end

@implementation OSSVDiscoveyThreeModuleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.moreImageButton];
        [self addSubview:self.leftImageButton];
        [self addSubview:self.middleImageButton];
        [self addSubview:self.rightImageButton];
        
        [self.moreImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(@0);
            make.height.mas_equalTo(45 * DSCREEN_WIDTH_SCALE);
        }];
        
        NSArray *tempImageArray = @[self.leftImageButton, self.middleImageButton, self.rightImageButton];
        [tempImageArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [tempImageArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_moreImageButton.mas_bottom).offset(0);
            make.height.mas_equalTo(128 * DSCREEN_WIDTH_SCALE);
        }];
        
    }
    return self;
}

#pragma mark -

- (void)didTapModuleViewAction :(UIButton *)button {
    
    NSInteger index = button.tag - kDiscoverThreeModuleViewButtonTag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapModuleViewActionWithModel: moduleType:position:)]) {
        [self.delegate tapModuleViewActionWithModel:self.tempModelArray[index] moduleType:ThreeModuleType position:index];
    }
}

#pragma mark - LazyLoad

- (void)setModelArray:(NSArray<OSSVAdvsEventsModel *> *)modelArray {
    
    if (modelArray.count != 4) return;
    
    self.tempModelArray = [NSArray arrayWithArray:modelArray];
    CGFloat imageWidth = SCREEN_WIDTH/3.0;
    
    for (OSSVAdvsEventsModel *model in modelArray) {
        NSInteger index = [modelArray indexOfObject:model];
        if (index == 0) {
            [self assginToImageDataWithButton:self.moreImageButton
                                    urlString:model.imageURL
                                         size:CGSizeMake(SCREEN_WIDTH, 45 * DSCREEN_WIDTH_SCALE)
                            placeholderString:kMouulePlaceholderMoreButtonImageString];
        }
        else if (index == 1) {
            [self assginToImageDataWithButton:self.leftImageButton
                                    urlString:model.imageURL
                                         size:CGSizeMake(imageWidth, 128 * DSCREEN_WIDTH_SCALE)
                            placeholderString:kModulePlaceholderDefalutImageString];
        }
        else if (index == 2) {
            [self assginToImageDataWithButton:self.middleImageButton
                                    urlString:model.imageURL
                                         size:CGSizeMake(imageWidth, 128 * DSCREEN_WIDTH_SCALE)
                            placeholderString:kModulePlaceholderDefalutImageString];
        }
        else if (index == 3) {
            [self assginToImageDataWithButton:self.rightImageButton
                                    urlString:model.imageURL
                                         size:CGSizeMake(imageWidth, 128 * DSCREEN_WIDTH_SCALE)
                            placeholderString:kModulePlaceholderDefalutImageString];
        }
    }
}


- (UIButton *)moreImageButton {
    if (!_moreImageButton) {
        _moreImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreImageButton.tag = kDiscoverThreeModuleViewButtonTag;
        [_moreImageButton setAdjustsImageWhenHighlighted:NO];
        [_moreImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreImageButton;
}

- (UIButton *)leftImageButton {
    if (!_leftImageButton) {
        _leftImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftImageButton.tag = kDiscoverThreeModuleViewButtonTag + 1;
        [_leftImageButton setAdjustsImageWhenHighlighted:NO];
        [_leftImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftImageButton;
}

- (UIButton *)middleImageButton {
    if (!_middleImageButton) {
        _middleImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _middleImageButton.tag = kDiscoverThreeModuleViewButtonTag + 2;
        [_middleImageButton setAdjustsImageWhenHighlighted:NO];
        [_middleImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _middleImageButton;
}

- (UIButton *)rightImageButton {
    if (!_rightImageButton) {
        _rightImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightImageButton.tag = kDiscoverThreeModuleViewButtonTag + 3;
        [_rightImageButton setAdjustsImageWhenHighlighted:NO];
        [_rightImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightImageButton;
}
@end
