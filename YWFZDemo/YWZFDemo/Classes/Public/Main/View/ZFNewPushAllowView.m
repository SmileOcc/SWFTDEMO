//
//  ZFNewPushAllowView.m
//  ZZZZZ
//
//  Created by YW on 2018/8/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNewPushAllowView.h"
#import "AppDelegate+ZFNotification.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFAppsflyerAnalytics.h"

@class ZFNewPushAllowCellModel;

@protocol ContentViewCellDelegate <NSObject>
@end

@protocol UITableViewCellProtocol <NSObject>

@property (nonatomic, strong) ZFNewPushAllowCellModel *model;
@property (nonatomic, weak) id<ContentViewCellDelegate>delegate;

@end

#pragma mark - ============= cell模型 =============
typedef NS_ENUM(NSInteger) {
    PushAllowButtonType_HasBackground = 1,
    PushAllowButtonType_UnBackground
}PushAllowButtonType;
@interface ZFNewPushAllowCellModel : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, strong) Class tableViewCellClass;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) PushAllowViewType buttonType;

@end

@implementation ZFNewPushAllowCellModel

@end

#pragma mark - ============= 一些cell =============

#pragma mark - ZFNewPushAllowImageCell
@interface ZFNewPushAllowImageCell : UITableViewCell
<
    UITableViewCellProtocol
>
@property (nonatomic, strong) YYAnimatedImageView *cellImageView;
@end

@implementation ZFNewPushAllowImageCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.cellImageView];
        
        [self.cellImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.bottom.mas_equalTo(self);
            make.height.mas_equalTo(self.mas_width).multipliedBy(0.44);
        }];
    }
    return self;
}

-(void)setModel:(ZFNewPushAllowCellModel *)model
{
    _model = model;
    
    _cellImageView.image = [UIImage imageNamed:model.imageName];
}

-(YYAnimatedImageView *)cellImageView
{
    if (!_cellImageView) {
        _cellImageView = ({
            YYAnimatedImageView *image = [[YYAnimatedImageView alloc] init];
            image;
        });
    }
    return _cellImageView;
}

@end

#pragma mark - ============= ZFNewPushAllowTitleCell =============
@interface ZFNewPushAllowTitleCell : UITableViewCell
<
    UITableViewCellProtocol
>
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation ZFNewPushAllowTitleCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(32);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-32);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
    }
    return self;
}

-(void)setModel:(ZFNewPushAllowCellModel *)model
{
    _model = model;
    
    _contentLabel.text = _model.content;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = @"TEST";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            label;
        });
    }
    return _contentLabel;
}

@end

#pragma mark - ============= ZFNewPushAllowImageTitleCell =============
@interface ZFNewPushAllowImageTitleCell : UITableViewCell
<
    UITableViewCellProtocol
>
@property (nonatomic, strong) YYAnimatedImageView *cellImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation ZFNewPushAllowImageTitleCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.cellImageView];
        [self addSubview:self.contentLabel];
        
        [self.cellImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(24);
            make.centerY.mas_equalTo(self.contentLabel.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.cellImageView.mas_trailing).mas_offset(8);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-40);
            make.top.mas_equalTo(self.mas_top).mas_offset(16);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-4);
        }];
    }
    return self;
}

-(void)setModel:(ZFNewPushAllowCellModel *)model
{
    _model = model;
    
    self.cellImageView.image = [UIImage imageNamed:model.imageName];
    self.contentLabel.text = ZFToString(model.content);
}

-(YYAnimatedImageView *)cellImageView
{
    if (!_cellImageView) {
        _cellImageView = ({
            YYAnimatedImageView *image = [[YYAnimatedImageView alloc] init];
            image;
        });
    }
    return _cellImageView;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12];
            label.numberOfLines = 0;
            label;
        });
    }
    return _contentLabel;
}
@end

#pragma mark - ============= ZFNewPushAllowButtonCell =============

@interface ZFNewPushAllowButtonCell : UITableViewCell
<
    UITableViewCellProtocol
>
@property (nonatomic, strong) UIButton *cellButton;
@end

@implementation ZFNewPushAllowButtonCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.cellButton];
        
        [self.cellButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-2);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
//            make.height.mas_equalTo(self.mas_width).multipliedBy(0.15);
            make.height.mas_equalTo(40);
        }];
    }
    return self;
}

