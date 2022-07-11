//
//  DiscoveryTwoModuleView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveyTwoModuleView.h"

static const NSInteger kDiscoverTwoModuleViewButtonTag = 2120;

@interface OSSVDiscoveyTwoModuleView ()

@property (nonatomic, strong) UIButton *moreImageButton;
@property (nonatomic, strong) UIButton *leftImageButton;
@property (nonatomic, strong) UIButton *rightImageButton;

@end

@implementation OSSVDiscoveyTwoModuleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.moreImageButton];
        [self addSubview:self.leftImageButton];
        [self addSubview:self.rightImageButton];

        
        [self.moreImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(@0);
            make.height.mas_equalTo(45 * DSCREEN_WIDTH_SCALE);
        }];
        
        [self.leftImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@0);
            make.top.equalTo(self.moreImageButton.mas_bottom);
            make.height.mas_equalTo(166 * DSCREEN_WIDTH_SCALE);
        }];
        
        [self.rightImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.moreImageButton.mas_bottom);
            make.leading.equalTo(self.leftImageButton.mas_trailing);
            make.height.mas_equalTo(166 * DSCREEN_WIDTH_SCALE);
            make.trailing.mas_equalTo(0);
            make.width.equalTo(self.leftImageButton.mas_width);
        }];
    }
    return self;
}

#pragma mark -

- (void)didTapModuleViewAction :(UIButton *)button {
    
    NSInteger index = button.tag - kDiscoverTwoModuleViewButtonTag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapModuleViewActionWithModel: moduleType:position:)]) {
        [self.delegate tapModuleViewActionWithModel:self.tempModelArray[index] moduleType:TwoModuleType position:index];
    }
}

#pragma mark - LazyLoad

- (void)setModelArray:(NSArray<OSSVAdvsEventsModel *> *)modelArray {
    
    if (modelArray.count != 3) return;
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
                                         size:CGSizeMake(SCREEN_WIDTH/2, 166 * DSCREEN_WIDTH_SCALE)
                            placeholderString:kModulePlaceholderDefalutImageString];
        }
        else if (index == 2) {
            [self assginToImageDataWithButton:self.rightImageButton
                                    urlString:model.imageURL
                                         size:CGSizeMake(SCREEN_WIDTH/2, 166 * DSCREEN_WIDTH_SCALE)
                            placeholderString:kModulePlaceholderDefalutImageString];
        }
    }
}

- (UIButton *)moreImageButton {
    if (!_moreImageButton) {
        _moreImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreImageButton.tag = kDiscoverTwoModuleViewButtonTag;
        [_moreImageButton setAdjustsImageWhenHighlighted:NO];
        [_moreImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreImageButton;
}

- (UIButton *)leftImageButton {
    if (!_leftImageButton) {
        _leftImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftImageButton.tag = kDiscoverTwoModuleViewButtonTag + 1;
        [_leftImageButton setAdjustsImageWhenHighlighted:NO];
        [_leftImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftImageButton;
}

- (UIButton *)rightImageButton {
    if (!_rightImageButton) {
        _rightImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightImageButton.tag = kDiscoverTwoModuleViewButtonTag + 2;
        [_rightImageButton setAdjustsImageWhenHighlighted:NO];
        [_rightImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightImageButton;
}

@end
