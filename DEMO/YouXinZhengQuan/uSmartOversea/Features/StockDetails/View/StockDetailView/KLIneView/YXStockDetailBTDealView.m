//
//  YXStockDetailBTDealView.m
//  uSmartOversea
//
//  Created by youxin on 2021/5/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXStockDetailBTDealView.h"
#import "YXStockDealDeatailCell.h"
#import "YXRefresh.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"
#import "UILabel+create.h"
#import "YYCategoriesMacro.h"

//MARK: 头部view
@implementation YXStockDetailBTDealHeaderView

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI{

    self.clipsToBounds = YES;

    self.backgroundColor = [QMUITheme foregroundColor];
    UILabel *timeLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stock_deal_time"] textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize: 14]];
    [self addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.equalTo(self).offset(16);
    }];

    UILabel *changeLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"economic_change_volume"] textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize: 14]];
    [self addSubview:changeLabel];
    [changeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.equalTo(self).offset(-16);
    }];


    UILabel *priceLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"market_now"] textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize: 14]];
    [self addSubview:priceLabel];
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.equalTo(self).offset(-168 * YXConstant.screenWidth / 375.0);
    }];

}

@end

@interface YXStockDetailBTDealView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXStockDetailBTDealHeaderView *headerView;
@property (nonatomic, strong) UITableView *dealTableView; //逐笔交易明细
// 是否允许滚动到底部
@property (nonatomic, assign) BOOL allowedScrollToBottom;

// 如果当前不允许滚动到底部，则使用这个定时器，过3秒后恢复到允许滚动状态
//@property (nonatomic, strong) RACDisposable *allowedScrollDisposable;

@property (nonatomic, assign) BOOL isRefresh;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) YXTimerFlag timeFlag;

@property (nonatomic, strong) UIImage *redImage;
@property (nonatomic, strong) UIImage *greenImage;

@property (nonatomic, strong) UIColor *greyColor;
@property (nonatomic, strong) UIColor *stockRedColor;
@property (nonatomic, strong) UIColor *stockGreenColor;

@end

@implementation YXStockDetailBTDealView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame market:(NSString *)market isLandScape:(BOOL)isLandScape {
    if (self = [super initWithFrame:frame]) {
        self.market = market;
        self.isLandScape = isLandScape;
        [self initUI];
    }
    return self;
}

- (void)initUI{

    _allowedScrollToBottom = YES;
    self.timeFlag = 0;

    self.redImage = [YXStockDetailTool changeDirectionImage: 1];
    self.greenImage = [YXStockDetailTool changeDirectionImage: -1];
    
    self.greyColor = [QMUITheme stockGrayColor];
    self.stockRedColor = [QMUITheme stockRedColor];
    self.stockGreenColor = [QMUITheme stockGreenColor];

    
    [self addGestureRecognizer:self.tapGesture];

    UILabel *titleLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stock_detail_tricker"] textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize: 20 weight: UIFontWeightMedium]];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.height.mas_equalTo(24);
        make.top.equalTo(self).offset(20);
    }];

    [self addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(36);
        make.top.equalTo(titleLabel.mas_bottom).offset(16);
    }];

    [self addSubview:self.dealTableView];
    [self.dealTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.headerView.mas_bottom);
        make.height.mas_equalTo(320);
    }];

    YXRefreshNormalHeader *header =  [YXRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.dealTableView.mj_header = header;
    header.stateLabel.font = [UIFont systemFontOfSize:10];
    header.arrowView.alpha = 0.0;
    header.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    // 为了让scorllview初始数据很少也可以下拉刷新, 做个1像素偏移
    if (!self.isLandScape) {
        if (self.dealTableView.contentOffset.y == 0) {
            [self.dealTableView setContentOffset:CGPointMake(0, 1) animated:NO];
        }
    }
}

- (void)loadMoreData {

    if (self.loadMoreCallBack && !self.isRefresh) {
        self.isRefresh = YES;
        self.loadMoreCallBack(@"0", @"0");
    }
}

- (void)reloadWithMoreLoad:(BOOL)noMoreData {
    if (self.dealTableView.mj_header.isRefreshing) {
        [self.dealTableView.mj_header endRefreshing];
    }
    self.isRefresh = NO;
}


