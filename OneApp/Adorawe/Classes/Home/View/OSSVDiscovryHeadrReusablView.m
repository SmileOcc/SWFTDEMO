//
//  DiscoveryHeaderReusableView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscovryHeadrReusablView.h"

#import "OSSVHomeDiscoveryModel.h"
#import "OSSVAdvsEventsModel.h"
#import "OSSVAdvsEventsManager.h"

#import "SDCycleScrollView.h"
#import "OSSVDiscoveyTopicsView.h"
#import "OSSVDiscoveyOneAdvsView.h"
#import "OSSVDiscoveyThreeView.h"

#import "OSSVDiscoveyOneModuleView.h"
#import "OSSVDiscoveyTwoModuleView.h"
#import "OSSVDiscoveyThreeModuleView.h"
#import "OSSVDiscoveyFourModuleView.h"
#import "OSSVDiscoveyFiveModuleView.h"

#import "OSSVHomeRecomdJustYouView.h"
#import "OSSVDetailsVC.h"



@interface OSSVDiscovryHeadrReusablView () <SDCycleScrollViewDelegate, DiscoveryTopicViewDelegate, DiscoveryOneBannerViewDelegate,DiscoveryThreeViewDelegate, DiscoveryModuleViewDelegate, STLDiscoverySecondKillBannerViewDelegate>

@property (nonatomic, strong) OSSVHomeDiscoveryModel               *discoveryTempModel;
@property (nonatomic, strong) NSArray                      *moduleArray;

@property (nonatomic, strong) SDCycleScrollView            *bannerScrollerView;
@property (nonatomic, strong) OSSVDiscoveyTopicsView           *topicView;
@property (nonatomic, strong) OSSVDiscoveyOneAdvsView       *oneBannerView;
@property (nonatomic, strong) OSSVDiscoveyThreeView           *threeView;
@property (nonatomic, strong) UIView                       *moduleBackView; // 分馆的背景View
@property (nonatomic, strong) UIView                       *lastTempView;   // 为了设置 临时 Module View 确定

@property (nonatomic, strong) OSSVDiscoveySecondsKillAdvsView *secondKillView;  ///秒杀视图
@property (nonatomic, strong) OSSVDiscoveySecondsKillAdvsView *discoveryScrollView;      ///<滚动视图

//@property (nonatomic, strong) DiscoveryOneModuleView *oneModuleView;
//@property (nonatomic, strong) DiscoveryTwoModuleView *twoModuleView;
//@property (nonatomic, strong) DiscoveryThreeModuleView *threeModuleView;
//@property (nonatomic, strong) DiscoveryFourModuleView *fourModuleView;
//@property (nonatomic, strong) DiscoveryFiveModuleView *fiveModuleView;

@property (nonatomic, strong) OSSVHomeRecomdJustYouView       *justForYouView;
@property (nonatomic, strong) UIButton                      *genderBtn;

@end

@implementation OSSVDiscovryHeadrReusablView

#pragma mark - Register Init

+ (OSSVDiscovryHeadrReusablView*)goodsDetailsHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString*)kind IndexPath:(NSIndexPath *)indexPath {
    
    [collectionView registerClass:[OSSVDiscovryHeadrReusablView class] forSupplementaryViewOfKind:kind withReuseIdentifier:@"DiscoveryHeaderReusableView"];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"DiscoveryHeaderReusableView" forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //广告
        [self addSubview:self.bannerScrollerView];
        //类似分类
        [self addSubview:self.topicView];
        [self addSubview:self.oneBannerView];
        
        //增加一个倒计时栏目
        [self addSubview:self.secondKillView];
        [self addSubview:self.discoveryScrollView];
        
        [self addSubview:self.threeView];
        [self addSubview:self.moduleBackView];
        [self addSubview:self.justForYouView];

        
        [self.bannerScrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(@0);
            make.height.mas_equalTo(@(kDiscoveryBannerViewHeight));
        }];
        
        [self.topicView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.equalTo(@0);
            make.top.equalTo(self.bannerScrollerView.mas_bottom);
            make.height.mas_equalTo(kDiscoveryTopicRealyHeight);
        }];
        
        [self.oneBannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.equalTo(@0);
            make.top.equalTo(self.topicView.mas_bottom);
            make.height.mas_equalTo(kDiscoveryOneBannerViewHeight);
        }];
        
        //秒杀头65 + 倒计时55 + 商品cell高度
        CGFloat secondKillHeight = [self.secondKillView viewHeight];
        [self.secondKillView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_offset(0);
            make.top.mas_equalTo(self.oneBannerView.mas_bottom);
            make.height.mas_equalTo(secondKillHeight);
        }];
        
        //滚动视图
        CGFloat srcollViewHeight = [self.discoveryScrollView viewHeight];
        [self.discoveryScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_offset(0);
            make.top.mas_equalTo(self.secondKillView.mas_bottom);
            make.height.mas_equalTo(srcollViewHeight);
        }];
 
        [self.threeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.equalTo(@0);
            make.top.equalTo(self.discoveryScrollView.mas_bottom);
            make.height.mas_equalTo(kDiscoveryThreeViewHeight);
        }];
        
        [self.moduleBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.equalTo(@0);
            make.top.equalTo(self.threeView.mas_bottom);
        }];
        
        [self.justForYouView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.lessThanOrEqualTo(self.moduleBackView.mas_bottom).offset(-kDiscoveryViewToOtherSpace);
            make.leading.trailing.equalTo(@0);
            make.bottom.equalTo(self.mas_bottom);
            make.height.mas_equalTo(@0);
        }]; 
        
    }
    return self;
}

