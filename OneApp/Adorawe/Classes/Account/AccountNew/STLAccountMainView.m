//
//  OSSVAccountsMainsView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVAccountsMainsView.h"
#import "STLAccountTableMenuView.h"
#import "STLAccountHeaderView.h"
#import "STLAccountTableFooterView.h"
#import "STLAccountHeaderBaseCell.h"
#import "OSSVAccountsMainViewAnalyseAP.h"
#import "STLWapBannerAPI.h"
#import "AccountManager.h"
@implementation STLAccountTableView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    UIView *unpaidOrderGoodsCollectionView = otherGestureRecognizer.view;
    if (unpaidOrderGoodsCollectionView
        && unpaidOrderGoodsCollectionView.tag == 444
        && unpaidOrderGoodsCollectionView.frame.size.height < 70) {
        return NO;//Cell中的滑动图片手势传递
    } else {
        return YES;
    }
}
@end



@interface OSSVAccountsMainsView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView                                 *topBackgroudColorView;
@property (nonatomic, weak) id<STLAccountVCProtocol>                 accountVCProtocol;
@property (nonatomic, strong) STLAccountTableMenuView                *menuView;
@property (nonatomic, strong) STLAccountTableFooterView              *tableFooterView;
@property (nonatomic, strong) OSSVAccountsMainViewAnalyseAP                  *analyticsAop;
@property (nonatomic, assign) CGFloat                                menuViewMinY;
@property (nonatomic, strong) CAGradientLayer                        *gradientLayer;
@property (nonatomic,assign) BOOL needShowBanner;
@end

@implementation OSSVAccountsMainsView


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithVCProtocol:(id<STLAccountVCProtocol>)actionProtocol {
    
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        self.accountVCProtocol = actionProtocol;
        self.canScroll = YES;
//        [[STLAnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAop];
        
        [self stlInitView];
        [self stlAutoLayoutView];
        [self addNotification];
        
        [self reloadAccountTableView];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSuperCanScrollStatus:) name:kNotif_AccountGoodsSupScrollStatus object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceieveBannerInfo:) name:kAccountBannerNotiName object:nil];
}

-(void)didReceieveBannerInfo:(NSNotification *)noti{
    self.needShowBanner  = noti.userInfo ? YES : NO;
    [self reloadAccountTableView];
}

- (void)setTableViewScrollToTop {
    if (self.tableView.scrollsToTop) {
        CGPoint point = (self.tableView.contentOffset.y == 0) ? CGPointMake(0, self.menuViewMinY) : CGPointZero;
        [self.tableView setContentOffset:point animated:YES];
    } else {
        [self.tableFooterView setScrollToTopAction];
    }
}

#pragma mark - tableviewDelegate

/// 刷新个人中心头部换肤
- (void)refreshHeadViewSkin {
//    [self.tableHeaderView changeAccountHeadInfoViewSkin];
}

/// 刷新个人中心头部头像
- (void)refreshHeadUserImage:(UIImage *)userImage {
    if (![userImage isKindOfClass:[UIImage class]])return;
//    self.tableHeaderView.avatorView.image = userImage;
}

/// 刷新浏览历史记录
- (void)refreshHistoryData {
    [self.tableFooterView refreshHistoryListData];
}

- (void)refreCategoryItemCell {
    for (NSInteger i=0; i<self.sectionTypeModelArr.count; i++){
        STLAccountHeaderCellTypeModel *sectionModel = self.sectionTypeModelArr[i];
        if (sectionModel.cellType == AccountHeaderCategoryItemCellType) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[UITableViewCell class]]) {
                if ([[self.tableView visibleCells] containsObject:cell]) {
                    [self.tableView reloadData];
                }
            }
            break;
        }
    }
}

- (void)endRefreshingData {
    [self.tableView.mj_header endRefreshing];
}

- (void)setRefreshRecommendFirstPage {
    [self.tableFooterView refreshRecommendToFirst];
}

/// 切换刷新表格
- (void)reloadAccountTableView {
    CGFloat totalHeight = [STLAccountHeaderView accountHeaderContentH:self.needShowBanner];

    [self.tableHeaderView reloadUserInfo];
    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, totalHeight);
    [self.tableView reloadData];
    [self layoutIfNeeded];
    for (NSInteger i=0; i<self.sectionTypeModelArr.count; i++) {

        CGFloat headerH = [self tableView:self.tableView heightForHeaderInSection:i];
        CGFloat footerH = [self tableView:self.tableView heightForFooterInSection:i];
        CGFloat cellH = 0;
        NSInteger sectionRowCount = [self tableView:self.tableView numberOfRowsInSection:i];
        for (NSInteger j=0; j<sectionRowCount; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            cellH = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
        }
        totalHeight += (headerH + cellH + footerH);
    }
    self.menuViewMinY = totalHeight - kSelectMenuViewHeight;
