//
//  YXCommonUGCViewController.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXCommonUGCViewController.h"
#import "uSmartOversea-Swift.h"
//#import "YXReviewLiveViewModel.h"
#import "YXWatchLiveViewModel.h"
#import "YXStockCommentDetailViewModel.h"

@implementation YXUGCContentView
@end

@interface PushAnimation: NSObject <UIViewControllerAnimatedTransitioning, CAAnimationDelegate>

@property (nonatomic, copy) dispatch_block_t completeBlock;

@property (nonatomic, assign) BOOL pullNext;

@end

@implementation PushAnimation

//用来处理具体的动画
- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    YXCommonUGCViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    YXCommonUGCViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (![fromVC isKindOfClass:[YXCommonUGCViewController class]] || ![toVC isKindOfClass:[YXCommonUGCViewController class]]) {
        return;
    }
    
    UIView *toView = toVC.view;
    [[transitionContext containerView] addSubview:toView];
    [toVC.contentView addSubview:fromVC.contentView];
    toVC.contentView.clipsToBounds = NO;
    [self beginAnimation:toVC.contentView from:fromVC.contentView];
    
    @weakify(fromVC, toVC, transitionContext)
    self.completeBlock = ^{
        @strongify(fromVC, toVC, transitionContext)
        [transitionContext completeTransition:YES];
        
        [fromVC.contentView removeFromSuperview];
        toVC.contentView.clipsToBounds = YES;
        [toVC.contentView.layer removeAnimationForKey:@"animation"];

        NSMutableArray *navControllers = [toVC.navigationController.viewControllers mutableCopy];
        [navControllers removeObject:fromVC];
        toVC.navigationController.viewControllers = navControllers;
    };
}

- (void)beginAnimation:(UIView *)toView from:(UIView *)fromView {
    CGRect toFrame = toView.frame;
    if (self.pullNext) {
        fromView.y = -CGRectGetHeight(toFrame);
    } else {
        fromView.y = CGRectGetHeight(toFrame);
    }
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.y";
    if (self.pullNext) {
        animation.fromValue = @(CGRectGetMaxY(toFrame) + CGRectGetHeight(toFrame)/2.0);
    } else {
        animation.fromValue = @(CGRectGetMinY(toFrame) - CGRectGetHeight(toFrame)/2.0);
    }
    animation.toValue = @(CGRectGetMinY(toFrame) + CGRectGetHeight(toFrame)/2.0);

    animation.duration = 0.2f;
    animation.beginTime = 0.f;
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [toView.layer addAnimation:animation forKey:@"animation"];
}

//设置动画执行的时长
- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2f;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim {
    NSLog(@"开始执行自定义的动画");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        NSLog(@"动画正常结束");
    }
    if (self.completeBlock) {
        self.completeBlock();
    }
}

@end

@interface YXCommonUGCViewController () <UINavigationControllerDelegate>

@property (nonatomic, strong, readwrite) YXUGCContentView *contentView;
@property (nonatomic, strong, readwrite) YXUGCPublisherView *navBarPublisherView;

@property (nonatomic, strong) NSMutableDictionary *feedNext;
@property (nonatomic, strong) NSMutableDictionary *feedPrev;

@end