#pragma mark - 点击事件 Delegate

#pragma mark ---  点击 Banner 图片回调
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
 
    OSSVAdvsEventsModel *OSSVAdvsEventsModel = self.discoveryTempModel.bannerArray[index];
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:OSSVAdvsEventsModel];
}

#pragma mark ---  点击 Topic 中间 item
- (void)tapTopicViewItemActionAtIndex:(NSInteger)index {
  
    OSSVAdvsEventsModel *OSSVAdvsEventsModel = self.discoveryTempModel.topicArray[index];
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:OSSVAdvsEventsModel];
}

#pragma mark ---  点击 New User
- (void)tapOneBannerViewActionWithModel:(OSSVAdvsEventsModel *)model {
    
    NSLog(@"点击 New User 事件 url === %@, name === %@",model.url, model.name);
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:model];
}

#pragma mark ---  点击 Three  底部 item
- (void)tapThreeViewItemActionAtIndex:(NSInteger)index {
    OSSVAdvsEventsModel *OSSVAdvsEventsModel = self.discoveryTempModel.threeArray[index];
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:OSSVAdvsEventsModel];
}

#pragma mark - sixteen module

///<点击头部视图
-(void)STLDiscoverySecondKillDidClickHeader:(OSSVAdvsEventsModel *)model
{
    [self tapModuleViewActionWithModel:model moduleType:CountDownModuleType position:0];
}

///<点击子视图
-(void)STLDiscoverySecondKillDidChildView:(OSSVHomeGoodsListModel *)model jumpMode:(OSSVAdvsEventsModel *)OSSVAdvsEventsModel type:(SecondKillViewType)type
{
    if (type == SecondKill_Type) {
        [self tapModuleViewActionWithModel:OSSVAdvsEventsModel moduleType:CountDownModuleType position:0];
    }else if (type == Scroll_Type){
        OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
        goodsDetailsVC.goodsId = model.goodsId;
        goodsDetailsVC.wid = model.wid;
        goodsDetailsVC.coverImageUrl = model.goodsImageUrl;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceHome;
        [self.controller.navigationController pushViewController:goodsDetailsVC animated:YES];
    }
}

///<点击viewMore
-(void)STLDiscoverySecondKillDidClickViewMore:(OSSVAdvsEventsModel *)model
{
    [self tapModuleViewActionWithModel:model moduleType:CountDownModuleType position:0];
}

#pragma mark ---  点击 所有的 Module 事件
// 目前所有 Module 分馆 的点击事件都是此处返回
- (void)tapModuleViewActionWithModel:(OSSVAdvsEventsModel *)model moduleType:(ModuleViewType)moduleType position:(NSInteger)position {
    
    NSLog(@"点击  Module 事件 url === %@, name === %@",model.url, model.name);
    // 点击跳转
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:model];
    
}

