//
//  STLFlashSaleContainer.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/3.
//  Copyright © 2020 starlink. All rights reserved.
//
//Controllers
#import "OSSVFlashSaleVC.h"
#import "OSSVDetailsVC.h"

#import "UIViewController+YNPageExtend.h"
//Models
#import "OSSVFlashSaleViewModel.h"
#import "OSSVFlashSaleGoodsModel.h"
#import "MZTimerLabel.h"
//Views
#import "OSSVHomeItemssCell.h"
#import "OSSVFlashSaleCell.h"
#import "OSSVFlashSaleCountdownView.h"
#import "OSSVFlashSaleHeaderView.h"

#import "OSSVFlashSaleListAnalyticsAP.h"

@interface OSSVFlashSaleVC ()<OSSVFlashSaleCellDelegate, MZTimerLabelDelegate,UICollectionViewDelegate,
UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSInteger page;
    NSInteger pageSize;
    BOOL reloading;
    BOOL hasNextPage;
}
@property (nonatomic, strong) NSMutableArray              *dataArray;
@property (nonatomic, strong) OSSVFlashSaleViewModel       *viewModel;
@property (nonatomic, strong) MZTimerLabel                *countdownL;
@property (nonatomic, strong) UIActivityIndicatorView     *actView;//加载菊花
//倒计时显示
@property (nonatomic, strong) OSSVFlashSaleCountdownView   *countDownView;
@property (nonatomic, strong) OSSVFlashSaleCountdownView   *suspensionCountDownView;

@property (nonatomic, strong) UICollectionView            *collectionView;
@property (nonatomic, copy)   NSString                    *timeString;

@property (nonatomic, strong) OSSVFlashSaleListAnalyticsAP *analyticsManager;

@end


@implementation OSSVFlashSaleVC
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        page = 1;
        pageSize = 40;
        reloading = NO;
        hasNextPage = NO;
        self.isFirstAddRefresh = YES;
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.analyticsManager];
    }
    return self;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.bounces = YES;
    if (self.dataArray.count <= 0) {
        [self requestGoodsData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"--%@--%@", [self class], NSStringFromSelector(_cmd));
        if (self.collectionView.mj_footer.isRefreshing) {
        [self.collectionView.mj_footer endRefreshing];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}
/// 重写父类方法 添加 刷新方法
- (void)addTableViewRefresh {
        
    @weakify(self)

    self.collectionView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self addTableViewFooterVeiwReloadMoreData];
    }];
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.collectionView.mj_footer.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    
    /// 需要设置下拉刷新控件UI的偏移位置
//    self.collectionView.mj_header.ignoredScrollViewContentInsetTop = self.yn_pageViewController.config.tempTopHeight;
    STLLog(@"-------kkkkkkkk %f   --- %i  ",self.yn_pageViewController.config.tempTopHeight,self.collectionView.mj_footer.isHidden);

}


- (OSSVFlashSaleCountdownView *)suspensionCountDownView {
    if (!_suspensionCountDownView) {
        _suspensionCountDownView = [[OSSVFlashSaleCountdownView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 34.f)];
        _suspensionCountDownView.backgroundColor = [OSSVThemesColors col_FFFAEA];

        if (self.isArCellTransform && [OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _suspensionCountDownView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _suspensionCountDownView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.analyticsManager.sourecDic = @{kAnalyticsAOPSourceID: STLToString(self.activeId)}.mutableCopy;

//    self.timeString = [NSString stringWithFormat:@"%@ %dh:%dm:%ds", self.labelStr, 0, 0, 0];

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, kIPHONEX_BOTTOM, 0));
    }];
    
    [self.view addSubview:self.actView];
    [self.actView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
    }];
    
    [self setTimer];
}

- (UIActivityIndicatorView *)actView {
    if (!_actView) {
        _actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _actView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }
    return _actView;
}
- (UICollectionView *)querySubScrollView {
    return self.collectionView;
}


//设置计时器
- (void)setTimer {
    _countdownL = [[MZTimerLabel alloc] initWithTimerType:MZTimerLabelTypeTimer];
    _countdownL.delegate = self;
    [_countdownL setCountDownTime:0];
    [_countdownL start];
    double endTime = [self.timeCount doubleValue];
    NSLog(@"返回的剩余秒数：%lf", endTime);
    if (endTime > 0) {
        [_countdownL reset];
        [_countdownL setCountDownTime:endTime];
        [_countdownL start];

    } else {
        [_countdownL reset];
        [_countdownL setCountDownTime:0];
        [_countdownL start];
    }
}