-(void)setModel:(ZFNewPushAllowCellModel *)model
{
    _model = model;
    [self.cellButton setTitle:model.content forState:UIControlStateNormal];
    if (_model.buttonType == PushAllowButtonType_HasBackground) {
        self.cellButton.backgroundColor = ZFC0x2D2D2D();
        [self.cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    if (_model.buttonType == PushAllowButtonType_UnBackground) {
        self.cellButton.backgroundColor = [UIColor clearColor];
        [self.cellButton setTitleColor:ZFCOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
    }
    
}

-(UIButton *)cellButton
{
    if (!_cellButton) {
        _cellButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:@"TEST" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor blackColor];
            button.layer.cornerRadius = 3;
            button.layer.masksToBounds = YES;
            button.enabled = NO;
            button;
        });
    }
    return _cellButton;
}

@end



#pragma mark  - ============= 主视图 =============


static  CGFloat padding = 32;

@interface ZFNewPushAllowView ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    ContentViewCellDelegate
>
@property (nonatomic, strong) UIView                                       *maskView;
@property (nonatomic, strong) UIView                                       *contentView;
@property (nonatomic, strong) UITableView                                  *tableView;
@property (nonatomic, strong) NSMutableArray                               *dataList;
@property (nonatomic, copy) void (^operateBlock)(BOOL flag);
@property (nonatomic, assign) PushAllowViewType                            pushAllowViewType;
@end

@implementation ZFNewPushAllowView

- (void)dealloc {
    YWLog(@"------&&&&&&&&&&&&&& ZFNewPushAllowView dealloc");
}
+ (instancetype)shareInstance {
    
    static ZFNewPushAllowView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.maskView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.tableView];
    
    self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    self.maskView.frame = self.bounds;
    
    self.contentView.frame = CGRectMake(padding, 0, KScreenWidth - padding * 2, KScreenHeight);;
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth - padding * 2, KScreenHeight);

}

#pragma mark - datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *datas = self.dataList[section];
    return datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1 || section == 2) {
        return 24;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 10;
    }
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = ZFCOLOR_WHITE;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = ZFCOLOR_WHITE;
    return footerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *datas = self.dataList[indexPath.section];
    ZFNewPushAllowCellModel *cellModel = datas[indexPath.row];
    id<UITableViewCellProtocol>cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellModel.tableViewCellClass)];
    cell.model = cellModel;
    cell.delegate = self;
    return (UITableViewCell *)cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *datas = self.dataList[indexPath.section];
    ZFNewPushAllowCellModel *cellModel = datas[indexPath.row];
    
    if (cellModel.buttonType == PushAllowButtonType_HasBackground) {//打开
        
        // 注册远程推送通知
        BOOL isPopAlert = [GetUserDefault(kHasShowSystemNotificationAlert) boolValue];
        if (isPopAlert) {
            //如果已经弹出过，就直接进入到系统推送页面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            [self operateEvent:YES];
        } else {
            [AppDelegate registerZFRemoteNotification:^(NSInteger openFlag){
                // 需要在这回调，从系统设置再次进入app时，自己获取的状态可能是错的
                [self operateEvent:YES];
                [ZFAnalytics appsFlyerTrackEvent:@"af_subscribe" withValues:@{}];
                // 统计推送点击量
                ZFOperateRemotePushType remoteType = ZFOperateRemotePush_sys_unKonw;
                if (openFlag == 1) {
                    remoteType = ZFOperateRemotePush_sys_yes;
                } else if (openFlag == 0) {
                    remoteType = ZFOperateRemotePush_sys_no;
                }                
                [self analyticsaAlertRemoteType:remoteType];
            }];
            // 统计推送点击量
            [self analyticsaAlertRemoteType:ZFOperateRemotePush_guide_yes];
        }
        
    } else if(cellModel.buttonType == PushAllowButtonType_UnBackground) {//稍后
        [self operateEvent:NO];
        // 统计推送点击量
        [self analyticsaAlertRemoteType:ZFOperateRemotePush_guide_no];
    }
}

- (void)operateEvent:(BOOL)flag {
    // 点击注册推送后立马关掉引导页面
    [self hidden];
    if (self.operateBlock) {
        self.operateBlock(flag);
    }
}

/**
 * appsFlyer统计页面显示打开的权限点击量
 */