#pragma mark - Model 赋值, 最核心
- (void)setModel:(OSSVHomeDiscoveryModel *)model {
    
#pragma mark  先赋值给本地TempModel
    self.discoveryTempModel = model;
   
#pragma mark  特别注意 Banner\Topic\NewUser\Three 四个的存在是否判断以及赋值
    //  Banner View 是否存在的情况
    if (self.discoveryTempModel.bannerArray.count > 0) {
        
        self.bannerScrollerView.hidden = NO;
        [self.bannerScrollerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kDiscoveryBannerViewHeight);
        }];
        
        // banner 赋值
        [self setBannerViewData];
    }
    else {
        self.bannerScrollerView.hidden = YES;
        [self.bannerScrollerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    
    //  Topic View 是否存在的情况
    if (self.discoveryTempModel.topicArray.count > 0) {
        self.topicView.hidden = NO;
        [self.topicView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kDiscoveryTopicRealyHeight);
        }];
        // topic 赋值
        [self setTopicViewData];
    }
    else {
        self.topicView.hidden = YES;
        [self.topicView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }

    // 新用户是否存在的情况
    if (self.discoveryTempModel.newuser.count == 1) {
        self.oneBannerView.hidden = NO;
        
        OSSVAdvsEventsModel *model = self.discoveryTempModel.newuser.lastObject; // 永远只有一个
        CGFloat h = kDiscoveryOneBannerViewHeight;
        if ([model.width floatValue] > 0 && [model.height floatValue] > 0) {
            CGFloat scale = [model.width floatValue] / [model.height floatValue];
            h = SCREEN_WIDTH / scale;
        }
        [self.oneBannerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(h);
        }];
        // new User 赋值
        self.oneBannerView.model = model;
    }
    else {
        self.oneBannerView.hidden = YES;
        [self.oneBannerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    
    ///秒杀视图
    if (self.discoveryTempModel.secondArray.count > 0) {
        self.secondKillView.hidden = NO;
        [self.secondKillView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset([self.secondKillView viewHeight]);
        }];
        //增加倒计时
        self.secondKillView.model = self.discoveryTempModel.secondArray[0];
        [self.secondKillView reloadSecond:self.countDown];
    }else{
        self.secondKillView.hidden = YES;
        [self.secondKillView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
        [self.countDown destoryTimer];
    }
    
    ///滑动视图
    if (self.discoveryTempModel.scrollArray.count > 0) {
        self.discoveryScrollView.hidden = NO;
        [self.discoveryScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset([self.discoveryScrollView viewHeight]);
        }];
        self.discoveryScrollView.model = self.discoveryTempModel.scrollArray[0];
    }else{
        self.discoveryScrollView.hidden = YES;
        [self.discoveryScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
    }
  
    // threeView 是否存在的情况
    if (self.discoveryTempModel.threeArray.count == 3) {
        self.threeView.hidden = NO;
        [self.threeView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kDiscoveryThreeViewHeight);
        }];
        // three 赋值
       self.threeView.modelArray = self.discoveryTempModel.threeArray;
    }
    else {
        self.threeView.hidden = YES;
        [self.threeView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    
    //Just for you
    NSDictionary *goodListDic = self.discoveryTempModel.goodsList;
    CGFloat justForYouH = 0;
    if ([goodListDic isKindOfClass:[NSDictionary class]]) {
        NSArray *goodList = goodListDic[@"goodList"];
        if ([goodList isKindOfClass:[NSArray class]]) {
            if (goodList.count) {
                justForYouH = kDiscoveryJustForYouHeight;
            }
        }
    }
    self.justForYouView.hidden = justForYouH == 0 ? YES : NO;
    [self.justForYouView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(justForYouH);
    }];
    
    //   上面Banner\Topic\NewUser\Three  是固定顺序的，下面则是不固定的，所以与此处要专门处理对 Moddle 分馆的状态进行判断，
    /**
     *  说明一下 Module View 的思路
     里面有一分馆，二分馆，三分馆，四分馆，五分馆
     问题点：
            数目不确定性，可能只有一个，或者是五个以上，也可能没有
            还可能重复，可能 一分馆 有多个，而且位置不同
            位置是顺序的，从 1 到 5 的
     暂时处理思路，每一次获取都是清空一下，然后根据返回的数目进行重新排序，后期看是否有更优化的处理
     
     */
    if (self.discoveryTempModel.blocklist.count > 0) {
         self.moduleBackView.hidden = NO;
        [self judgeAndAssignModuleView];
    }
    else {
        // 怕出现ModuleBackView 在刷新的时候，突然没啦的情况，而实际上 subView 还是在的
        for (UIView *subViews in self.moduleBackView.subviews) {
            [subViews removeFromSuperview];
        }
        self.moduleBackView.hidden = YES;
    }
    
//    //如果用户是登录状态下 或
//    //本地存有性别状态 即不显示性别选择按钮
//    if (USERID || (![OSSVNSStringTool isEmptyString:[[NSUserDefaults standardUserDefaults] objectForKey:kGenderKey]])) {
//        self.genderBtn.hidden = YES;
//    }else {
//        self.genderBtn.hidden = NO;
//    }

}