//数据请求
- (void)requestGoodsData {
    @weakify(self)
    [self.actView startAnimating];
    page = 1;
        [self.viewModel requestFlashGoodsWithParmater:STLToString(self.activeId) page:page pageSize:pageSize  completion:^(id result) {
        @strongify(self)
        STLFlashTotalModel *totalModel = (STLFlashTotalModel *)result;
        [self.dataArray removeAllObjects];
        NSInteger totalPage = STLToString(totalModel.pageCount).intValue;
        if (totalPage > 1) {
            hasNextPage = YES;
        }else{
            hasNextPage = NO;
        }
        [self.dataArray addObjectsFromArray:totalModel.goodsList];
        [self.collectionView reloadData];
//        [self.collectionView.mj_header endRefreshing];

        reloading = NO;
            [self suspendTopReloadHeaderViewHeight];
        if (!hasNextPage) {
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.collectionView.mj_footer resetNoMoreData];
        }

       [self.actView stopAnimating];
    } failure:^(id error) {
        @strongify(self)
//        [self.collectionView.mj_header endRefreshing];
        [self suspendTopReloadHeaderViewHeight];

    }];
}

#pragma mark - 悬浮Top刷新高度方法
- (void)suspendTopReloadHeaderViewHeight {
    
    if (!self.collectionView.mj_footer) {
        [self addTableViewRefresh];
    }

//    /// 布局高度
//    __weak typeof (self) weakSelf = self;
//
//    /// 结束刷新时 刷新 HeaderView高度
//    [self.collectionView.mj_header endRefreshingWithCompletionBlock:^{
//        YNPageViewController *VC = weakSelf.yn_pageViewController;
//        if (VC.headerView.frame.size.height != 900) {
//            VC.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.contentHeight);
//            [VC reloadSuspendHeaderViewFrame];
//            [weakSelf addTableViewRefresh];
//        }
//        self.collectionView.bounces = YES;
//        VC.scrollMenuView.userInteractionEnabled = YES;
//    }];
    
    
}


- (void)addTableViewFooterVeiwReloadMoreData {
    /// 这里加 footer 刷新
    @weakify(self)
    [self.viewModel requestFlashGoodsWithParmater:STLToString(self.activeId) page:++page pageSize:pageSize completion:^(id result) {
        @strongify(self)
        STLFlashTotalModel *totalModel = (STLFlashTotalModel *)result;
        NSInteger totalPage = STLToString(totalModel.pageCount).integerValue;
        if (page > totalPage) {
            hasNextPage = NO;
        } else {
            hasNextPage = YES;
        }
        [self.dataArray addObjectsFromArray:totalModel.goodsList];
        [self.collectionView reloadData];

//        [self.collectionView.mj_header endRefreshing];
        reloading = NO;
    
        if (!hasNextPage) {
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.collectionView.mj_footer endRefreshing];
        }
    } failure:^(id error) {
        @strongify(self)
        page--;
        [self.collectionView.mj_footer endRefreshing];
    }];
}


- (OSSVFlashSaleViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVFlashSaleViewModel alloc] init];
    }
    return _viewModel;
}

#pragma mark --加购--弹出加购面板
- (void)selectedIndexButton:(UIButton *)sender {
    
    UICollectionViewCell *cell = sender.viewCollectionViewCell;
    NSIndexPath *path = [self.collectionView indexPathForCell:cell];
    OSSVFlashSaleGoodsModel *goodModel = self.dataArray[path.row];
    
    NSDictionary *itemDic = @{@"item_id" : STLToString(goodModel.goods_sn),
                              @"item_name" : STLToString(goodModel.goodsTitle),
                              @"item_brand" : @"",
                              @"item_category" : STLToString(goodModel.cat_name),
                              @"price" : STLToString(goodModel.activePrice),
                              @"quantity" : @(1)
                              
    };
    NSString *pageName = [UIViewController currentTopViewControllerPageName];

    [OSSVAnalyticsTool analyticsGAEventWithName:@"add_to_cart" parameters:@{@"screen_group" : [NSString stringWithFormat:@"ActivityList_%@", STLToString(pageName)],
                                                                       @"position"     : @"ActivityList_Recommended",
                                                                       @"currency"     : @"USD",
                                                                       @"value"        : STLToString(goodModel.activePrice),
                                                                       @"items"        : @[itemDic]
    }];
    
    if (self.showCartBlock) {
        self.showCartBlock(goodModel,path.row);
    }
}

