
#import <UIKit/UIKit.h>

#import "MJRefresh.h"


/** 进入刷新状态的回调 */
typedef void (^STLRefreshingBlock)(void);
/** 下拉显示Banner Block */
typedef void (^PullingBannerBlock)(void);
/** 正在执行下拉操作*/
typedef void(^PullingDownBlock)(void);

typedef enum : NSUInteger {
    RequestNormalStatus,    //0 正常状态
    RequestEmptyDataStatus, //1 空数据状态
    RequestFailStatus,      //2 请求失败状态
    RequesNoNetWorkStatus,  //3 网络连接失败状态
} STLBlankPageViewStatus;


@interface UIScrollView (STLBlankPageView)

/**
 * 以下所有的属性需要配合 <showRequestTip:> 方法使用
 */

/** 空数据标题 */
@property (nonatomic, copy) NSString *emptyDataTitle;
/** 空数据副标题 */
@property (nonatomic, copy) NSString *emptyDataSubTitle;
/** 空数据图片 */
@property (nonatomic, strong) UIImage *emptyDataImage;
/** 空数据按钮标题 */
@property (nonatomic, copy) NSString *emptyDataBtnTitle;


/** 请求失败文字 */
@property (nonatomic, copy) NSString *requestFailTitle;
/** 请求失败图片 */
@property (nonatomic, strong) UIImage *requestFailImage;
/** 请求失败按钮 */
@property (nonatomic, copy) NSString *requestFailBtnTitle;


/** 网络连接失败文字 */
@property (nonatomic, copy) NSString *networkErrorTitle;
/** 网络连接失败图片 */
@property (nonatomic, strong) UIImage *networkErrorImage;
/** 网络连接失败按钮 */
@property (nonatomic, copy) NSString *networkErrorBtnTitle;

/** 自定义按钮点击的事件 */
@property (nonatomic, copy) void (^blankPageViewActionBlcok)(STLBlankPageViewStatus status);

/**
 * 一个属性即可自动设置显示请求提示view,(但是在请求失败时只能显示无数据提示)
 * 此方法一定要放在请求数据回来时的reloadData之前设置此属性效果才正常
 */
//@property (nonatomic, assign) BOOL automaticShowTipView;//目前Adorawe项目中没有使用该属性,暂时关闭

/** 外部可控制整体View的中心位置 */
@property(nonatomic) CGPoint   blankPageViewCenter;

/** 外部可控制内容提示tipView的中心上移距离 */
@property(nonatomic, assign) CGFloat   blankPageTipViewOffsetY;

/** 外部可控制内容提示图片的距离顶部距离 优先级高*/
@property (nonatomic, assign) CGFloat blankPageImageViewTopDistance;

/** 外部可控制内容提示tipView的距离顶部距离 优先级高*/
@property (nonatomic, assign) CGFloat blankPageTipViewTopDistance;

@property (nonatomic, assign) BOOL    isIgnoreHeaderOrFooter;

/**
 * 显示全屏下拉banner
 */
@property (nonatomic, assign) BOOL showDropBanner;

#pragma mark -- 给表格添加上下拉刷新事件

/**
 社区页面初始化表格的上下拉刷新控件
 
 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上拉刷新需要调用的函数
 @param startRefreshing 是否需要立即刷新
 */
- (void)addCommunityHeaderRefreshBlock:(STLRefreshingBlock)headerBlock
                    footerRefreshBlock:(STLRefreshingBlock)footerBlock
                       startRefreshing:(BOOL)startRefreshing;

/**
 初始化表格的上下拉刷新控件
 
 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上拉刷新需要调用的函数
 @param startRefreshing 是否需要立即刷新
 */
- (void)addHeaderRefreshBlock:(STLRefreshingBlock)headerBlock
           footerRefreshBlock:(STLRefreshingBlock)footerBlock
              startRefreshing:(BOOL)startRefreshing;

/**
 * <此方法与上方法作用相同>
 */
- (void)addCommunityHeaderRefreshBlock:(STLRefreshingBlock)headerBlock
                PullingShowBannerBlock:(PullingBannerBlock)pullingBannerBlock
                    footerRefreshBlock:(STLRefreshingBlock)footerBlock
                       startRefreshing:(BOOL)startRefreshing;

/**
 社区页面初始化表格的上下拉刷新控件
 
 @param headerBlock 下拉刷新需要调用的函数
 @param pullingDownBlock 正在下拉调用的函数
 @param footerBlock 上拉刷新需要调用的函数
 @param startRefreshing 是否需要立即刷新
 */
- (void)addCommunityHeaderRefreshBlock:(STLRefreshingBlock)headerBlock
                PullingShowBannerBlock:(PullingBannerBlock)pullingBannerBlock
               refreshDropPullingBlock:(PullingDownBlock)pullingDownBlock
                    footerRefreshBlock:(STLRefreshingBlock)footerBlock
                       startRefreshing:(BOOL)startRefreshing;

/**
 * 开始加载头部数据
 
 @param animation 加载时是否需要动画
 */
- (void)headerRefreshingByAnimation:(BOOL)animation;


#pragma mark -- 处理表格上下拉刷新,分页,添加空白页事件

/**
 此方法作用: 调用后会自动收起表格上下拉刷新控件, 判断分页逻辑, 添加数据空白页等操作
 调用条件：  必须要在UITableView/UICollectionView 实例的reloadData方法执行后调用才能生效
 
 @param totalPageCurrentPageCountDict 页面上表格分页数据 "pageCount"数 与 "curPage"数 包装的字典
 
 1. 页面请求成功样例:
 [self.tableView reloadData];
 NSDictionary *pageDic = @{kTotalPageKey   : @(self.model.pageCount),
                           kCurrentPageKey : @(self.model.curPage)};
 [self.tableView showRequestTip:pageDic];
 
 2. 页面请求失败样例:
 [self.tableView reloadData]; //失败时不调用刷新方法也可以
 [self.tableView showRequestTip:nil];
 
 */
- (void)showRequestTip:(NSDictionary *)totalPageCurrentPageCountDict;


/**
 @param totalPageCurrentPageCountDict
 @param isNeedNetWorkStatus 是否需要判断网络状态显示处理
 */
- (void)showRequestTip:(NSDictionary *)totalPageCurrentPageCountDict isNeedNetWorkStatus:(BOOL)isNeedNetWorkStatus;

/**
 * 处理空白页 <此方法与上方法作用相同>
 */
- (void)doBlankViewWithCurrentPage:(NSNumber *)currentPage totalPage:(NSNumber *)totalPage;

//移除
- (void)removeOldTipBgView;

@end

