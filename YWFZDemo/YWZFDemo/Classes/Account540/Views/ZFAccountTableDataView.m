//
//  ZFAccountTableDataView.m
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountTableDataView.h"
#import "AccountManager.h"
#import "ZFColorDefiner.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFAccountHeaderBaseCell.h"
#import "ZFAccountHeaderCReusableView.h"
#import "ZFAccountTableMenuView.h"
#import "ZFAccountTableFooterView.h"
#import "ZFNotificationDefiner.h"
#import "ZFRefreshHeader.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFAccountGoodsListView.h"
#import "ZFLocalizationString.h"
#import "ZFAccountTableDataViewAop.h"
#import "ZFPushManager.h"

@implementation ZFAccountTableView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    UIView *unpaidOrderGoodsCollectionView = otherGestureRecognizer.view;
    if (unpaidOrderGoodsCollectionView
        && unpaidOrderGoodsCollectionView.tag == 444
        && unpaidOrderGoodsCollectionView.frame.size.height < 70) {
        return NO;//丢弃未支付订单Cell中的滑动图片手势传递
    } else {
        return YES;
    }
}
@end


@interface ZFAccountTableDataView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView                                *topBackgroudColorView;
@property (nonatomic, weak) id<ZFAccountVCProtocol>                 accountVCProtocol;
@property (nonatomic, strong) ZFAccountTableMenuView                *menuView;
@property (nonatomic, strong) ZFAccountHeaderCReusableView          *tableHeaderView;
@property (nonatomic, strong) ZFAccountTableFooterView              *tableFooterView;
@property (nonatomic, strong) ZFAccountTableDataViewAop             *analyticsAop;
@property (nonatomic, assign) CGFloat                               menuViewMinY;
@property (nonatomic, assign) BOOL                                  canScroll;
@property (nonatomic, strong) CAGradientLayer                       *gradientLayer;
@end

@implementation ZFAccountTableDataView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithVCProtocol:(id<ZFAccountVCProtocol>)actionProtocol {
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    if (self) {
        self.accountVCProtocol = actionProtocol;
        self.canScroll = YES;
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAop];
        
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSuperCanScrollStatus:) name:kGoodsShowsDetailViewSuperScrollStatus object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPushTipView) name:kAppDidBecomeActiveNotification object:nil];
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

/// 刷新头部推送提醒框
- (void)reloadPushTipView {
    self.tableHeaderView.showType = ZFNewAccountInfoStatusNeedReload;
    [self.tableView reloadData];
}

///刷新用户登录状态
- (void)reloadUserLoginStatus {
    self.tableHeaderView.showType = ZFNewAccountInfoStatusNeedReload;
}

/// 刷新个人中心头部换肤
- (void)refreshHeadViewSkin {
    [self.tableHeaderView changeAccountHeadInfoViewSkin];
}

/// 刷新个人中心头部头像
- (void)refreshHeadUserImage:(UIImage *)userImage {
    if (![userImage isKindOfClass:[UIImage class]])return;
    self.tableHeaderView.avatorView.image = userImage;
}

/// 刷新浏览历史记录
- (void)refreshHistoryData {
    [self.tableFooterView refreshHistoryListData];
}

