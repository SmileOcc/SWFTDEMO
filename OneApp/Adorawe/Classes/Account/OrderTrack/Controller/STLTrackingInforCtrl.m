//
//  STLTrackingInforCtrl.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLTrackingInforCtrl.h"
#import "DLCustomSlideView.h"
#import "DLScrollTabbarView.h"
#import "DLLRUCache.h"
#import "STLTrackingItemCtrl.h"
#import "OSSVTrackingccInfomatViewModel.h"

@interface STLTrackingInforCtrl ()<DLCustomSlideViewDelegate>

@property (nonatomic, strong) DLCustomSlideView *slideView;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) OSSVTrackingccInfomatViewModel *viewModel;
@property (nonatomic, strong) UIScrollView *emptyBackView;

@end

@implementation STLTrackingInforCtrl

#pragma mark Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"trackingTitle",nil);
    self.view.backgroundColor = OSSVThemesColors.col_FFFFFF;
    [self initEmptySubViews];
    [self requsetLoadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 谷歌统计
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
}
#pragma mark - Method 
- (void)requsetLoadData {
    
    if (! (self.orderNumber.length > 0)) return;
    @weakify(self)
    [self.viewModel requestNetwork:self.orderNumber completion:^(id obj) {
        @strongify(self)
        self.dataArray = [NSArray arrayWithArray:obj];
        if (self.dataArray.count > 0) {
            [self loadDataAndInitDLCustomSlideView];
            [self.emptyBackView removeFromSuperview];
        }
        else {
            self.emptyBackView.hidden = NO;
        }
    } failure:^(id obj) {
        @strongify(self)
        self.emptyBackView.hidden = NO;
    }];

}
#pragma mark 当空白的时候点击
- (void)emptyHomeTapAction {
    [self.emptyBackView.mj_header beginRefreshing];
}

#pragma mark - Delegate
#pragma mark DLCustomSlideDelegate
- (NSInteger)numberOfTabsInDLCustomSlideView:(DLCustomSlideView *)sender{
    return self.itemArray.count;
}

- (UIViewController *)DLCustomSlideView:(DLCustomSlideView *)sender controllerAt:(NSInteger)index{
    STLTrackingItemCtrl *trackItemVC  = [[STLTrackingItemCtrl alloc] init];
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        index = self.dataArray.count - 1 - index;
    }
    OSSVTrackingcInformationcModel *model = self.dataArray[index];
    model.shippingName = self.shippingMethod;
    trackItemVC.OSSVTrackingcInformationcModel = self.dataArray[index];
    return trackItemVC;
}

#pragma mark- MakeUI
- (void)loadDataAndInitDLCustomSlideView {
    
    DLCustomSlideView *slideView = [[DLCustomSlideView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:slideView];
    [slideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    self.slideView = slideView;
    self.slideView.delegate = self;
    self.slideView.tabbarBottomSpacing = 0;
    self.slideView.baseViewController = self;
 
    DLLRUCache *cache = [[DLLRUCache alloc] initWithCount:self.dataArray.count];
    self.slideView.cache = cache;
   
    // 假如只有一个 包裹的时候，不需要滑动
    if (self.dataArray.count > 1) {
        DLScrollTabbarView *tabbar = [[DLScrollTabbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 38)];
        // 设置 tab 各种属性
        tabbar.tabItemNormalColor = OSSVThemesColors.col_333333;
        tabbar.tabItemSelectedColor = OSSVThemesColors.col_333333;
        tabbar.tabItemNormalFontSize = 14.0f;
        tabbar.trackColor = OSSVThemesColors.col_FDD835;
        // 额外设置线宽
        NSString *tempTitle = [NSString stringWithFormat:@"%@ 1",STLLocalizedString_(@"package", nil)];
        CGFloat titleWidth = [tempTitle textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(SCREEN_WIDTH, 38) lineBreakMode:NSLineBreakByWordWrapping].width;
        tabbar.trackLineViewMoreWidth = SCREEN_WIDTH / 2.0 - titleWidth - 10; // 增加线宽
        // 添加 tabbar
        self.itemArray = [NSMutableArray array];
        NSInteger i = 0;
        NSInteger count = self.dataArray.count;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            i = self.dataArray.count;
            for (; i > 0; i--) {
                // 暂时先这样确定名字
                NSString *title = [NSString stringWithFormat:@"%@ %ld", STLLocalizedString_(@"package", nil),(long)(i)];
                DLScrollTabbarItem *item = [DLScrollTabbarItem itemWithTitle:title width:SCREEN_WIDTH/2.0];
                [self.itemArray addObject:item];
            }
        }else{
            for (; i < count; i++) {
                // 暂时先这样确定名字
                NSString *title = [NSString stringWithFormat:@"%@ %ld", STLLocalizedString_(@"package", nil),(long)(i + 1)];
                DLScrollTabbarItem *item = [DLScrollTabbarItem itemWithTitle:title width:SCREEN_WIDTH/2.0];
                [self.itemArray addObject:item];
            }
        }
        
        tabbar.tabbarItems = self.itemArray;
        self.slideView.tabbar = tabbar;
        self.slideView.enableScroller = YES;
    }else{
        self.itemArray = [self.dataArray mutableCopy];
        self.slideView.enableScroller = NO;
    }

    [self.slideView setup];
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.slideView.selectedIndex = [self.itemArray count] - 1;
    }else{
        self.slideView.selectedIndex = 0;
    }
}
#pragma mark - 空白View
- (void)initEmptySubViews {
    
    self.emptyBackView = [[UIScrollView alloc] init];
    self.emptyBackView.hidden = YES;
    [self.view addSubview:self.emptyBackView];
    [self.emptyBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    // 这样做是为了增加  菊花的刷新效果
    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestNetwork:STLRefresh completion:^(id obj) {
            @strongify(self)
            [self requsetLoadData];
            [self.emptyBackView.mj_header endRefreshing];
        } failure:^(id obj) {
            @strongify(self)
            [self.emptyBackView.mj_header endRefreshing];
        }];
    }];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.emptyBackView.mj_header = header;
    
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"loading_failed"];
    [self.emptyBackView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.emptyBackView.mas_top).offset(52 * DSCREEN_HEIGHT_SCALE);
        make.centerX.mas_equalTo(self.emptyBackView.mas_centerX);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = OSSVThemesColors.col_333333;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = STLLocalizedString_(@"load_failed", nil);;
    [self.emptyBackView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(36);
        make.centerX.mas_equalTo(self.emptyBackView.mas_centerX);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [OSSVThemesColors col_262626];
    button.titleLabel.font = [UIFont stl_buttonFont:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (APP_TYPE == 3) {
        [button setTitle:STLLocalizedString_(@"retry", nil) forState:UIControlStateNormal];
    } else {
        [button setTitle:STLLocalizedString_(@"retry", nil).uppercaseString forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(emptyHomeTapAction) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [self.emptyBackView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(33);
        make.centerX.mas_equalTo(self.emptyBackView.mas_centerX);
        make.width.mas_equalTo(@180);
        make.height.mas_equalTo(@40);
    }];
    
}


#pragma mark - LazyLoad

- (OSSVTrackingccInfomatViewModel *)viewModel {
    
    if (!_viewModel) {
        _viewModel = [[OSSVTrackingccInfomatViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

@end