- (void)setBannerViewData {
    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:self.discoveryTempModel.bannerArray.count];
    for (OSSVAdvsEventsModel *model in self.discoveryTempModel.bannerArray) {
        [imageArray addObject:model.imageURL];
    }
    // 网络URL
    self.bannerScrollerView.imageURLStringsGroup = imageArray;
    if (imageArray.count == 1) {
        self.bannerScrollerView.autoScroll = NO;
    }
}

- (void)setTopicViewData {
    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:self.discoveryTempModel.topicArray.count];
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:self.discoveryTempModel.topicArray.count];
    for (OSSVAdvsEventsModel *model in self.discoveryTempModel.topicArray) {
        [imageArray addObject:model.imageURL];
        [titleArray addObject:model.name];
    }
    //    NSArray *titleArray = @[@"The Wheel Of Fortune",@"Invite&Cet Cash",@"Community",@"Categories"];
    //    NSArray *imageArray = @[
    //                            @"http://uidesign.rosegal.com/RG/images/banner/eight/categories@2x.png",
    //                            @"http://uidesign.rosegal.com/RG/images/banner/eight/community@2x.png",
    //                            @"http://uidesign.rosegal.com/RG/images/banner/eight/fortune@2x.png",
    //                            @"http://uidesign.rosegal.com/RG/images/banner/eight/input@2x.png"
    //                            ];
    //            NSArray *imageArray = @[@"home_wheel_icon",@"home_invite_cet_cash_icon",@"home_code_icon",@"home_boutuque_icon",@"home_boutuque_icon"];
    
    [self.topicView makeTopicViewsWithTitleArray:titleArray.copy imageArray:imageArray.copy];
}

#pragma mark - Module View 排序调整

#pragma mark ----  Module View 分馆的排序
- (void)judgeAndAssignModuleView {
    
    // 每次进来都清空一下
    for (UIView *subViews in self.moduleBackView.subviews) {
        [subViews removeFromSuperview];
    }
    // 然后对数据进行处理
    for (NSInteger i = 0; i < self.discoveryTempModel.blocklist.count; i++) {
        if (i == 0) {
            // 第一个永远在最前面
            self.lastTempView = [[UIView alloc] init];
            [self.moduleBackView addSubview:self.lastTempView];
            // 此处写防止 警告冲突
            [self.lastTempView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.leading.top.equalTo(@0);
                make.height.mas_equalTo(0);
            }];
        }
        NSArray *modelArray = [NSArray yy_modelArrayWithClass:[OSSVAdvsEventsModel class] json:self.discoveryTempModel.blocklist[i]];
        if (modelArray.count > 1) { // 至少两个，more + 1
            [self jugdeModelViewWithModelArray:modelArray];
        }
    }
    
//    [self jugdeModelViewWithModelArray:@[@1,@1,@1,@1,@1,@1,@1,@1,@1]];
}

#pragma mark ----  Module View 分馆的创建和赋值
- (void)jugdeModelViewWithModelArray:(NSArray <OSSVAdvsEventsModel *> *)modelArray {
    
   // modelArrayCount + 1 是加上 moreButton
    switch (modelArray.count) {
        case DiscoveryOneModuleType:
        {
            [self makeOneModuleViewWithModelArray:modelArray];
        }
            break;
        case DiscoveryTwoModuleType:
        {
            [self makeTwoModuleViewWithModelArray:modelArray];
        }
            break;
        case DiscoveryThreeModuleType:
        {
            [self makeThreeModuleViewWithModelArray:modelArray];
        }
            break;
        case DiscoveryFourModuleType:
        {
            [self makeFourModuleViewWithModelArray:modelArray];
        }
            break;
        case DiscoveryFiveModuleType:
        {
            [self makeFiveModuleViewWithModelArray:modelArray];
        }
            break;
        case DiscoveryEightModuleType:
        {
            [self makeEightModuleViewWithModelArray:modelArray];
        }
            break;
        case DiscoverySixteenModuleType:
        {
            [self makeSixteenModuleViewWithModelArray:modelArray];
        }
            break;
        default:
            break;
    }
}