- (void)refreCategoryItemCell {
    for (NSInteger i=0; i<self.sectionTypeModelArr.count; i++){
        ZFAccountHeaderCellTypeModel *sectionModel = self.sectionTypeModelArr[i];
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
    [self.tableView reloadData];
    [self layoutIfNeeded];
    
    CGFloat totalHeight = self.tableHeaderView.bounds.size.height;
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
    
    if (!self.topBackgroudColorView) {
        self.topBackgroudColorView = [[UIView alloc] initWithFrame:CGRectMake(0, -200, KScreenWidth, self.menuViewMinY + 200)];
//        self.topBackgroudColorView.backgroundColor = ZFCOLOR_RANDOM;
        [self.tableView insertSubview:self.topBackgroudColorView atIndex:0];
        
        //初始化CAGradientlayer对象，使它的大小为渐变背景视图的大小
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = CGRectMake(0, 0, KScreenWidth, CGRectGetHeight(self.topBackgroudColorView.frame));
        //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
        self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        self.gradientLayer.endPoint = CGPointMake(0.0, 1.0);
        // 设置渐变颜色的分割点

        CGFloat startY = 200.0 / CGRectGetHeight(self.topBackgroudColorView.frame);
        self.gradientLayer.locations = @[@(startY),@(startY)];
        NSArray *colorsArray = @[(__bridge id)ColorHex_Alpha(0xEEEEEE, 1.0).CGColor,(__bridge id)ColorHex_Alpha(0xEEEEEE, 1.0).CGColor,(__bridge id)ColorHex_Alpha(0xFFFFFF, 1.0).CGColor];

        self.gradientLayer.type = kCAGradientLayerAxial;
        self.gradientLayer.colors = colorsArray;
        [self.topBackgroudColorView.layer addSublayer:self.gradientLayer];
        
    } else {
        CGRect frame = self.topBackgroudColorView.frame;
        frame.size.height = self.menuViewMinY + 200;
        self.topBackgroudColorView.frame = frame;
        [self.tableView insertSubview:self.topBackgroudColorView atIndex:0];

        CGRect gradieFrame = self.gradientLayer.frame;
        gradieFrame.size.height = CGRectGetHeight(self.topBackgroudColorView.frame);
        self.gradientLayer.frame = gradieFrame;
        
        CGFloat startY = 200.0 / CGRectGetHeight(self.topBackgroudColorView.frame);
        self.gradientLayer.locations = @[@(startY),@(startY)];
    }
   
}

#pragma mark - <SetData>

- (void)setSectionTypeModelArr:(NSArray<ZFAccountHeaderCellTypeModel *> *)sectionTypeModelArr {
    _sectionTypeModelArr = sectionTypeModelArr;
    [self reloadAccountTableView];
}

- (CGFloat)heightForFooter:(NSInteger)section {
    ZFAccountHeaderCellTypeModel *sectionModel = self.sectionTypeModelArr[section];
    if (sectionModel.cellType == AccountHeaderHorizontalScrollCellType) {
        return 0;
    }
    return 0;
}

- (BOOL)showMenuForSection:(NSInteger)section {
    ZFAccountHeaderCellTypeModel *sectionModel = self.sectionTypeModelArr[section];
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
 *  ZFAccountUnpaidOrderCell -> [UIImage imageNamed:@"unpaid_arrow_up"]
 */
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self heightForFooter:section] == 0) return nil;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 12)];
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
    return self.sectionTypeModelArr[indexPath.section].sectionRowHeight;;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionTypeModelArr.count <= indexPath.section)  {
        return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    }
    ZFAccountHeaderCellTypeModel *sectionModel = self.sectionTypeModelArr[indexPath.section];
    ZFAccountHeaderBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(sectionModel.sectionRowCellClass) forIndexPath:indexPath];
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
    if (offset.y < -height) {
        offset.y = -height;
        [scrollView setContentOffset:offset];
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
            [self sendSubTabCanScroll:YES];
        } else {
            [self sendSubTabCanScroll:NO];
        }
    } else {
        scrollView.contentOffset = CGPointMake(0, headerOffsetY);
        if (!scrollView.isDragging) {
            [self sendSubTabCanScroll:YES];
        }
    }
}

- (void)sendSubTabCanScroll:(BOOL)status {
    NSDictionary *dic = @{
        @"status":@(status),
        @"type":@(self.menuView.selectIndex)
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:kGoodsShowsDetailViewSubScrollStatus object:nil userInfo:dic];
}

- (void)setSuperCanScrollStatus:(NSNotification *)notice {
    NSDictionary *dic = notice.userInfo;
    NSNumber *status = dic[@"status"];
    self.canScroll = [status boolValue];
    self.tableView.scrollsToTop = self.canScroll;
}