//    self.menuViewMinY = totalHeight;

//
    if (!self.topBackgroudColorView) {
        
        self.topBackgroudColorView = [[UIView alloc] initWithFrame:CGRectMake(0, -100, SCREEN_WIDTH, 250)];
        self.topBackgroudColorView.backgroundColor = [STLThemeColor col_0D0D0D];
        [self.tableView insertSubview:self.topBackgroudColorView atIndex:0];
        
//        self.topBackgroudColorView = [[UIView alloc] initWithFrame:CGRectMake(0, -200, KScreenWidth, self.menuViewMinY + 200)];
////        self.topBackgroudColorView.backgroundColor = STLCOLOR_RANDOM;
//        [self.tableView insertSubview:self.topBackgroudColorView atIndex:0];
//
//        //初始化CAGradientlayer对象，使它的大小为渐变背景视图的大小
//        self.gradientLayer = [CAGradientLayer layer];
//        self.gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.topBackgroudColorView.frame));
//        //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
//        self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
//        self.gradientLayer.endPoint = CGPointMake(0.0, 1.0);
//        // 设置渐变颜色的分割点
//
//        CGFloat startY = 200.0 / CGRectGetHeight(self.topBackgroudColorView.frame);
//        self.gradientLayer.locations = @[@(startY),@(startY)];
//
//        self.gradientLayer.type = kCAGradientLayerAxial;
//        self.gradientLayer.colors = colorsArray;
//        [self.topBackgroudColorView.layer addSublayer:self.gradientLayer];
//
    } else {
        [self.tableView insertSubview:self.topBackgroudColorView atIndex:0];

//        CGRect frame = self.topBackgroudColorView.frame;
//        frame.size.height = self.menuViewMinY + 200;
//        self.topBackgroudColorView.frame = frame;
//        [self.tableView insertSubview:self.topBackgroudColorView atIndex:0];
//
//        CGRect gradieFrame = self.gradientLayer.frame;
//        gradieFrame.size.height = CGRectGetHeight(self.topBackgroudColorView.frame);
//        self.gradientLayer.frame = gradieFrame;
//
//        CGFloat startY = 200.0 / CGRectGetHeight(self.topBackgroudColorView.frame);
//        self.gradientLayer.locations = @[@(startY),@(startY)];
    }
}

#pragma mark - <SetData>

- (void)setSectionTypeModelArr:(NSArray<STLAccountHeaderCellTypeModel *> *)sectionTypeModelArr {
    _sectionTypeModelArr = sectionTypeModelArr;
    [self reloadAccountTableView];
}

- (CGFloat)heightForFooter:(NSInteger)section {
    STLAccountHeaderCellTypeModel *sectionModel = self.sectionTypeModelArr[section];
    if (sectionModel.cellType == AccountHeaderHorizontalScrollCellType) {
        return 0;
    }
    return 0;
}

- (BOOL)showMenuForSection:(NSInteger)section {
    STLAccountHeaderCellTypeModel *sectionModel = self.sectionTypeModelArr[section];
    if (sectionModel.cellType == AccountHeaderHorizontalScrollCellType) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - <UITableViewDelegate>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTypeModelArr.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self showMenuForSection:section] ? self.menuView : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self showMenuForSection:section] ? kSelectMenuViewHeight : 0;
}

