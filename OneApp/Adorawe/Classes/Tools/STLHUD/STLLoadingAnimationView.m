//
//  STLLoadingAnimationView.m
// XStarlinkProject
//
//  Created by odd on 2020/7/18.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLLoadingAnimationView.h"

//static CGFloat const kContentViewH = 72.f;

@interface STLLoadingAnimationView ()
//@property (nonatomic,strong) LOTAnimationView *animView;
@end

@implementation STLLoadingAnimationView

//- (CGSize)intrinsicContentSize {
//    CGFloat contentViewH = kContentViewH;
//    CGFloat contentViewW = kContentViewH;
//    return CGSizeMake(contentViewW, contentViewH);
//}
//
//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self configureUI];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
//    }
//    return self;
//}
//
//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    STLLog(@"释放请求loading动画");
//}
//
//- (void)appDidBecomeActive
//{
//    [self.animView play];
//    STLLog(@"激活请求loading动画");
//}
//
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//}
//
//- (void)willMoveToSuperview:(UIView *)newSuperview {
//    if (newSuperview) {
//        [self.animView play];
//    } else {
//        [self.animView stop];
//    }
//}
//
//- (void)configureUI {
//    self.animView = [LOTAnimationView animationNamed:@"Adorawe_loading_pushloading"];
//    self.animView.frame = self.bounds;
//    [self addSubview:self.animView];
//    self.animView.loopAnimation = YES;
//}

@end