#pragma mark ----   五个 Module View 分馆 分别的创建和布局
- (void)makeOneModuleViewWithModelArray:(NSArray <OSSVAdvsEventsModel *> *)modelArray {
    
    OSSVDiscoveyOneModuleView *oneModuleView = [[OSSVDiscoveyOneModuleView alloc] init];
    oneModuleView.delegate = self;
    [self.moduleBackView addSubview:oneModuleView];
    [oneModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastTempView.mas_bottom);
        make.trailing.leading.equalTo(@0);
        make.height.mas_equalTo(kDiscoveryOneModuleHeight);
    }];
    oneModuleView.modelArray = modelArray;
    self.lastTempView = oneModuleView;
}

- (void)makeTwoModuleViewWithModelArray:(NSArray <OSSVAdvsEventsModel *> *)modelArray {
    OSSVDiscoveyTwoModuleView *twoModuleView = [[OSSVDiscoveyTwoModuleView alloc] init];
    twoModuleView.delegate = self;
    [self.moduleBackView addSubview:twoModuleView];
    [twoModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastTempView.mas_bottom);
        make.trailing.leading.equalTo(@0);
        make.height.mas_equalTo(kDiscoveryTwoModuleHeight);
    }];
    
    twoModuleView.modelArray = modelArray;
    self.lastTempView = twoModuleView;
}

- (void)makeThreeModuleViewWithModelArray:(NSArray <OSSVAdvsEventsModel *> *)modelArray {
    OSSVDiscoveyThreeModuleView *threeModuleView = [[OSSVDiscoveyThreeModuleView alloc] init];
    threeModuleView.delegate = self;
    [self.moduleBackView addSubview:threeModuleView];
    [threeModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastTempView.mas_bottom);
        make.trailing.leading.equalTo(@0);
        make.height.mas_equalTo(kDiscoveryThreeModuleHeight);
    }];
    
    threeModuleView.modelArray = modelArray;
    self.lastTempView = threeModuleView;
}

- (void)makeFourModuleViewWithModelArray:(NSArray <OSSVAdvsEventsModel *> *)modelArray {
    OSSVDiscoveyFourModuleView *fourModuleView = [[OSSVDiscoveyFourModuleView alloc] init];
    fourModuleView.delegate = self;
    [self.moduleBackView addSubview:fourModuleView];
    [fourModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastTempView.mas_bottom);
        make.trailing.leading.equalTo(@0);
        make.height.mas_equalTo(kDiscoveryFourModuleHeight);
    }];
    
    fourModuleView.modelArray = modelArray;
    self.lastTempView = fourModuleView;
}

- (void)makeFiveModuleViewWithModelArray:(NSArray <OSSVAdvsEventsModel *> *)modelArray {
    OSSVDiscoveyFiveModuleView *fiveModuleView = [[OSSVDiscoveyFiveModuleView alloc] init];
    fiveModuleView.delegate = self;
    [self.moduleBackView addSubview:fiveModuleView];
    [fiveModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastTempView.mas_bottom);
        make.trailing.leading.equalTo(@0);
        make.height.mas_equalTo(kDiscoveryFiveModuleHeight);
    }];
    
    fiveModuleView.modelArray = modelArray;
    self.lastTempView = fiveModuleView;
}

- (void)makeEightModuleViewWithModelArray:(NSArray *)modelArray
{
    OSSVDiscoveyEightsModuleView *eightModuleView = [[OSSVDiscoveyEightsModuleView alloc] init];
    eightModuleView.delegate = self;
    [self.moduleBackView addSubview:eightModuleView];
    [eightModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lastTempView.mas_bottom);
        make.trailing.leading.mas_offset(0);
        make.height.mas_offset(kDiscoveryEightModuleHeight);
    }];
    
    eightModuleView.modelArray = modelArray;
    self.lastTempView = eightModuleView;
}

