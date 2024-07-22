//
//  ZFOutfitsWorkSpaceView.m
//  ZZZZZ
//
//  Created by YW on 2018/5/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOutfitsWorkSpaceView.h"
#import "ZFOutfitItemView.h"
#import "Constants.h"
#import "ZFOutfitBuilderSingleton.h"

@interface ZFOutfitsWorkSpaceView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) ZFOutfitItemView          *currentfitItemView;
@property (nonatomic, strong) NSMutableArray            *outfitItemArray;

@property (nonatomic, assign) CGPoint                   currentItemCenterPoint;
@property (nonatomic, assign) CGRect                    currentItemFrame;

@end

@implementation ZFOutfitsWorkSpaceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.outfitItemArray = [NSMutableArray new];
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
        [panGesture addTarget:self action:@selector(positionPanAction:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
        
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] init];
        [pinchGesture addTarget:self action:@selector(pinchAction:)];
        pinchGesture.delegate = self;
        [self addGestureRecognizer:pinchGesture];
        
        
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] init];
        [rotationGesture addTarget:self action:@selector(rotationAction:)];
        rotationGesture.delegate = self;
        [self addGestureRecognizer:rotationGesture];

    }
    return self;
}


- (void)setCanvasWithImage:(UIImage *)image {
    self.image = image;
}

#pragma mark - GestureRecognizer

- (void)tapAction {
    [self resetAllItemStatus:YES];
    YWLog(@"--------tap");
}

- (void)positionPanAction:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint translatedPoint = [panGesture translationInView:self];
    YWLog(@"--------pan: x:%f   y:%f",translatedPoint.x,translatedPoint.y);
    if (self.currentfitItemView) {
        
        CGPoint currentCentPoint = self.currentItemCenterPoint;
        switch (panGesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                currentCentPoint = CGPointMake(self.currentItemCenterPoint.x + translatedPoint.x, self.currentItemCenterPoint.y + translatedPoint.y);
                self.currentfitItemView.center = currentCentPoint;
                [self setNeedsDisplay];
                break;
            }
            case UIGestureRecognizerStateEnded: {
                self.currentItemCenterPoint = self.currentfitItemView.center;
                self.currentItemFrame = self.currentfitItemView.frame;
                
                break;
            }
            default:
                break;
        }
    }
    
}


- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {
    
    YWLog(@"--------pinch");
    if (self.currentfitItemView) {
        
        switch (pinch.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                CGFloat height = self.currentItemFrame.size.height * pinch.scale;
                CGFloat width  = self.currentItemFrame.size.width * pinch.scale;
                YWLog(@"--------pinch: height:%f   width:%f",height,width);

                self.currentfitItemView.bounds    = CGRectMake(0.0, 0.0, width, height);
                [self.currentfitItemView changeContentImageSize];
                
                [self setNeedsDisplay];
                break;
            }
            case UIGestureRecognizerStateEnded: {
                self.currentItemFrame = self.currentfitItemView.frame;
                self.currentItemCenterPoint = self.currentfitItemView.center;
                break;
            }
            default:
                break;
        }
    }
}


- (void)rotationAction:(UIRotationGestureRecognizer *)rotationGesture {
    YWLog(@"--------rotation");
    if (self.currentfitItemView) {
        self.currentfitItemView.transform = CGAffineTransformRotate(self.currentfitItemView.transform, rotationGesture.rotation) ;
        rotationGesture.rotation = 0 ;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - Public Method

- (void)addNewOutfitItemWithItemModel:(ZFOutfitItemModel *)itemModel {
    ZFOutfitItemView *outfitItemView = [[ZFOutfitItemView alloc] initWithItemModel:itemModel mainView:self];
    @weakify(self)
    outfitItemView.tapItemBlock = ^(ZFOutfitItemView *itemView) {
        @strongify(self)
        self.currentfitItemView = itemView;
        self.currentItemCenterPoint = self.currentfitItemView.center;
        self.currentItemFrame = self.currentfitItemView.frame;
        [self resetAllItemStatus:NO];
    };
    
    [self addSubview:outfitItemView];
    [self.outfitItemArray addObject:outfitItemView];
    [self.currentfitItemView itemStatus:NO];
    
    self.currentfitItemView = outfitItemView;
    self.currentItemCenterPoint = self.currentfitItemView.center;
    self.currentItemFrame = self.currentfitItemView.frame;
    
    [self resetAllItemStatus:NO];
}


- (void)deleteSelectOutfitItemView {
    if (self.currentfitItemView) {
        if ([self.outfitItemArray containsObject:self.currentfitItemView]) {
            
            [[ZFOutfitBuilderSingleton shareInstance] deleteSelectedOutfitItem:self.currentfitItemView.itemModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:kOutfitItemCountChange object:nil];
            if (self.currentfitItemView.superview) {
                [self.currentfitItemView removeFromSuperview];
            }
            [self.outfitItemArray removeObject:self.currentfitItemView];
            self.currentfitItemView = nil;
            
            [self resetAllItemStatus:YES];
            
            if (self.deleteItem) {
                self.deleteItem();
            }
        }
    }
   
}

//重置选中
- (void)resetAllItemStatus:(BOOL)resetAll {
    if (resetAll) {
        self.currentfitItemView = nil;
        self.currentItemCenterPoint = CGPointZero;
        self.currentItemFrame = CGRectZero;
    }
    BOOL hasSelected = NO;
    if (self.currentfitItemView) {
        hasSelected = [self.outfitItemArray containsObject:self.currentfitItemView];
    }
    for (ZFOutfitItemView *outfitItemView in self.outfitItemArray) {
        if (hasSelected) {
            if (outfitItemView == self.currentfitItemView) {
                [outfitItemView itemStatus:YES];
                outfitItemView.alpha = 1.0;
            } else {
                [outfitItemView itemStatus:NO];
                outfitItemView.alpha = 0.5;
            }
        } else {
            [outfitItemView itemStatus:NO];
            outfitItemView.alpha = 1.0;
        }
    }
    
    if (self.cancelAllSelectBlock) {
        self.cancelAllSelectBlock(resetAll);
    }
}

- (ZFOutfitItemView *)currentSelectItemView {
    return self.currentfitItemView;
}


- (void)upOutfitItem {
    [self exChangeItemIndexIsUp:YES];
}

- (void)downOufitItem {
    [self exChangeItemIndexIsUp:NO];
}

- (void)exChangeItemIndexIsUp:(BOOL)isUp {

    NSInteger currentIndex = [self.outfitItemArray indexOfObject:self.currentfitItemView];
    if (isUp) {
        NSInteger nextIndex = currentIndex + 1;
        if (self.outfitItemArray.count > nextIndex) {
            [self exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:nextIndex];
            [self.outfitItemArray exchangeObjectAtIndex:nextIndex withObjectAtIndex:currentIndex];
        }
    } else {
        NSInteger upIndex = currentIndex - 1;
        if (upIndex >= 0 && self.outfitItemArray.count > currentIndex) {

            [self exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:upIndex];
            [self.outfitItemArray exchangeObjectAtIndex:upIndex withObjectAtIndex:currentIndex];
        }
    }
}

@end