- (void)analyticsaAlertRemoteType:(ZFOperateRemotePushType)remoteType {
    NSString *pushEventName = @"";
    if (self.pushAllowViewType == PushAllowViewType_OrderSuccess) {
        pushEventName = @"paysucess";
    } else {
        pushEventName = @"Orderlist";
    }
    [ZFAppsflyerAnalytics analyticsPushEvent:pushEventName
                                   remoteType:remoteType];
}

#pragma mark - public method

-(void)limitShow:(PushAllowViewType)type operateBlock:(void(^)(BOOL flag))operateBlock {

    [ZFPushManager canShowAlertView:^(BOOL canShow) {
        if (canShow) {
            [self noLimitShow:type operateBlock:operateBlock];
        }
    }];
}

-(void)noLimitShow:(PushAllowViewType)type operateBlock:(void(^)(BOOL flag))operateBlock
{
    ///保存显示时间
    [ZFPushManager saveShowAlertTimestamp];

    self.operateBlock = operateBlock;
    [self.dataList removeAllObjects];
    
    NSMutableArray *firstGroups = [[NSMutableArray alloc] init];
    NSMutableArray *secondGroups = [[NSMutableArray alloc] init];
    NSMutableArray *threeGroups = [[NSMutableArray alloc] init];
    [self.dataList addObject:firstGroups];
    [self.dataList addObject:secondGroups];
    [self.dataList addObject:threeGroups];

    NSString *imageName = @"";
    NSString *content = @"";

    self.pushAllowViewType = type;
    // 统计推送显示
    [self analyticsaAlertRemoteType:ZFOperateRemotePush_Default];
    
    if (type == PushAllowViewType_OrderSuccess) {
        imageName = @"account_orderScuuessPushIcon";
        content = ZFLocalizedString(@"Push_Order_Status_Delivery&_Shipping_Information", nil);
    }
    if (type == PushAllowViewType_OrderFail || type == PushAllowViewType_Msg) {
        imageName = @"account_orderFailPushIcon";
        content = ZFLocalizedString(@"Push_yes_notifications_never_miss_out_again", nil);
    }
    
    ZFNewPushAllowCellModel *cellModel = [[ZFNewPushAllowCellModel alloc] init];
    cellModel.tableViewCellClass = [ZFNewPushAllowImageCell class];
    cellModel.imageName = imageName;
    [firstGroups addObject:cellModel];
    
    ZFNewPushAllowCellModel *cellModel1 = [[ZFNewPushAllowCellModel alloc] init];
    cellModel1.content = content;
    cellModel1.tableViewCellClass = [ZFNewPushAllowTitleCell class];
    [secondGroups addObject:cellModel1];
    
    if (type == PushAllowViewType_OrderFail || type == PushAllowViewType_Msg) {
        ZFNewPushAllowCellModel *cellModel2 = [[ZFNewPushAllowCellModel alloc] init];
        cellModel2.imageName = @"account_home_coupon_new";
        cellModel2.content = ZFLocalizedString(@"Push_first_APP_exclusive_sales_offers", nil);
        cellModel2.tableViewCellClass = [ZFNewPushAllowImageTitleCell class];
        [secondGroups addObject:cellModel2];
        
        ZFNewPushAllowCellModel *cellModel3 = [[ZFNewPushAllowCellModel alloc] init];
        cellModel3.imageName = @"account_home_wishlist_new";
        cellModel3.content = ZFLocalizedString(@"Push_New_collections_latest_trends", nil);
        cellModel3.tableViewCellClass = [ZFNewPushAllowImageTitleCell class];
        [secondGroups addObject:cellModel3];
    }
    
    ZFNewPushAllowCellModel *cellModel4 = [[ZFNewPushAllowCellModel alloc] init];
    cellModel4.content = [ZFLocalizedString(@"Push_Open", nil) uppercaseString];
    cellModel4.buttonType = PushAllowButtonType_HasBackground;
    cellModel4.tableViewCellClass = [ZFNewPushAllowButtonCell class];
    [threeGroups addObject:cellModel4];
    
    ZFNewPushAllowCellModel *cellModel5 = [[ZFNewPushAllowCellModel alloc] init];
    cellModel5.content = ZFLocalizedString(@"Push_Later", nil);
    cellModel5.buttonType = PushAllowButtonType_UnBackground;
    cellModel5.tableViewCellClass = [ZFNewPushAllowButtonCell class];
    [threeGroups addObject:cellModel5];
    
    if (![self superview]) {
        [WINDOW addSubview:self];
    }
    if (![self.contentView superview]) {
        [self addSubview:self.contentView];
    }
    
    if (![self.tableView superview]) {
        [self.contentView addSubview:self.tableView];
    }
    //设置全屏来获取总cell,
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth - padding * 2, KScreenHeight);
    self.contentView.frame = CGRectMake(padding, 0, KScreenWidth - padding * 2, KScreenHeight);
    [self.tableView reloadData];
    
    CGFloat totalHeight = 0;
    //方法一
    /**
    NSArray *listCell = [self.tableView visibleCells];
    //需要调用一下 visibleCells， 不然可能indexPathsForVisibleRows取得不准
    NSArray *list = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in list) {
        CGFloat height = [self.tableView rectForRowAtIndexPath:indexPath].size.height;
        totalHeight += height;
    }
     */
    
    //方法二
    NSInteger sections = self.tableView.numberOfSections;
    for (int section = 0; section < sections; section++) {
        NSInteger rows =  [self.tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            CGFloat height = [self.tableView rectForRowAtIndexPath:indexPath].size.height;
            totalHeight += height;
        }
    }
    
    //两个组头 24 和 最后一个尾部 10
    totalHeight += 58;
    
    CGRect oldFrame = self.tableView.frame;
    if (totalHeight > KScreenHeight) {
        totalHeight = 450;
    }
    self.tableView.frame = CGRectMake(0, 0, oldFrame.size.width, totalHeight);
    self.contentView.frame = CGRectMake(padding, oldFrame.origin.y, oldFrame.size.width, totalHeight);
    
    [UIView animateWithDuration:.3 animations:^{
        CGFloat y = (KScreenHeight - totalHeight)/2;
        self.contentView.frame = CGRectMake(padding, y, oldFrame.size.width, totalHeight);
        self.maskView.alpha = 0.5;
    }];
    
}

