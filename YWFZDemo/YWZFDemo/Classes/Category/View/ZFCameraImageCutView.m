//
//  ZFCameraImageCutView.m
//  ZZZZZ
//
//  Created by YW on 2018/7/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCameraImageCutView.h"
#import "UIView+LayoutMethods.h"
#import "Constants.h"

#define kMinWidth      100.0
#define kPanWidth      10.0
@interface ZFCameraImageCutView ()

@property (nonatomic, assign) CGRect         cutRect;
@property (nonatomic, strong) UIView         *boardPanView;
@property (nonatomic, strong) UIImageView    *cutContentImageView;
@property (nonatomic, assign) CGPoint        centerPoint;
@property (nonatomic, assign) CGRect         editContentFrame;
@property (nonatomic, assign) CGPoint        beginPoint;

@end

@implementation ZFCameraImageCutView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        [self addSubview:self.cutContentImageView];
        [self addSubview:self.boardPanView];
        [self addCutGesture];
    }
    return self;
}

- (void)addCutGesture {
    UIPanGestureRecognizer *boardPanGesture = [[UIPanGestureRecognizer alloc] init];
    [boardPanGesture addTarget:self action:@selector(boardPanAction:)];
    [self.boardPanView addGestureRecognizer:boardPanGesture];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat offsetX = 50.0;
    CGFloat width   = self.frame.size.width -  offsetX * 2;
    CGFloat height  = width;
    CGFloat offsetY = (self.frame.size.height - height) / 2;
    _editContentFrame = CGRectMake(offsetX, offsetY, width, height);
    [self setContentFrame:_editContentFrame];
    _centerPoint = self.cutContentImageView.center;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //背景色
    [[UIColor colorWithWhite:0 alpha:0.6] set];
    CGContextAddRect(ctx, rect);
    CGContextFillPath(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeClear);

    CGContextAddRect(ctx, self.cutRect);
    CGContextFillPath(ctx);
//    CGContextRelease(ctx);
}

- (CGRect)cutResultImageRect {
    return self.cutRect;
}

- (void)setContentFrame:(CGRect)frame {
    self.cutContentImageView.frame = frame;
    self.cutRect = CGRectMake(frame.origin.x + 3.0, frame.origin.y + 3.0, frame.size.width - 6.0, frame.size.height - 6.0);
    self.boardPanView.frame = CGRectMake(frame.origin.x - kPanWidth, frame.origin.y - kPanWidth, frame.size.width + kPanWidth * 2, frame.size.height + kPanWidth * 2);
}

#pragma mark - event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch     = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.boardPanView];
    _beginPoint        = touchPoint;
    YWLog(@"%f==%f",touchPoint.x,touchPoint.y);
}

- (void)boardPanAction:(UIPanGestureRecognizer *)panGesture {
    CGPoint translatedPoint = [panGesture translationInView:self.boardPanView];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self changeFrameWithTranslatePoint:translatedPoint beginPoint:_beginPoint];
            [self setNeedsDisplay];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            _editContentFrame = self.cutContentImageView.frame;
            _centerPoint = self.cutContentImageView.center;
            break;
        }
        default:
            break;
    }
}