- (CGFloat)navgationMaxY {
    CGFloat navMaxY = 98;
    if ([self.accountVCProtocol respondsToSelector:@selector(fetchNavgationMaxY)]) {
         navMaxY = [self.accountVCProtocol fetchNavgationMaxY];
    }
    return navMaxY;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - <ZFInitUI>

- (ZFAccountHeaderCReusableView *)tableHeaderView {
    if (!_tableHeaderView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, 116 + 44 + STATUSHEIGHT);
        _tableHeaderView = [[ZFAccountHeaderCReusableView alloc] initWithFrame:rect];
        _tableHeaderView.showType = ![AccountManager sharedManager].isSignIn;
        _tableHeaderView.delegate = self.accountVCProtocol;
        _tableHeaderView.backgroundColor = ZFCClearColor();
        @weakify(self)
        _tableHeaderView.closeBlock = ^{
            @strongify(self)
            [ZFPushManager saveShowAlertTimestampWithKey:kAccountShowNotificationAlertTimestamp];
            [self reloadUserLoginStatus];
            [self.tableView reloadData];
        };
        _tableHeaderView.openBlock = ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        };
    }
    return _tableHeaderView;
}

- (ZFAccountTableMenuView *)menuView {
    if (!_menuView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, kSelectMenuViewHeight);
        _menuView = [[ZFAccountTableMenuView alloc] initWithFrame:rect];
        _menuView.backgroundColor = ZFC0xFFFFFF();
        _menuView.datasArray = @[ZFLocalizedString(@"Account_Discover_title", nil), ZFLocalizedString(@"History_View_Title", nil)];
        
        @weakify(self)
        _menuView.selectBlock = ^(NSInteger index) {
            @strongify(self)
            [self.tableFooterView selectCustomIndex:index];
        };
    }
    return _menuView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[ZFAccountTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = ZFCClearColor();
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = self.tableHeaderView;
        _tableView.tableFooterView = self.tableFooterView;
        _tableView.clipsToBounds = NO; //为了后部下拉显示背景图
        
        @weakify(self);
        ZFRefreshHeader *mj_header = [ZFRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self)
            if ([self.accountVCProtocol respondsToSelector:@selector(requestAccountPageAllData)]) {
                [self.accountVCProtocol requestAccountPageAllData];
            }
            [self setRefreshRecommendFirstPage];
        }];
        mj_header.startViewOffsetY = 55;
        _tableView.mj_header = mj_header;
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        /** 注册页面用到的所有Cell类型 */
        NSArray *cellTypeInfoArr = [ZFAccountHeaderCellTypeModel fetchAllCellTypeArray];
        for (NSDictionary *cellTypeDict in cellTypeInfoArr) {            
            Class sectionCellClass = cellTypeDict.allValues.firstObject;
            if (![sectionCellClass class]) continue;
            [_tableView registerClass:[sectionCellClass class] forCellReuseIdentifier:NSStringFromClass([sectionCellClass class])];
        }
        // 默认Cell
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _tableView;
}

- (ZFAccountTableFooterView *)tableFooterView {
    if (!_tableFooterView) {
        CGFloat navMaxY = self.navgationMaxY;
        CGFloat tabbarH = 98;
        if ([self.accountVCProtocol respondsToSelector:@selector(fetchTabberHeight)]) {
             tabbarH = [self.accountVCProtocol fetchTabberHeight];
        }
        CGFloat pageHeight = KScreenHeight - (navMaxY + kSelectMenuViewHeight + tabbarH);
        CGRect rect = CGRectMake(0, 0, KScreenWidth, pageHeight);
        
        @weakify(self);
        _tableFooterView = [[ZFAccountTableFooterView alloc] initWithFrame:rect selectedGoodsBlock:^(ZFGoodsModel *goodsModel, ZFAccountRecommendSelectType dataType) {
            @strongify(self);
            if ([self.accountVCProtocol respondsToSelector:@selector(selectedGoods:dataType:)]) {
                [self.accountVCProtocol selectedGoods:goodsModel dataType:dataType];
            }
        }];
        _tableFooterView.backgroundColor = ZFC0xFFFFFF();
        
        _tableFooterView.selectIndexCompletion = ^(NSInteger index) {
            @strongify(self);
            self.menuView.selectIndex = index;
        };
    }
    return _tableFooterView;
}

- (ZFAccountTableDataViewAop *)analyticsAop {
    if (!_analyticsAop) {
        _analyticsAop = [[ZFAccountTableDataViewAop alloc] init];
    }
    return _analyticsAop;
}


@end