#pragma mark - delegate & datasource --- 目前无接口, 测试数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tickModel.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    YXStockDealDeatailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellReuseIdentifier_stockDealDeatail"];
    if (!cell) {
        cell = [[YXStockDealDeatailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellReuseIdentifier_stockDealDeatail" isBTDeal:YES];
    }
    if (indexPath.row < self.tickModel.list.count) {
        uint32_t priceBase = self.tickModel.priceBase.value > 0 ? self.tickModel.priceBase.value : self.priceBase;
        cell.decimalCount = self.decimalCount;
        YXTick *tickDetailModel = self.tickModel.list[indexPath.row];
        [cell reloadDataWithModel:tickDetailModel pclose:self.pclose priceBase:priceBase isCryptos:YES];
        
        //买入 - 红, 卖出 - 绿 , 不涨不跌 - 灰
       switch (tickDetailModel.direction.value) {
           case YXTickDirectionDefault:
               cell.numLabel.textColor = self.greyColor;
               cell.iconView.image = nil;
               cell.animationView.backgroundColor = [self.greyColor colorWithAlphaComponent:0.2];
               break;
           case YXTickDirectionSell:
               cell.numLabel.textColor = self.stockGreenColor;
               cell.iconView.image = self.greenImage;
               cell.animationView.backgroundColor = [self.stockGreenColor colorWithAlphaComponent:0.2];
               break;
           case YXTickDirectionBuy:
               cell.numLabel.textColor = self.stockRedColor;
               cell.iconView.image = self.redImage;
               cell.animationView.backgroundColor = [self.stockRedColor colorWithAlphaComponent:0.2];
               break;
           default:
               break;
       }
    }
    if (!self.isLandScape) {
        if (indexPath.row == self.tickModel.list.count - 1) {
            cell.isLastRow = YES;
        } else {
            cell.isLastRow = NO;
        }
    }
    return cell;

}

#pragma mark - lazy load
- (UITableView *)dealTableView{
    if (!_dealTableView) {
        _dealTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _dealTableView.backgroundColor = [UIColor clearColor];
        //[_dealTableView registerClass:[YXStockDealDeatailCell class] forCellReuseIdentifier:@"cellReuseIdentifier_stockDealDeatail"];
        _dealTableView.dataSource = self;
        _dealTableView.delegate = self;
        _dealTableView.rowHeight = 32;
        _dealTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _dealTableView;
}

- (YXStockDetailBTDealHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[YXStockDetailBTDealHeaderView alloc] init];
    }
    return _headerView;
}
- (UITapGestureRecognizer *)tapGesture {

    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureEvent)];
    }
    return _tapGesture;

}

#pragma mark - setModel

- (void)setPclose:(double)pclose {
    if (_pclose != pclose) {
        _pclose = pclose;
        [_dealTableView reloadData];
    }
}

- (void)tapGestureEvent {
    if (self.tickClickCallBack) {
        self.tickClickCallBack();
    }
}


/**
 接收HTTP返回的数据，但是加载更多数据时不在此处处理
 在首次进入个股详情页面或发生轮询时，在此处理

 @param tickModel 需要展示的tick Data
 */
- (void)setTickModel:(YXTickData *)tickModel {
    _tickModel = tickModel;
    [_dealTableView reloadData];

    if ([_dealTableView isDragging] || [_dealTableView isTracking] || [_dealTableView isDecelerating]) {

    } else {
        if (_tickModel.list != nil && (_allowedScrollToBottom || self.isRefresh)) {
            if ([_tickModel.list count] > 0) {
                if (self.isRefresh) {
                    [self setUpTimer];
                } else {

                    [_dealTableView qmui_scrollToBottom];
                }
            }
        }
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
    if (bottomOffset <= height) {
        // 已经到达底部
        _allowedScrollToBottom = YES;
    } else {
        // 不在底部
        _allowedScrollToBottom = NO;
    }

    // 如果当前不允许滚动到底部，过3秒后恢复到允许滚动到底部
    if (!_allowedScrollToBottom && self.timeFlag == 0) {
        [self setUpTimer];
    }


    // 为了让scorllview不在顶部边界, 可以下拉刷新
    if (!self.isLandScape) {
        if (contentOffsetY == 0) {
            [scrollView setContentOffset:CGPointMake(0, 1) animated:NO];
        }
    }
}

- (void)setUpTimer {

    [self invalidateTimer];
    @weakify(self)
    self.timeFlag = [YXTimerSingleton.shareInstance transactOperation:^(YXTimerFlag flag) {
        @strongify(self)
        [self refreshScrollState];
    } timeInterval:3 repeatTimes:1 atOnce:NO];
}

- (void)refreshScrollState {
    _allowedScrollToBottom = YES;
    [self invalidateTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 如果开始拖拽了，则取消定时器触发
    [self invalidateTimer];
}


- (void)invalidateTimer {
    [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.timeFlag];
    self.timeFlag = 0;
}

- (void)dealloc {
    [self invalidateTimer];
}

@end
