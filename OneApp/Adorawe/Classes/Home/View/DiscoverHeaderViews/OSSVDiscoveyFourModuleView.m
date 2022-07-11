//
//  DiscoveryFourModuleView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveyFourModuleView.h"

static const NSInteger kDiscoverFourModuleViewButtonTag = 2140;

@interface OSSVDiscoveyFourModuleView ()

@property (nonatomic, strong) UIButton *moreImageButton;
@property (nonatomic, strong) UIButton *leftImageButton;
@property (nonatomic, strong) UIButton *rightTopImageButton;
@property (nonatomic, strong) UIButton *rightLeadImageButton;
@property (nonatomic, strong) UIButton *rightTrailImageButton;

@end


@implementation OSSVDiscoveyFourModuleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.moreImageButton];
        [self addSubview:self.leftImageButton];
        [self addSubview:self.rightTopImageButton];
        [self addSubview:self.rightLeadImageButton];
        [self addSubview:self.rightTrailImageButton];

        [self.moreImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(@0);
            make.height.mas_equalTo(45 * DSCREEN_WIDTH_SCALE);
        }];
        
        [self.leftImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@0);
            make.top.equalTo(self.moreImageButton.mas_bottom);
            make.height.mas_equalTo(175 * DSCREEN_WIDTH_SCALE);
            make.width.mas_equalTo(136 * DSCREEN_WIDTH_SCALE);
        }];
        
        [self.rightTopImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(@0);
            make.top.equalTo(self.moreImageButton.mas_bottom);
            make.leading.equalTo(_leftImageButton.mas_trailing);
        }];
        
        [self.rightLeadImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.rightTopImageButton.mas_bottom);
            make.bottom.equalTo(self.leftImageButton.mas_bottom);
            make.leading.equalTo(self.leftImageButton.mas_trailing);
            make.width.mas_equalTo(92 * DSCREEN_WIDTH_SCALE);
        }];
        
        [self.rightTrailImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.rightTopImageButton.mas_bottom);
            make.bottom.equalTo(self.leftImageButton.mas_bottom);
            make.leading.equalTo(self.rightLeadImageButton.mas_trailing);
            make.trailing.mas_equalTo(0);
        }];
        
        
    }
    return self;
}

#pragma mark -

- (void)didTapModuleViewAction :(UIButton *)button {
    
    NSInteger index = button.tag - kDiscoverFourModuleViewButtonTag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapModuleViewActionWithModel: moduleType:position:)]) {
        [self.delegate tapModuleViewActionWithModel:self.tempModelArray[index] moduleType:FourModuleType position:index];
    }
}

#pragma mark - LazyLoad

- (void)setModelArray:(NSArray<OSSVAdvsEventsModel *> *)modelArray {
    
    if (modelArray.count != 5) return;
    
    self.tempModelArray = [NSArray arrayWithArray:modelArray];
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
                                         size:CGSizeMake(136 * DSCREEN_WIDTH_SCALE, 175 * DSCREEN_WIDTH_SCALE)
                            placeholderString:kModulePlaceholderDefalutImageString];
        }
        else if (index == 2) {
            [self assginToImageDataWithButton:self.rightTopImageButton
                                    urlString:model.imageURL
                                         size:CGSizeMake(SCREEN_WIDTH - 136 * DSCREEN_WIDTH_SCALE, 88 * DSCREEN_WIDTH_SCALE)
                            placeholderString:kModulePlaceholderDefalutImageString];
        }
        else if (index == 3) {
            [self assginToImageDataWithButton:self.rightLeadImageButton
                                    urlString:model.imageURL
                                         size:CGSizeMake((SCREEN_WIDTH - 136 * DSCREEN_WIDTH_SCALE)/2.0, 87 * DSCREEN_WIDTH_SCALE)
                            placeholderString:kModulePlaceholderDefalutImageString];
        }
        else if (index == 4) {
            [self assginToImageDataWithButton:self.rightTrailImageButton
                                    urlString:model.imageURL
                                         size:CGSizeMake((SCREEN_WIDTH - 136 * DSCREEN_WIDTH_SCALE)/2.0, 87 * DSCREEN_WIDTH_SCALE)
                            placeholderString:kModulePlaceholderDefalutImageString];
        }
    }
}

- (UIButton *)moreImageButton {
    if (!_moreImageButton) {
        _moreImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreImageButton.tag = kDiscoverFourModuleViewButtonTag;
        [_moreImageButton setAdjustsImageWhenHighlighted:NO];
        [_moreImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreImageButton;
}

- (UIButton *)leftImageButton {
    if (!_leftImageButton) {
        _leftImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftImageButton.tag = kDiscoverFourModuleViewButtonTag + 1;
        [_leftImageButton setAdjustsImageWhenHighlighted:NO];
        [_leftImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftImageButton;
}

- (UIButton *)rightTopImageButton {
    if (!_rightTopImageButton) {
        _rightTopImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightTopImageButton.tag = kDiscoverFourModuleViewButtonTag + 2;
        [_rightTopImageButton setAdjustsImageWhenHighlighted:NO];
        [_rightTopImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightTopImageButton;
}

- (UIButton *)rightLeadImageButton {
    if (!_rightLeadImageButton) {
        _rightLeadImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightLeadImageButton.tag = kDiscoverFourModuleViewButtonTag + 3;
        [_rightLeadImageButton setAdjustsImageWhenHighlighted:NO];
        [_rightLeadImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightLeadImageButton;
}

- (UIButton *)rightTrailImageButton {
    if (!_rightTrailImageButton) {
        _rightTrailImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightTrailImageButton.tag = kDiscoverFourModuleViewButtonTag + 4;
        [_rightTrailImageButton setAdjustsImageWhenHighlighted:NO];
        [_rightTrailImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightTrailImageButton;
}
@end
