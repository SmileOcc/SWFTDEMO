//
//  ZFOutfitItemView.m
//  ZZZZZ
//
//  Created by YW on 2018/5/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOutfitItemView.h"
#import "ZFOutfitBuilderSingleton.h"
#import <math.h>
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+LayoutMethods.h"
#import "ZFNotificationDefiner.h"
#import "Constants.h"

#define kMinSize   54.0f                        // 放缩最小尺寸
#define kOperateViewSize 36.0
#define kDeleteSize 22.0
@interface ZFOutfitItemView (){
    CGPoint _centerPoint;
    CGRect _frame;
}

@property (nonatomic, strong) UIImageView         *contentImageView;

@end

@implementation ZFOutfitItemView

- (instancetype)initWithItemModel:(ZFOutfitItemModel *)itemModel mainView:(UIView *)mainView {
    if (self = [super init]) {
        CGFloat minWidth = (mainView.width > mainView.height) ? mainView.height : mainView.width;
        CGFloat width    = minWidth * 3 / 5;
        self.frame       = CGRectMake(0.0, 0.0, width, width);
        self.center      = CGPointMake(mainView.width / 2, mainView.height / 2);
        self.userInteractionEnabled = YES;
        
        _centerPoint     = self.center;
        _frame           = self.frame;
        
        self.itemModel = itemModel;
        [self setupView];
        [self addGestures];
        if (self.itemModel.photoImage) {
            self.contentImageView.image = self.itemModel.photoImage;
        } else {
            [self.contentImageView yy_setImageWithURL:[NSURL URLWithString:self.itemModel.imageURL]
                                          placeholder:nil];
        }
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.contentImageView];
    [self setContentImageFrame];
}

- (void)itemStatus:(BOOL)isOperater {
    if (isOperater) {
        self.contentImageView.layer.borderWidth = 0.5f;
    } else {
        self.contentImageView.layer.borderWidth = 0.0f;
    }
}

- (void)addGestures {
    // 添加手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(contentTapAction)];
    [self addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
    [panGesture addTarget:self action:@selector(contentPanAction:)];
    [self addGestureRecognizer:panGesture];
}

#pragma mark - event

- (void)contentTapAction {
    if (self.tapItemBlock) {
        self.tapItemBlock(self);
        [self itemStatus:YES];
    }
}


- (void)contentPanAction:(UIPanGestureRecognizer *)panGesture {
    //FIXME: occ Bug 1101 需优化
    CGPoint translatedPoint = [panGesture translationInView:self.superview];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self contentTapAction];
            break;
        }
        case UIGestureRecognizerStateChanged: {
//            self.center = CGPointMake(_centerPoint.x + translatedPoint.x, _centerPoint.y + translatedPoint.y);
//            _frame      = self.frame;
//            [self setNeedsDisplay];
            break;
        }
        case UIGestureRecognizerStateEnded: {
//            _centerPoint = self.center;
            break;
        }
        default:
            break;
    }
}

#pragma mark - private method
- (void)setContentImageFrame {
    self.contentImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (void)changeContentImageSize {
    self.contentImageView.frame = self.bounds;
}

#pragma mark - getter/setter
- (UIImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] init];
        _contentImageView.userInteractionEnabled = YES;
        _contentImageView.contentMode            = UIViewContentModeScaleAspectFit;
        _contentImageView.layer.borderWidth      = 0.5;
        _contentImageView.layer.borderColor      = ZFC0xFE5269().CGColor;
    }
    return _contentImageView;
}


@end