- (void)hidden
{
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.0;
        self.contentView.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (self.superview) {
            [self removeFromSuperview];
        }
        self.contentView.alpha = 1.0;
    }];
}

-(CGFloat)CalculateHeight:(NSArray<ZFNewPushAllowCellModel *> *)dataList
{
    CGFloat height = 0;
    for (ZFNewPushAllowCellModel *cellModel in dataList) {
        height += cellModel.rowHeight;
    }
//    for (ZFNewPushAllowCellModel *cellModel in dataList) {
//        NSString *classString = NSStringFromClass(cellModel.tableViewCellClass);
//        if ([classString isEqualToString:@"ZFNewPushAllowImageCell"]) {
//            height += self.contentView.frame.size.width * 0.44;
//        }
//        if ([classString isEqualToString:@"ZFNewPushAllowTitleCell"]) {
//            CGFloat padding = 24;
//            CGFloat titleHeight = [cellModel.content textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height;
//            height += (titleHeight + padding*2);
//        }
//        if ([classString isEqualToString:@"ZFNewPushAllowImageTitleCell"]) {
//            CGFloat titleHeight = [cellModel.content textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping].height;
//            height += (titleHeight + 16);
//        }
//    }
    return height;
}

#pragma mark - setter and getter

-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor blackColor];
            view.alpha = 0.0;
            view;
        });
    }
    return _maskView;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.showsVerticalScrollIndicator = NO;
            tableView.showsHorizontalScrollIndicator = NO;
            tableView.estimatedRowHeight = 112;
            tableView.rowHeight = UITableViewAutomaticDimension;
            tableView.separatorStyle = NO;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.bounces = NO;
            
            [tableView registerClass:[ZFNewPushAllowImageCell class] forCellReuseIdentifier:NSStringFromClass([ZFNewPushAllowImageCell class])];
            [tableView registerClass:[ZFNewPushAllowTitleCell class] forCellReuseIdentifier:NSStringFromClass([ZFNewPushAllowTitleCell class])];
            [tableView registerClass:[ZFNewPushAllowImageTitleCell class] forCellReuseIdentifier:NSStringFromClass([ZFNewPushAllowImageTitleCell class])];
            [tableView registerClass:[ZFNewPushAllowButtonCell class] forCellReuseIdentifier:NSStringFromClass([ZFNewPushAllowButtonCell class])];
            
            tableView;
        });
    }
    return _tableView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _contentView;
}

-(NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

@end