- (void)changeFrameWithTranslatePoint:(CGPoint)translatedPoint beginPoint:(CGPoint)beginPoint {
    CGFloat width  = _editContentFrame.size.width;
    CGFloat height = _editContentFrame.size.height;
    CGFloat offsetX = _editContentFrame.origin.x;
    CGFloat offsetY = _editContentFrame.origin.y;
    
    if (beginPoint.x > kPanWidth * 2
               && beginPoint.x < _editContentFrame.size.width - kPanWidth * 2
               && beginPoint.y > kPanWidth * 2
               && beginPoint.y < _editContentFrame.size.height - kPanWidth * 2) {
        // 操作中间区域
        CGFloat changeX = _centerPoint.x + translatedPoint.x;
        CGFloat changeY = _centerPoint.y + translatedPoint.y;
        CGFloat falfWidth = self.cutContentImageView.width / 2;
        CGFloat falfHeight = self.cutContentImageView.height / 2;
        
        CGFloat centerX = (changeX - falfWidth) > 0 ? changeX : falfWidth;
        centerX = changeX + falfWidth < self.width ? centerX : self.width - falfWidth;
        centerX = MAX(centerX, falfWidth);
        centerX = MIN(centerX, self.width - falfWidth);
        
        CGFloat centerY = (changeY - falfHeight) > 0 ? changeY : falfHeight;
        centerY = changeY + falfHeight < self.height ? centerY : self.height - falfHeight;
        centerY = MAX(centerY, falfHeight);
        centerY = MIN(centerY, self.height - falfHeight);
        
        self.cutContentImageView.center = CGPointMake(centerX, centerY);
        [self setContentFrame:self.cutContentImageView.frame];
    } else {
        // 四面八方操作
        if (beginPoint.x <= kPanWidth * 2
            && (beginPoint.y > kPanWidth * 2 && beginPoint.y < _editContentFrame.size.height - kPanWidth)) {
            // 操作左边框
            if (self.cutContentImageView.width > kMinWidth) {
                offsetX = offsetX + translatedPoint.x;
            } else {
                offsetX = self.cutContentImageView.x;
            }
            
            if (offsetX > 0) {
                width = _editContentFrame.size.width - translatedPoint.x;
            } else {
                width = self.cutContentImageView.width;
            }
        } else if (beginPoint.y <= kPanWidth * 2
                   && (beginPoint.x > kPanWidth * 2 && beginPoint.x < _editContentFrame.size.width - kPanWidth)) {
            // 操作上边框
            if (self.cutContentImageView.height > kMinWidth) {
                offsetY = offsetY + translatedPoint.y;
            }else {
                offsetY = self.cutContentImageView.y;
            }
            
            if (offsetY > 0) {
                height  = _editContentFrame.size.height - translatedPoint.y;
            } else {
                height = self.cutContentImageView.height;
            }
        } else if (beginPoint.x >= _editContentFrame.size.width - kPanWidth * 2
                   && (beginPoint.y > kPanWidth * 2 && beginPoint.y < _editContentFrame.size.height - kPanWidth)) {
            // 操作右边框
            width  = _editContentFrame.size.width + translatedPoint.x;
            height = self.cutContentImageView.height;
        } else if (beginPoint.y >= _editContentFrame.size.height - kPanWidth * 2
                   && (beginPoint.x > kPanWidth * 2 && beginPoint.x < _editContentFrame.size.width - kPanWidth)) {
            // 操作下边框
            height  = _editContentFrame.size.height + translatedPoint.y;
            width  = self.cutContentImageView.width;
        } else if (beginPoint.x < kPanWidth * 2
                   && beginPoint.y < kPanWidth * 2) {
            // 操作左上角
            offsetX = offsetX + translatedPoint.x;
            offsetY = offsetY + translatedPoint.y;
            width   = width - translatedPoint.x;
            height  = height - translatedPoint.y;
        } else if (beginPoint.x > _editContentFrame.size.width - kPanWidth
                   && beginPoint.y < kPanWidth * 2) {
            // 操作右上角
            offsetY = offsetY + translatedPoint.y;
            width   = width + translatedPoint.x;
            height  = height - translatedPoint.y;
        } else if (beginPoint.x > _editContentFrame.size.width - kPanWidth
                   && beginPoint.y > _editContentFrame.size.height - kPanWidth) {
            // 操作右下角
            width   = width + translatedPoint.x;
            height  = height + translatedPoint.y;
        } else if (beginPoint.x < kPanWidth * 2
                   && beginPoint.y > _editContentFrame.size.height - kPanWidth) {
            // 操作左下角
            offsetX = offsetX + translatedPoint.x;
            width   = width - translatedPoint.x;
            height  = height + translatedPoint.y;
        }
        
        width  = width > kMinWidth ? width : kMinWidth;
        width  = MIN(width, self.width);
        height = height > kMinWidth ? height : kMinWidth;
        height = MIN(height, self.height);
        
        offsetX = offsetX + width > self.width ? self.width - width : offsetX;
        offsetX = MAX(offsetX, 0.0);
        
        offsetY = offsetY + height > self.height ? self.height - height : offsetY;
        offsetY = MAX(offsetY, 0.0);
        
        CGRect cutFrame = CGRectMake(offsetX, offsetY, width, height);
        [self setContentFrame:cutFrame];
    }
}

#pragma mark - getter
- (UIView *)boardPanView {
    if (!_boardPanView) {
        _boardPanView = [[UIView alloc] init];
        _boardPanView.userInteractionEnabled = YES;
        _boardPanView.backgroundColor = [UIColor clearColor];
    }
    return _boardPanView;
}

- (UIImageView *)cutContentImageView {
    if (!_cutContentImageView) {
        _cutContentImageView = [[UIImageView alloc] init];
        _cutContentImageView.userInteractionEnabled = YES;
        _cutContentImageView.backgroundColor = [UIColor clearColor];
        UIImage *img = [UIImage imageNamed:@"search_imagesearch_cutrect"];
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
        _cutContentImageView.image = img;
    }
    return _cutContentImageView;
}

- (void)setPreCutRect:(CGRect)cutFrame {
    if (!CGRectEqualToRect(cutFrame, CGRectZero)) {
        @weakify(self)
        CGRect frame = CGRectMake(cutFrame.origin.x - 3.0,  cutFrame.origin.y - 3.0, cutFrame.size.width + 6.0, cutFrame.size.height + 6.0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            [self setContentFrame:frame];
            [self setNeedsDisplay];

            self.editContentFrame = self.cutContentImageView.frame;
            self.centerPoint = self.cutContentImageView.center;
        });
    }
}


@end