#pragma mark - MZTimerLabelDelegate
-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime {
    NSUInteger timeint = (int)countTime;
    if (timeint == [self.timeCount intValue]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self.activiteRefreshBlock) {
                self.activiteRefreshBlock(YES);
            }
        });
    }
}

-(void)timerLabel:(MZTimerLabel*)timerLabel countingTo:(NSTimeInterval)time timertype:(MZTimerLabelType)timerType {

    NSInteger second = (int)time  % 60;
    NSInteger minute = ((int)time / 60) % 60;
    NSInteger hours = ((int)time / 3600) % 24;
    NSInteger  days  = ((int)time / 3600)/24 ;
    if (second < 0) {
        second = 0;
    }
    if (minute < 0) {
        minute = 0;
    }
    if (hours < 0) {
        hours = 0;
    }
    if (days < 1) {
        days = 0;
    }
    
    [self.suspensionCountDownView updateTimeWithDay:days hour:hours minute:minute second:second endString:STLToString(self.labelStr)];

    [self.countDownView updateTimeWithDay:days hour:hours minute:minute second:second endString:STLToString(self.labelStr)];
    
}



- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [OSSVThemesColors col_FFFAEA];
        [_collectionView registerClass:[OSSVFlashSaleCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVFlashSaleCell.class)];

        [_collectionView registerClass:[OSSVFlashSaleHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(OSSVFlashSaleHeaderView.class)];
    }
    return _collectionView;
}


#pragma mark - UICollectionViewDelegate
//指定单元格的个数 ，这个是一个组里面有多少单元格，e.g : 一个单元格就是一张图片
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