/** 警告: 这里不能重用的headerView会挡住未支付Cell中超出的顶部箭头
 *  STLAccountUnpaidOrderCell -> [UIImage imageNamed:@"unpaid_arrow_up"]
 */
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self heightForFooter:section] == 0) return nil;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 12)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self heightForFooter:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sectionTypeModelArr[section].sectionRowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.sectionTypeModelArr[indexPath.section].sectionRowHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionTypeModelArr.count <= indexPath.section)  {
        return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    }
    STLAccountHeaderCellTypeModel *sectionModel = self.sectionTypeModelArr[indexPath.section];
    STLAccountHeaderBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(sectionModel.sectionRowCellClass) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellTypeModel = sectionModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.topBackgroudColorView) {
        [self.tableView insertSubview:self.topBackgroudColorView atIndex:0];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = 95;
    CGPoint offset = scrollView.contentOffset;
    
    if ([self.accountVCProtocol respondsToSelector:@selector(scrollContentOffsetY:)]) {
        [self.accountVCProtocol scrollContentOffsetY:offset.y];
    }
    if (offset.y < -height) {
        offset.y = -height;
        [scrollView setContentOffset:offset];
        //STLLog(@"mai scrollViewDidScroll-------- return");
        return;
    }
    [self.tableView bringSubviewToFront:self.tableView.mj_header];
    
    if ([self.accountVCProtocol respondsToSelector:@selector(refreshNavgationBackgroundColorAlpha:)]) {
        CGFloat alpha = (offset.y) / height;
        [self.accountVCProtocol refreshNavgationBackgroundColorAlpha:alpha];
    }
    
    CGFloat headerOffsetY = self.menuViewMinY - self.navgationMaxY;
    
    if (self.canScroll) {
        if (scrollView.contentOffset.y >= headerOffsetY) {
            scrollView.contentOffset = CGPointMake(0, headerOffsetY);
            //STLLog(@"canScroll--------kkkk yes tableSrcoll:%i",self.canScroll);
            [self sendSubTabCanScroll:YES];
            _menuView.backgroundColor = [STLThemeColor stlWhiteColor];
        } else {
            //STLLog(@"canScroll--------kkkk NO tableSrcoll:%i",self.canScroll);
            [self sendSubTabCanScroll:NO];
            if (app_type == 3) {
                _menuView.backgroundColor = [STLThemeColor stlWhiteColor];
            } else {
                _menuView.backgroundColor = [STLThemeColor col_F5F5F5];
            }
        }
    } else {
        scrollView.contentOffset = CGPointMake(0, headerOffsetY);
        if (!scrollView.isDragging) {
            //STLLog(@"nocanScroll--------kkkk NO  tableSrcollToTop:%i",self.tableView.scrollsToTop);
            [self sendSubTabCanScroll:YES];
            _menuView.backgroundColor = [STLThemeColor stlWhiteColor];
        }
    }
}

- (void)sendSubTabCanScroll:(BOOL)status {
    NSDictionary *dic = @{
        @"status":@(status),
        @"type":@(self.menuView.selectIndex)
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_AccountGoodsSubScrollStatus object:nil userInfo:dic];
}

- (void)setSuperCanScrollStatus:(NSNotification *)notice {
    NSDictionary *dic = notice.userInfo;
    NSNumber *status = dic[@"status"];
    self.canScroll = [status boolValue];
    self.tableView.scrollsToTop = self.canScroll;
}


#pragma mark - <STLInitViewProtocol>

- (void)stlInitView {
    self.backgroundColor = [STLThemeColor stlWhiteColor];
    [self addSubview:self.tableView];
}

- (void)stlAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}


#pragma mark - <STLInitUI>

- (STLAccountHeaderView *)tableHeaderView {
    if (!_tableHeaderView) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, [STLAccountHeaderView accountHeaderContentH:NO]);
        _tableHeaderView = [[STLAccountHeaderView alloc] initWithFrame:rect];
        
        @weakify(self)
        _tableHeaderView.eventBlock = ^(AccountEventOperate event) {
            @strongify(self)
            if (self.accountHeaderEventBlock) {
                self.accountHeaderEventBlock(event);
            }
        };
        
        _tableHeaderView.bindPhoneBlock = ^(AccountBindPhoneOperate event) {
            @strongify(self)
            if (self.accountHeaderBindPhoeBlock) {
                self.accountHeaderBindPhoeBlock(event);
            }
        };
        
        _tableHeaderView.servicesBlock = ^(AccountServicesOperate service, NSString *title) {
            @strongify(self)
            if (self.accountHeaderServicesBlock) {
                self.accountHeaderServicesBlock(service, title);
            }
        };
        
        _tableHeaderView.orderBlock = ^(AccountOrderOperate type, NSString *title) {
            @strongify(self)
            if (self.accountHeadeOrderBlock) {
                self.accountHeadeOrderBlock(type, title);
            }
        };
        
        _tableHeaderView.typeBlock = ^(AccountTypeOperate type, NSString *title) {
            @strongify(self)
            if (self.accountHeaderTypeBlock) {
                self.accountHeaderTypeBlock(type,title);
            }
        };

        _tableHeaderView.backgroundColor = [STLThemeColor stlClearColor];
    }
    return _tableHeaderView;
}