@implementation YXCommonUGCViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = QMUITheme.foregroundColor;
//    [self.yx_navigationbar setBottomLineHidden:YES];
//    if ([self alwaysShowNavBarPublisher]) {
//        [self.yx_navigationbar setBottomLineHidden:NO];
//    }
//    [self.yx_navigationbar addSubview:self.navBarPublisherView];
//    [self.navBarPublisherView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(32);
//        make.top.mas_equalTo(YXConstant.statusBarHeight);
//        make.right.equalTo(self.yx_navigationbar).offset(-44);
//        make.height.mas_equalTo(44);
//    }];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.navigationItem.titleView = self.navBarPublisherView;

    self.contentView = [[YXUGCContentView alloc] initWithFrame:CGRectMake(0, YXConstant.navBarHeight, self.view.width, self.view.height - YXConstant.navBarHeight)];
    self.contentView.showsVerticalScrollIndicator = NO;
    [self.view insertSubview:self.contentView atIndex:0];
    
    if (@available(iOS 11.0, *)) {
        self.contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UIScrollView *scrollView = [self scrollView];
    if (scrollView) {
        scrollView.frame = CGRectMake(0, [self topHeight], self.contentView.width, self.contentView.height - [self bottomHeight] - [self topHeight]);
        scrollView.bounces = NO;
        [self.contentView addSubview:scrollView];
    }
        
    NSString *show_time = self.viewModel.params[@"show_time"];
    NSString *cid = self.viewModel.params[@"cid"];
    NSString *query_token = self.viewModel.params[@"query_token"];

    if (show_time && cid && query_token) {
        self.navigationController.delegate = self;
        @weakify(self)
        YXFeedContextRequestModel *requestModel = [[YXFeedContextRequestModel alloc] init];
        requestModel.cid = cid;
        requestModel.show_time = show_time;
        requestModel.query_token = query_token;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseCodeSuccess) {
                NSString *query_token = responseModel.data[@"query_token"];
                
                NSArray *next = responseModel.data[@"feed_next"];
                if ([next isKindOfClass:[NSArray class]] && [next.firstObject isKindOfClass:[NSDictionary class]]) {
                    self.feedNext = [next.firstObject mutableCopy];
                    self.feedNext[@"query_token"] = query_token;
                    self.contentView.mj_footer = [YXUGCRefreshFooter footerWithRefreshingBlock:^{
                        @strongify(self)
                        self.pullNext = @YES;
                        [self.contentView.mj_footer endRefreshing];
                        [self pushUGCWithContentType:[self.feedNext[@"content_type"] intValue]];
                    }];
                }
                 
                NSArray *prev = responseModel.data[@"feed_prev"];
                if ([prev isKindOfClass:[NSArray class]] && [prev.firstObject isKindOfClass:[NSDictionary class]]) {
                    self.feedPrev = [prev.firstObject mutableCopy];
                    self.feedPrev[@"query_token"] = query_token;
                    self.contentView.mj_header = [YXUGCRefreshHeader headerWithRefreshingBlock:^{
                        @strongify(self)
                        self.pullNext = @NO;
                        [self.contentView.mj_header endRefreshing];
                        [self pushUGCWithContentType:[self.feedPrev[@"content_type"] intValue]];
                    }];
                }
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            
        }];
    } else {
        scrollView.bounces = YES;
    }
}

- (void)pushUGCWithContentType:(YXInformationFlowType)type {
    NSDictionary *params;
    if (self.pullNext.boolValue) {
        params = self.feedNext;
    } else {
        params = self.feedPrev;
    }
    YXViewModel *viewModel;

    NSString *adName = @"";
    switch (type) {
        case YXInformationFlowTypeLive:
            viewModel = [[YXWatchLiveViewModel alloc] initWithServices:self.viewModel.services params:params];
            adName = @"直播详情页";
            break;
        case YXInformationFlowTypeReplay:
            //TODO:屏蔽回访详情
//            viewModel = [[YXReviewLiveViewModel alloc] initWithServices:self.viewModel.services params:params];
            adName = @"回放详情页";
            break;
        case YXInformationFlowTypeStockdiscuss:
            viewModel = [[YXStockCommentDetailViewModel alloc] initWithServices:self.viewModel.services params:params];
            adName = @"讨论详情页";
            break;
        default:
            break;
    }
    [self.viewModel.services pushViewModel:viewModel animated:YES];

}

- (YXUGCPublisherView *)navBarPublisherView {
    if (_navBarPublisherView == nil) {
        _navBarPublisherView = [[YXUGCPublisherHeadView alloc] initWithStyle:PublisherStyleNavBar];
        _navBarPublisherView.hidden = ![self alwaysShowNavBarPublisher];
    }
    return _navBarPublisherView;
}

- (__kindof UIScrollView * _Nullable)scrollView {
    return nil;
}

- (CGFloat)bottomHeight {
    return 0;
}

- (CGFloat)topHeight {
    return 0;
}

- (BOOL)alwaysShowNavBarPublisher {
    return false;
}

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (self.pullNext && [fromVC isKindOfClass:[YXCommonUGCViewController class]]
        && [toVC isKindOfClass:[YXCommonUGCViewController class]]
        && operation == UINavigationControllerOperationPush) {
        PushAnimation *animation = [[PushAnimation alloc] init];
        animation.pullNext = self.pullNext.boolValue;
        self.pullNext = nil;
        return animation;
    }
    return nil;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    NSLog(@"控制器挂了.");
}

@end
