//
//  DiscoveryFiveModuleView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveyFiveModuleView.h"

static const NSInteger kDiscoverFiveModuleViewButtonTag = 2150;


@interface OSSVDiscoveyFiveModuleView ()

@property (nonatomic, strong) UIButton *moreImageButton;
@property (nonatomic, strong) UIButton *leftImageButton;
@property (nonatomic, strong) UIView   *rightBackView;

@end

@implementation OSSVDiscoveyFiveModuleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.moreImageButton];
        [self addSubview:self.leftImageButton];
        [self addSubview:self.rightBackView];

        [self.moreImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(@0);
            make.height.mas_equalTo(45 * DSCREEN_WIDTH_SCALE);
        }];
        
        [self.leftImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@0);
            make.top.equalTo(self.moreImageButton.mas_bottom);
            make.width.mas_equalTo(136 * DSCREEN_WIDTH_SCALE);
            make.height.mas_equalTo(175 * DSCREEN_WIDTH_SCALE);
        }];
        
        [self.rightBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.moreImageButton.mas_bottom);
            make.leading.equalTo(self.leftImageButton.mas_trailing);
            make.bottom.equalTo(self.leftImageButton.mas_bottom);
            make.trailing.mas_equalTo(0);
        }];
        
        
        CGFloat buttonWidth = (SCREEN_WIDTH - 136* DSCREEN_WIDTH_SCALE)/2.0; // 此处和设计图上有一点点不同，这边是让其相等的
        CGFloat buttonHeight = (175 * DSCREEN_WIDTH_SCALE) / 2.0;
        for (NSInteger i = 0; i < 4; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = kDiscoverFiveModuleViewButtonTag + 2 + i;
            [button setAdjustsImageWhenHighlighted:NO];
            [button addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.rightBackView addSubview:button];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(i/2 * buttonHeight);
                make.leading.mas_equalTo(i % 2 * buttonWidth);
                make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
            }];
        }
    }
    return self;
}

#pragma mark -

- (void)didTapModuleViewAction :(UIButton *)button {
    
    NSInteger index = button.tag - kDiscoverFiveModuleViewButtonTag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapModuleViewActionWithModel: moduleType:position:)]) {
        [self.delegate tapModuleViewActionWithModel:self.tempModelArray[index] moduleType:FiveModuleType position:index];
    }
}

#pragma mark - LazyLoad

- (void)setModelArray:(NSArray<OSSVAdvsEventsModel *> *)modelArray {
    
    if (modelArray.count != 6) return;
    
    self.tempModelArray = [NSArray arrayWithArray:modelArray];
    NSMutableArray *fourImageArray = [NSMutableArray arrayWithCapacity:4];
    
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
        else if (index > 1) {
            [fourImageArray addObject:model.imageURL];
        }
    }
    
    // 给四个View的值赋值
    NSString *urlString = nil;
    CGFloat buttonWidth = (SCREEN_WIDTH - 136 * DSCREEN_WIDTH_SCALE)/2.0;
    CGFloat buttonHeight = (175 * DSCREEN_WIDTH_SCALE) / 2.0;
    
    if (fourImageArray.count != 4) return;
    
    for (UIButton *button in self.rightBackView.subviews) {
        switch (button.tag) {
            case kDiscoverFiveModuleViewButtonTag + 2:
                urlString = fourImageArray[0];
                break;
            case kDiscoverFiveModuleViewButtonTag + 3:
                urlString = fourImageArray[1];
                break;
            case kDiscoverFiveModuleViewButtonTag + 4:
                urlString = fourImageArray[2];
                break;
            case kDiscoverFiveModuleViewButtonTag + 5:
                urlString = fourImageArray[3];
                break;
            default:
                break;
        }
        [self assginToImageDataWithButton:button
                                urlString:urlString
                                     size:CGSizeMake(buttonWidth,buttonHeight)
                        placeholderString:kModulePlaceholderDefalutImageString];
    }

}

- (UIButton *)moreImageButton {
    if (!_moreImageButton) {
        _moreImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreImageButton.tag = kDiscoverFiveModuleViewButtonTag;
        [_moreImageButton setAdjustsImageWhenHighlighted:NO];
        [_moreImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreImageButton;
}

- (UIButton *)leftImageButton {
    if (!_leftImageButton) {
        _leftImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftImageButton.tag = kDiscoverFiveModuleViewButtonTag + 1;
        [_leftImageButton setAdjustsImageWhenHighlighted:NO];
        [_leftImageButton addTarget:self action:@selector(didTapModuleViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftImageButton;
}

- (UIView *)rightBackView {
    if (!_rightBackView) {
        _rightBackView = [[UIView alloc]init];
        _rightBackView.backgroundColor = [UIColor clearColor];
    }
    return _rightBackView;
}

@end