- (STLAccountTableMenuView *)menuView {
    if (!_menuView) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kSelectMenuViewHeight);
        _menuView = [[STLAccountTableMenuView alloc] initWithFrame:rect];
        _menuView.backgroundColor = [STLThemeColor col_F5F5F5];
        if (APP_TYPE == 3) {
            _menuView.backgroundColor = [STLThemeColor stlWhiteColor];
            _menuView.isHiddenUnderLineView = NO;
        }
        _menuView.datasArray = @[STLLocalizedString_(@"Recently_viewed", nil),STLLocalizedString_(@"Account_Recommend", nil)];
        
        @weakify(self)
        _menuView.selectBlock = ^(NSInteger index) {
            @strongify(self)
            [self.tableFooterView selectCustomIndex:index];
        };
    }
    return _menuView;
}

- (STLAccountTableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[STLAccountTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [STLThemeColor stlClearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = self.tableHeaderView;
        _tableView.tableFooterView = self.tableFooterView;
        _tableView.clipsToBounds = NO; //为了后部下拉显示背景图
        
        if(@available(iOS 15.0,*)){_tableView.sectionHeaderTopPadding=0;}
        
        @weakify(self);
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self)
            if ([self.accountVCProtocol respondsToSelector:@selector(requestAccountPageAllData)]) {
                [self.accountVCProtocol requestAccountPageAllData];
            }
            [self setRefreshRecommendFirstPage];
        }];
        
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;

        // 隐藏状态
        header.stateLabel.hidden = YES;
        
        //mj_header.startViewOffsetY = 55;
        _tableView.mj_header = header;
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        /** 注册页面用到的所有Cell类型 */
        NSArray *cellTypeInfoArr = [STLAccountHeaderCellTypeModel fetchAllCellTypeArray];
        for (NSDictionary *cellTypeDict in cellTypeInfoArr) {
            Class sectionCellClass = cellTypeDict.allValues.firstObject;
            if (![sectionCellClass class]) continue;
            [_tableView registerClass:[sectionCellClass class] forCellReuseIdentifier:NSStringFromClass([sectionCellClass class])];
        }
        // 默认Cell
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        [_tableView registerClass:[STLAccountHeaderBaseCell class] forCellReuseIdentifier:NSStringFromClass([STLAccountHeaderBaseCell class])];
    }
    return _tableView;
}

- (STLAccountTableFooterView *)tableFooterView {
    if (!_tableFooterView) {
        CGFloat navMaxY = self.navgationMaxY;
        CGFloat tabbarH = 98;
        if ([self.accountVCProtocol respondsToSelector:@selector(fetchTabberHeight)]) {
             tabbarH = [self.accountVCProtocol fetchTabberHeight];
        }
        CGFloat pageHeight = SCREEN_HEIGHT - (navMaxY + kSelectMenuViewHeight + tabbarH);
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, pageHeight);
        
        @weakify(self);
        _tableFooterView = [[STLAccountTableFooterView alloc] initWithFrame:rect selectedGoodsBlock:^(id  _Nonnull goodsModel, AccountGoodsListType dataType, NSInteger index,NSString *requestId) {

            @strongify(self);
            if ([self.accountVCProtocol respondsToSelector:@selector(stl_selectedGoods:dataType:index:requestId:)]) {
                [self.accountVCProtocol stl_selectedGoods:goodsModel dataType:dataType index:index requestId:requestId];
            }
        }];
        _tableFooterView.backgroundColor = [STLThemeColor col_F5F5F5];
        _tableFooterView.selectIndexCompletion = ^(NSInteger index) {
            @strongify(self);
            self.menuView.selectIndex = index;
        };
    }
    return _tableFooterView;
}


- (CGFloat)navgationMaxY {
    CGFloat navMaxY = 98;
    if ([self.accountVCProtocol respondsToSelector:@selector(fetchNavgationMaxY)]) {
         navMaxY = [self.accountVCProtocol fetchNavgationMaxY];
    }
    return navMaxY;
}

- (OSSVAccountsMainViewAnalyseAP *)analyticsAop {
    if (!_analyticsAop) {
        _analyticsAop = [[OSSVAccountsMainViewAnalyseAP alloc] init];
    }
    return _analyticsAop;
}


@end
