//
//  DiscoveryOneModuleView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveyOneModuleView.h"

static const NSInteger kDiscoverOneModuleViewButtonTag = 2110;

@interface OSSVDiscoveyOneModuleView ()

@property (nonatomic, strong) UIButton *moreImageButton;
@property (nonatomic, strong) UIButton *contentImageButton;

@end


@implementation OSSVDiscoveyOneModuleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.moreImageButton];
        [self addSubview:self.contentImageButton];

        [self.moreImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(@0);
            make.height.mas_equalTo(45 * DSCREEN_WIDTH_SCALE);
        }];
        
        [self.contentImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(@0);
            make.top.equalTo(self.moreImageButton.mas_bottom);
            make.height.mas_equalTo(122 * DSCREEN_WIDTH_SCALE);
        }];

    }
    return self;
}

#pragma mark -
- (void)didTapModuleViewAction:(UIButton *)button {
    
    NSInteger index = button.tag - kDiscoverOneModuleViewButtonTag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapModuleViewActionWithModel: moduleType:position:)]) {
        [self.delegate tapModuleViewActionWithModel:self.tempModelArray[index] moduleType:OneModuleType position:index];
    }
}



#pragma mark - LazyLoad

- (void)setModelArray:(NSArray<OSSVAdvsEventsModel *> *)modelArray {
    
    if (modelArray.count != 2) return;
    self.tempModelArray = [NSArray arrayWithArray:modelArray];
    for (OSSVAdvsEventsModel *model in modelArray) {
        NSInteger index = [modelArray indexOfObject:model];
        if (index == 0) {
            [self assginToImageDataWithButton:self.moreImageButton urlString:model.imageURL size:CGSizeMake(SCREEN_WIDTH, 45 * DSCREEN_WIDTH_SCALE) placeholderString:kMouulePlaceholderMoreButtonImageString];
        }
        else if (index == 1) {
            [self assginToImageDataWithButton:self.contentImageButton urlString:model.imageURL size:CGSizeMake(SCREEN_WIDTH, 122 * DSCREEN_WIDTH_SCALE) placeholderString:kModulePlaceholderDefalutImageString];
        }
    }
}

- (UIButton *)moreImageButton {
    if (!_moreImageButton) {
        _moreImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreImageButton.tag = kDiscoverOneModuleViewButtonTag;
        [_moreImageButton setAdjustsImageWhenHighlighted:NO];
        [_moreImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreImageButton;
}

- (UIButton *)contentImageButton {
    if (!_contentImageButton) {
        _contentImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _contentImageButton.tag = kDiscoverOneModuleViewButtonTag + 1;
        [_contentImageButton setAdjustsImageWhenHighlighted:NO];
        [_contentImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contentImageButton;
}




@end