//构建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVFlashSaleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVFlashSaleCell.class) forIndexPath:indexPath];
    OSSVFlashSaleGoodsModel *goodModel = self.dataArray[indexPath.item];
    cell.model =goodModel;
    cell.delegate = self;
    [cell.productImgView yy_setImageWithURL:[NSURL URLWithString:STLToString(goodModel.goodsImgUrl)]
                                placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                    options:kNilOptions
                                 completion:nil];
    
    
    cell.titleLabel.text = STLToString(goodModel.goodsTitle);
    cell.priceLabel.text = STLToString(goodModel.active_price_converted);
    if (STLIsEmptyString(goodModel.lineMarketPrice.string)) {
        NSString *oldPrice = STLToString(goodModel.market_price_converted);
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:oldPrice];
        
        [attStr addAttributes:@{NSForegroundColorAttributeName:OSSVThemesColors.col_999999,
                                NSFontAttributeName:[UIFont boldSystemFontOfSize:11],
                                NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],
                                NSBaselineOffsetAttributeName:@(NSUnderlineStyleSingle)
        } range:NSMakeRange(0, oldPrice.length)];
        goodModel.lineMarketPrice = attStr;
    }
    
    cell.oldPirceLabel.attributedText = goodModel.lineMarketPrice;
    if (STLToString(goodModel.discount).intValue > 0) {
        [cell.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(goodModel.discount)];
        
        cell.activityStateView.hidden = NO;
    }else {
        cell.activityStateView.hidden = YES;
    }
    
    //销售数量
    NSInteger soldCount = STLToString(goodModel.soldNum).intValue;
    //活动库存量
    NSInteger activeStockCount = STLToString(goodModel.activeStock).intValue;
    CGFloat progress = (CGFloat )soldCount / activeStockCount;
    /////卖光了，强制处理
    if (STLToString(goodModel.soldOut).boolValue) {
        progress = 1.0;
    }
    cell.progressView.progress = progress;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        cell.progressLabel.text = [NSString stringWithFormat:@"%@ %@",STLLocalizedString_(@"sold", nil),STLToString(goodModel.soldNum)];
        
    } else {
        cell.progressLabel.text = [NSString stringWithFormat:@"%@ %@",STLToString(goodModel.soldNum),STLLocalizedString_(@"sold", nil)];
    }
    //售完的阴影
    BOOL isSoldOut = STLToString(goodModel.soldOut).boolValue;
    cell.soldOutBgView.hidden = !isSoldOut;
    cell.soldOutImageView.hidden = !isSoldOut;
    cell.soldOutLabel.hidden = !isSoldOut;
    cell.productDetailLabel.hidden = !isSoldOut;
    cell.addButton.hidden    = isSoldOut;
    
    if (self.isArCellTransform && [OSSVSystemsConfigsUtils isRightToLeftShow]) {
        cell.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OSSVFlashSaleCell *flashSaleCell = (OSSVFlashSaleCell *)cell;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [flashSaleCell.progressView startProgressAnimation];
    });
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        OSSVFlashSaleHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(OSSVFlashSaleHeaderView.class) forIndexPath:indexPath];
        headerView.backgroundColor = [OSSVThemesColors col_FFFAEA];
        OSSVFlashSaleCountdownView *dowView = [[OSSVFlashSaleCountdownView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 34)];
        if (self.isArCellTransform && [OSSVSystemsConfigsUtils isRightToLeftShow]) {
            dowView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
//        if (!STLIsEmptyString(self.timeString)) {
//            self.suspensionCountDownView.timeLabel.text = self.timeString;
//        }
//        dowView = self.suspensionCountDownView;
        self.countDownView = dowView;
        self.countDownView.hidden = YES;
        if (self.dataArray.count > 0) {
            self.countDownView.hidden = NO;
        }
        [headerView addSubview:self.countDownView];
        return headerView;
    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = OSSVThemesColors.col_F1F1F1;
    headerView.hidden = YES;
    
    return headerView;
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OSSVFlashSaleGoodsModel *goodModel = self.dataArray[indexPath.row];

    OSSVDetailsVC *goodDetail = [[OSSVDetailsVC alloc] init];
    goodDetail.goodsId = goodModel.goodId;
    goodDetail.wid     = goodModel.wid;
    goodDetail.sourceType = STLAppsflyerGoodsSourceFlashList;
    goodDetail.coverImageUrl = STLToString(goodModel.goodsImgUrl);
    
    NSDictionary *dic = @{kAnalyticsAction          :[OSSVAnalyticsTool sensorsSourceStringWithType:STLAppsflyerGoodsSourceFlashList sourceID:@""],
                          kAnalyticsUrl             :STLToString(self.activeId),
                          kAnalyticsKeyWord         :@"",
                          kAnalyticsPositionNumber  :@(indexPath.row+1),
                          
                          
    };
    [goodDetail.transmitMutDic addEntriesFromDictionary:dic];
    
    [self.navigationController pushViewController:goodDetail animated:YES];
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (APP_TYPE == 3) {
        return CGSizeMake(SCREEN_WIDTH, 114*kScale_375);
    } else {
        return CGSizeMake(SCREEN_WIDTH, 144*kScale_375);
    }
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(0, 12, 0, 12);
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section {
    
    if (self.dataArray.count > 0) {
        return 34;
    }
    return 0.001;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if(section == 0 && self.dataArray.count > 0){
        return CGSizeMake(0, 34);
    }
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0001;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0001;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    YNPageViewController *VC = self.yn_pageViewController;
//    VC.pageScrollView.contentSize = CGSizeMake(375, 603);
    
    CGFloat scrollerOffsetY = scrollView.contentOffset.y;
    STLLog(@"----------   %f",scrollerOffsetY);
    
    if (self.suspensionCountDownView) {
        CGFloat y = scrollerOffsetY + 44;
        if (y >= 0) {
            y = 0;
            self.suspensionCountDownView.hidden = NO;
            if (self.suspensionCountDownView.superview != self.view) {
                [self.suspensionCountDownView removeFromSuperview];
                self.suspensionCountDownView.frame = CGRectMake(0, 44, SCREEN_WIDTH, 34);
                [self.view addSubview:self.suspensionCountDownView];
            }
        } else {
            self.suspensionCountDownView.hidden = YES;
        }
    }
    
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    YNPageViewController *VC = self.yn_pageViewController;
//    VC.bgScrollView.scrollEnabled = YES;
}

- (OSSVFlashSaleListAnalyticsAP *)analyticsManager {
    if (!_analyticsManager) {
        _analyticsManager = [[OSSVFlashSaleListAnalyticsAP alloc] init];
        _analyticsManager.source = STLAppsflyerGoodsSourceFlashList;
    }
    return _analyticsManager;
}
@end