- (void)makeSixteenModuleViewWithModelArray:(NSArray *)modelArray
{
    OSSVDiscoveyEightsModuleView *sixteenModuleView = [[OSSVDiscoveyEightsModuleView alloc] init];
    sixteenModuleView.delegate = self;
    [self.moduleBackView addSubview:sixteenModuleView];
    [sixteenModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lastTempView.mas_bottom);
        make.trailing.leading.mas_offset(0);
        make.height.mas_offset(kDiscoverySixteenModuleHeight);
    }];
    sixteenModuleView.modelArray = modelArray;
    self.lastTempView = sixteenModuleView;
}

#pragma mark ----  分馆View内存优化的思考
/**
 *  lastView 此处也是重新创建内存的，为了更合适的呈现
 *
 *  而对比 上面五个分馆，必须是单独创建，可能会出现同时出现 某个分馆的情况，
         例如同时出现五个一分馆，所以此处还是要一一创建为好。
    但是现在 removeFromSuperview，仅仅移除了 View，但是真正的把其 subView 的内存也干掉了吗？
    在 单独创建 时，以五分馆举例：
                fiveModuleView alloc ===> fiveModuleView 引用计数 + 1
                addSubViews          ===> fiveModuleView 引用计数 + 1
                出了make方法           ===> fiveModuleView 引用计数 - 1
                removeFromSuperviews  ===>  fiveModuleView 引用计数 -1   ===> release;
    备注：在MRC中,retainCount 中的数目并不准确，最终确实还是会release的。
    此处是否是真的内存真的没啦 ???? ，但是系统调用 release 是在 dealloc 中执行的，而我们首页中可以说正常情况下一般不会 去执行dealloc。
    
    所以需要优化的点是： 在removeFormSuperviews 后移除的 view 的内存怎样立马干掉它，不等系统自动的delloc ？
    
    但是后来发现，这样移除后的View 其实实际上会在不久被干掉，在当前 runloop 中被干掉，在Dealloc 之前肯定没啦

 */


#pragma mark - LazyLoad

- (SDCycleScrollView *)bannerScrollerView {
    if (!_bannerScrollerView) {
        _bannerScrollerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage imageNamed:@"placeholder_banner_pdf"]];
        _bannerScrollerView.autoScrollTimeInterval = 3.0; // 间隔时间
        _bannerScrollerView.currentPageDotColor = OSSVThemesColors.col_FDF135;
        _bannerScrollerView.pageDotColor = OSSVThemesColors.col_F1F1F1;
        _bannerScrollerView.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    }
    return _bannerScrollerView;
}

- (OSSVDiscoveyTopicsView *)topicView {
    if (!_topicView) {
        _topicView = [[OSSVDiscoveyTopicsView alloc] init];
        _topicView.delegate = self;
        _topicView.backgroundColor = [UIColor whiteColor];
    }
    return _topicView;
}

- (OSSVDiscoveyOneAdvsView *)oneBannerView {
    if (!_oneBannerView) {
        _oneBannerView = [[OSSVDiscoveyOneAdvsView alloc] init];
        _oneBannerView.delegate = self;
    }
    return _oneBannerView;
}

- (OSSVDiscoveyThreeView *)threeView {
    if (!_threeView) {
        _threeView = [[OSSVDiscoveyThreeView alloc] init];
        _threeView.delegate = self;
    }
    return _threeView;
}

- (UIView *)moduleBackView {
    if (!_moduleBackView) {
        _moduleBackView = [[UIView alloc] init];
        _moduleBackView.backgroundColor = [UIColor clearColor];
    }
    return _moduleBackView;
}

- (OSSVHomeRecomdJustYouView *)justForYouView {
    if (!_justForYouView) {
        _justForYouView = [[OSSVHomeRecomdJustYouView alloc] init];
    }
    return _justForYouView;
}

-(OSSVDiscoveySecondsKillAdvsView *)secondKillView
{
    if (!_secondKillView) {
        _secondKillView = [[OSSVDiscoveySecondsKillAdvsView alloc] initWithType:SecondKill_Type];
        _secondKillView.delegate = self;
    }
    return _secondKillView;
}

-(OSSVDiscoveySecondsKillAdvsView *)discoveryScrollView
{
    if (!_discoveryScrollView) {
        _discoveryScrollView = [[OSSVDiscoveySecondsKillAdvsView alloc] initWithType:Scroll_Type];
        _discoveryScrollView.delegate = self;
    }
    return _discoveryScrollView;
}

@end
