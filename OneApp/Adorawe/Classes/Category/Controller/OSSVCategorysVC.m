//
//  OSSVCategorysVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAdvsEventsManager.h"
#import "OSSVCategroysTablev.h"
#import "OSSVCategoryssViewsModel.h"
#import "OSSVSearchVC.h"
#import "OSSVCategorysModel.h"
#import "OSSVCategroysCollectionView.h"
#import "OSSVCategorysVC.h"
#import "OSSVCategorysListVC.h"
#import "OSSVCategoryCollectionHeadView.h"
#import "OSSVCategoryNavigatiBar.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "OSSVCartVC.h"
#import "OSSVCategoyScrollrViewCCell.h"
#import "OSSVCommonnRequestsManager.h"
#import "OSSVCategoryseAnalyseAP.h"

@interface OSSVCategorysVC ()
<STLCategroyTableviewDelegate,
STLCategroyCollectionViewDelegate,
STLCategoryNavigationBarDelegate
>

@property (nonatomic, strong) OSSVCategoryNavigatiBar      *navigationBar;

@property (nonatomic, strong) OSSVCategroysCollectionView     *collectionView;
@property (nonatomic, strong) UIButton                      *categoriesSearchBtn;
@property (nonatomic, strong) UIScrollView                  *emptyBackView;
@property (nonatomic, strong) OSSVCategoryssViewsModel          *viewModel;
@property (nonatomic, copy) NSString                        *selectedCatId;
@property (nonatomic, strong) OSSVCategroysTablev          *tableView;
@property (nonatomic, strong) UIView                        *collectionViewBgView;
@property (nonatomic, strong) UIView                        *tableViewBgView;
@property (nonatomic, assign) BOOL                          isSelectingTalebing;
@property (nonatomic, strong) NSArray                       *hotWordArray;

@property (nonatomic, strong) OSSVCategoryseAnalyseAP       *categoryAnalyticsManager;

@end

@implementation OSSVCategorysVC

#pragma mark - Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_ChangeGender object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationBar showCartCount];

    if (!self.firstEnter){
        self.firstEnter = YES;
    }
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.categoryAnalyticsManager];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedCatId = @"";//初始化选中的catId
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestData) name:kNotif_ChangeGender object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadOnlineRequest) name:kNotif_OnlineAddressUpdate object:nil];

    self.fd_prefersNavigationBarHidden = YES;
    [self.view addSubview:self.navigationBar];
    
    [self createEmptyViews];
    [self requestData];
    [self requestHotSearchWords];
}

- (NSArray *)hotWordArray {
    if (!_hotWordArray) {
        _hotWordArray = [NSArray array];
    }
    return _hotWordArray;
}
#pragma mark ---请求热搜词， 用于顶部搜索框文案滚动
- (void)requestHotSearchWords {
    
    NSString *groupId = @"category";
    OSSVHotsSearchsWordsAip *api = [[OSSVHotsSearchsWordsAip alloc] initWithGroupId:groupId cateId:@""];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200){
            
            self.hotWordArray = [NSArray yy_modelArrayWithClass:[OSSVHotsSearchWordsModel class] json:requestJSON[kResult]];
            self.navigationBar.searchBarView.hotWordsArray = self.hotWordArray;

        }else{
            
            [HUDManager showHUDWithMessage:requestJSON[@"message"]];
            self.navigationBar.searchBarView.hotWordsArray = @[];
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkNotAvailable", nil)];
        self.navigationBar.searchBarView.hotWordsArray = @[];
    }];
}

#pragma mark - private methods

- (void)reloadOnlineRequest {
    [self requestData];
}


- (void)requestData {
    @weakify(self)
    [self.viewModel requestCategory:@{} completion:^(id obj) {
        @strongify(self)
        if (self.emptyBackView && self.emptyBackView.mj_header.isRefreshing) {
            [self.emptyBackView.mj_header endRefreshing];
        }
        if (self.viewModel.dataArray.count > 0) {
            [self setupView];
            self.emptyBackView.hidden = YES;
//            [self.tableView updateData:self.viewModel.dataArray];
            self.view.backgroundColor = [OSSVThemesColors col_F5F5F5]; //首次进入，改变了父视图的背景色，目的是不显示右侧圆角
            CGSize size = [OSSVCategoryssViewsModel cellRangeItemSize];
            NSMutableArray *allCategoryArrays = [[NSMutableArray alloc] init];
            NSInteger parentIndex = 0;
            NSInteger indexSection = 0;
            CGFloat bottomOffsetY = 0;
            //遍历出总数据
            for (OSSVCategorysModel *cateModel in self.viewModel.dataArray) {
                cateModel.selfCategoryId = [NSString stringWithFormat:@"catID_%i",arc4random() % 123456];
                cateModel.startOffsetY = bottomOffsetY;
                STLLog(@"====== %li ---%f",(long)parentIndex, bottomOffsetY);

                BOOL hasBanner = NO;
                if ((STLJudgeNSArray(cateModel.banner) && cateModel.banner.count > 0) || (STLJudgeNSArray(cateModel.guide) && cateModel.guide.count > 0) ) {
                    hasBanner = YES;
                    cateModel.startSection = indexSection;
                    cateModel.parnetSection = parentIndex;
                    [allCategoryArrays addObject:cateModel];
                    indexSection++;
                    bottomOffsetY += [OSSVCategoyScrollrViewCCell scrollViewContentH:cateModel];

                }
                
                NSArray *tempArray = cateModel.category;
                if (STLJudgeNSArray(tempArray) && tempArray.count > 0) {
                    
                    for (OSSVSecondsCategorysModel *secondModel in tempArray) {
                        
                        if (!hasBanner) {
                            hasBanner = YES;
                            cateModel.startSection = indexSection;
                        }
                        indexSection++;
                        secondModel.parnetSection = parentIndex;
                        secondModel.parentsCategoryName = cateModel.title;
                        secondModel.parentsCategoryID = cateModel.cat_id;
                        NSArray *childArrays = secondModel.child;
                        if (!STLJudgeNSArray(childArrays)) {
                            childArrays = @[];
                        }
                        
                        
                        NSMutableArray *changeArrays = [[NSMutableArray alloc] initWithArray:childArrays];
                        
                        if (APP_TYPE == 3) {
                            
                        } else {
                            
                            OSSVCatagorysChildModel *viewAllModel = [[OSSVCatagorysChildModel alloc] init];
                            viewAllModel.img_addr = STLToString(secondModel.img_addr);
                            viewAllModel.isViewAll = YES;
                            viewAllModel.cat_name = STLLocalizedString_(@"viewAll", nil);
                            viewAllModel.cat_id = STLToString(secondModel.cat_id);
                            //is_op_cat为0的时候，才去添加到第一个位置
                            if (secondModel.is_op_cat.intValue == 0 && childArrays.count > 0) {
                                [changeArrays insertObject:viewAllModel atIndex:0];
                            }
                        }
                        
                        secondModel.child = [[NSArray alloc] initWithArray:changeArrays];
                        
                        secondModel.isAllCorners = NO;
                        if (changeArrays.count <= 0) {
                            secondModel.isAllCorners = YES;
                        }
                        
                        NSInteger las = secondModel.child.count % 3 > 0 ? 1 : 0;
                        NSInteger row = secondModel.child.count / 3 + las;
                        
                        if (APP_TYPE == 3) {
                            las = secondModel.child.count % 2 > 0 ? 1 : 0;
                            row = secondModel.child.count / 2 + las;
                        }
                        
                        //行间隙
                        NSInteger spaceCount = 0;
                        if (row > 0) {
                            spaceCount = row-1;
                        }
                        bottomOffsetY += row * size.height + spaceCount * 8 + 40 + 24;
                        STLLog(@"======temp %li ---%f",(long)parentIndex, bottomOffsetY);

                        [allCategoryArrays addObject:secondModel];
                    }
                    
                }
                parentIndex++;
            }
//            self.collectionView.dataArray = self.viewModel.dataArray;
            self.collectionView.allCategoryArrays = allCategoryArrays;
//            [self.collectionView updateDataAtSelectedIndex:0];
            [self.collectionView reloadData];
            [self.tableView updateData:self.viewModel.dataArray];

//            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.equalTo(@(48 * self.viewModel.dataArray.count));
//            }];


        } else {
            self.emptyBackView.hidden = NO;
            [self.emptyBackView showRequestTip:@{}];
        }
        
    } failure:^(id obj) {
        
        if (self.emptyBackView && self.emptyBackView.mj_header.isRefreshing) {
            [self.emptyBackView.mj_header endRefreshing];
        }
        
        if (STLJudgeEmptyArray(self.viewModel.dataArray)) {
            self.emptyBackView.hidden = NO;
            [self.emptyBackView showRequestTip:nil];
        } else {
            self.emptyBackView.hidden = YES;
        }
    }];
}

- (void)setupView {
    //添加约束，进行自动布局
    __weak typeof(self.view) ws = self.view;
    ws.backgroundColor = [UIColor whiteColor];
 
    [ws addSubview:self.tableViewBgView];
    [self.tableViewBgView addSubview:self.tableView];
    
    [self.tableViewBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navigationBar.mas_bottom).offset(0);
        make.leading.mas_equalTo(ws.mas_leading);
        make.bottom.mas_equalTo(ws.mas_bottom);
        make.width.mas_equalTo([OSSVCategoryssViewsModel listFirstRangeTableWidth]);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.tableViewBgView);
//        make.height.equalTo(0);
//        make.bottom.mas_equalTo(self.tableViewBgView.mas_bottom);
//        make.top.mas_equalTo(self.navigationBar.mas_bottom).offset(0);
//        make.leading.mas_equalTo(ws.mas_leading);
        make.bottom.mas_equalTo(self.tableViewBgView.mas_bottom);
//        make.width.mas_equalTo([OSSVCategoryssViewsModel listFirstRangeTableWidth]);
    }];
    
  
    [ws addSubview:self.collectionViewBgView];
    [self.collectionViewBgView addSubview:self.collectionView];
    
    [self.collectionViewBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navigationBar.mas_bottom).offset(0);
        make.leading.mas_equalTo(self.tableView.mas_trailing);
        make.trailing.mas_equalTo(ws.mas_trailing);
        make.bottom.mas_equalTo(ws.mas_bottom).offset(6);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionViewBgView.mas_top).offset(12);
        make.leading.mas_equalTo(self.collectionViewBgView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.collectionViewBgView.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.collectionViewBgView.mas_bottom).offset(-6);
    }];

}

- (UIView *)tableViewBgView {
    if (!_tableViewBgView) {
        _tableViewBgView = [UIView new];
        _tableViewBgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _tableViewBgView;
}

- (UIView *)collectionViewBgView {
    if (!_collectionViewBgView) {
        _collectionViewBgView = [UIView new];
        _collectionViewBgView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        _collectionViewBgView.layer.cornerRadius = 6;
        _collectionViewBgView.layer.masksToBounds = YES;
        
        if (APP_TYPE == 3) {
            _collectionViewBgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        }
    }
    return _collectionViewBgView;
}

//空白View
- (void)createEmptyViews
{
    [self.view addSubview:self.emptyBackView];
    [self.emptyBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navigationBar.mas_bottom);
    }];
    
    // 这样做是为了增加  菊花的刷新效果
    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        
        [OSSVCommonnRequestsManager refreshAppOnLineDomain];
        [self requestData];
    }];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.emptyBackView.mj_header = header;
    self.emptyBackView.blankPageImageViewTopDistance = 40;
    if (APP_TYPE == 3) {
        self.emptyBackView.emptyDataBtnTitle = STLLocalizedString_(@"retry", nil);
    } else {
        self.emptyBackView.emptyDataBtnTitle = STLLocalizedString_(@"retry", nil).uppercaseString;
    }
    self.emptyBackView.blankPageViewActionBlcok = ^(STLBlankPageViewStatus status) {
        @strongify(self)
        [self.emptyBackView.mj_header beginRefreshing];
    };
}


// 路由式响应链重写
- (void)routerWithEventName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if ([eventName isEqualToString:@"CategoriesSelectedCell"])
    {
        NSInteger selectedIdx = [userInfo[@"selectIdx"] integerValue];
        if (self.viewModel.dataArray.count > 0)
        {
            OSSVCategorysModel *selectCate = self.viewModel.dataArray[selectedIdx];
            self.selectedCatId = selectCate.cat_id;
        }
    }
}



#pragma mark - 导航框文字点击代理
- (void)jumpToSearchWithKey:(NSString *)searchKey {
    OSSVSearchVC * searchVC = [[OSSVSearchVC alloc] init];
    searchVC.searchTitle = searchKey;
    [self.navigationController pushViewController:searchVC animated:NO];

}


#pragma mark ----没有请求到热词的时候 走这个方法
- (void)actionSearch {
    OSSVSearchVC * searchVC = [[OSSVSearchVC alloc] init];
//    searchVC.searchTitle = STLLocalizedString_(@"search", nil);
    [self.navigationController pushViewController:searchVC animated:NO];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":@"Category",
           @"button_name":@"Search_box"}];
}
#pragma mark - 点击购物车按钮
- (void)actionCart {
    OSSVCartVC *cartVC = [[OSSVCartVC alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":@"Category",
           @"button_name":@"Cart"}];
}


#pragma mark - STLCategroyTableviewDelegate

//点击左侧一级分类
-(void)didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableView.dataArray.count > indexPath.row) {
        OSSVCategorysModel *currentModel = self.tableView.dataArray[indexPath.row];
        if (APP_TYPE == 3) {
            if (!STLIsEmptyString(currentModel.link)) {
                [self tapAdvCategory:currentModel second:nil third:nil];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self handViewBackgroundColorIndex:indexPath.row];
                    //    [_collectionView updateDataAtSelectedIndex:indexPath.row];
                    self.isSelectingTalebing = YES;
                    [OSSVAnalyticsTool analyticsGAEventWithName:@"category_navigation" parameters:@{
                                    @"screen_group":@"Category",
                                    @"navigaition":[NSString stringWithFormat:@"Navifirst_%@",STLToString(currentModel.title)]}];
                    
                    [self.collectionView updateSelectCategoryModel:currentModel];
                });
                return;
            }
        }
        
        [self handViewBackgroundColorIndex:indexPath.row];
        //    [_collectionView updateDataAtSelectedIndex:indexPath.row];
        self.isSelectingTalebing = YES;
        [OSSVAnalyticsTool analyticsGAEventWithName:@"category_navigation" parameters:@{
                        @"screen_group":@"Category",
                        @"navigaition":[NSString stringWithFormat:@"Navifirst_%@",STLToString(currentModel.title)]}];
        
        [self.collectionView updateSelectCategoryModel:currentModel];
    }
}

- (void)handViewBackgroundColorIndex:(NSInteger)index {
    
    if (index == 0) {
        self.view.backgroundColor = [OSSVThemesColors col_F5F5F5];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)tapAdvCategory:(OSSVCategorysModel *)categoryModel second:(OSSVSecondsCategorysModel *)secondModel third:(OSSVCatagorysChildModel *)thirdModel {
    
    NSString *link = @"";
    if (categoryModel) {
        link = STLToString(categoryModel.link);
    } else if(secondModel) {
        link = STLToString(secondModel.link);
    } else if(thirdModel) {
        link = STLToString(thirdModel.link);
    }
    
    if (APP_TYPE == 3) {
        if (!STLIsEmptyString(link) && [link hasPrefix:[OSSVLocaslHosstManager appDeeplinkPrefix]]) {
            OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
            NSMutableDictionary *md = [OSSVAdvsEventsManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:link]];
            if ([md[@"actiontype"] integerValue] > 0) {
                advEventModel.actionType = [md[@"actiontype"] integerValue];
                advEventModel.url        = REMOVE_URLENCODING(STLToString(md[@"url"]));
                advEventModel.name       = REMOVE_URLENCODING(STLToString(md[@"name"]));
                advEventModel.webtype       = REMOVE_URLENCODING(STLToString(md[@"webtype"]));
            }
            [OSSVAdvsEventsManager advEventTarget:self withEventModel:advEventModel];
        }
    }
}


#pragma mark - delegate

- (void)categoryCollection:(OSSVCategroysCollectionView *)collectionView category:(OSSVCategorysModel *)categoryModel bannerGuide:(OSSVAdvsEventsModel *)advModel isBanner:(BOOL)isBanner {
    
    if(advModel) {
        OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
        advEventModel.actionType = advModel.actionType;
        advEventModel.url  = advModel.url;
        advEventModel.name = advModel.name;
        [OSSVAdvsEventsManager advEventTarget:self withEventModel:advEventModel];
        
        if (!isBanner) {//不是banner 是guide
            
            ///1.4.4 埋点
            NSString *pageName = [UIViewController currentTopViewControllerPageName];
            NSString *attrNode3 = [NSString stringWithFormat:@"custom_first_categories_%@",STLToString(categoryModel.title)];
            
            NSString *attrNode4 = [NSString stringWithFormat:@"custom_third_categories_%@_%@",STLLocalizedString_(@"featuredProduct", nil).uppercaseString,STLToString(advModel.name)];
            
            NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                              @"attr_node_1":@"home_tab",
                                              @"attr_node_2":@"home_category",
                                              @"attr_node_3":attrNode3,
                                              @"attr_node_4":attrNode4,
            };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
            
            //数据GA埋点曝光 广告点击
                                
                                // item
                                NSMutableDictionary *item = [@{
                            //          kFIRParameterItemID: $itemId,
                            //          kFIRParameterItemName: $itemName,
                            //          kFIRParameterItemCategory: $itemCategory,
                            //          kFIRParameterItemVariant: $itemVariant,
                            //          kFIRParameterItemBrand: $itemBrand,
                            //          kFIRParameterPrice: $price,
                            //          kFIRParameterCurrency: $currency
                                } mutableCopy];


                                // Prepare promotion parameters
                                NSMutableDictionary *promoParams = [@{
                            //          kFIRParameterPromotionID: $promotionId,
                            //          kFIRParameterPromotionName:$promotionName,
                            //          kFIRParameterCreativeName: $creativeName,
                            //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                            //          @"screen_group":@"Home"
                                } mutableCopy];

                                // Add items
                                promoParams[kFIRParameterItems] = @[item];
                                
                            //        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
            
        }
    }
}
- (void)categoryCollection:(OSSVCategroysCollectionView *)collectionView scecondCategory:(OSSVSecondsCategorysModel *)secondModel childModel:(OSSVCatagorysChildModel *)childModel {
    
    if (APP_TYPE == 3) {
        if (childModel) {
            if (!STLIsEmptyString(childModel.link)) {
                [self tapAdvCategory:nil second:nil third:childModel];
                return;
            }
        } else if (secondModel) {
            if (!STLIsEmptyString(secondModel.link)) {
                [self tapAdvCategory:nil second:secondModel third:nil];
                return;
            }
        }
    }
    NSString *analyticCateNameNode4 = @"";
     if(childModel) {
        OSSVCategorysListVC *listView = [[OSSVCategorysListVC alloc]init];
        listView.childId = childModel.cat_id;
        //点击View ALL 传入的标题为 二级分类的标题
        if (childModel.isViewAll) {
            listView.childDetailTitle = STLToString(secondModel.parentsCategoryName);
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"category_navigation" parameters:@{
                            @"screen_group":@"Category",
                            @"navigaition":[NSString stringWithFormat:@"Second_%@_%@",STLToString(secondModel.parentsCategoryName),STLToString(secondModel.cat_name)]}];
            
        } else {
            listView.childDetailTitle = childModel.cat_name;
            [OSSVAnalyticsTool analyticsGAEventWithName:@"category_navigation" parameters:@{
                            @"screen_group":@"Category",
                            @"navigaition":[NSString stringWithFormat:@"Second_%@_%@",STLToString(secondModel.parentsCategoryName),STLToString(secondModel.cat_name)]}];
            
        }
         analyticCateNameNode4 = STLToString(childModel.cat_name);
        [self.navigationController pushViewController:listView animated:YES];
    } else if(secondModel) {
        OSSVCategorysListVC *listView = [[OSSVCategorysListVC alloc]init];
        listView.childId = secondModel.cat_id;
        listView.childDetailTitle = secondModel.cat_name;
        analyticCateNameNode4 = STLLocalizedString_(@"viewAll", nil);
        [self.navigationController pushViewController:listView animated:YES];
        
        [OSSVAnalyticsTool analyticsGAEventWithName:@"category_navigation" parameters:@{
                        @"screen_group":@"Category",
                        @"navigaition":[NSString stringWithFormat:@"Second_%@_%@",STLToString(secondModel.parentsCategoryName),STLToString(secondModel.cat_name)]}];
    }
    
    ///1.4.4 埋点
    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    NSString *attrNode3 = [NSString stringWithFormat:@"custom_first_categories_%@",STLToString(secondModel.parentsCategoryName)];
    
    NSString *attrNode4 = [NSString stringWithFormat:@"custom_third_categories_%@_%@",STLToString(secondModel.cat_name),analyticCateNameNode4];

    NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                      @"attr_node_1":@"home_tab",
                                      @"attr_node_2":@"home_category",
                                      @"attr_node_3":attrNode3,
                                      @"attr_node_4":attrNode4,
    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
    
}

- (void)categoryCollection:(OSSVCategroysCollectionView *)collectionView willShowCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isSelectingTalebing) {
        return;
    }
    
    NSArray *allCategorys = collectionView.allCategoryArrays;
    if (allCategorys.count > indexPath.section) {

        if ([allCategorys[indexPath.section] isKindOfClass:[OSSVCategorysModel class]]) {
            OSSVCategorysModel *channelModel = allCategorys[indexPath.section];
            NSInteger parentSection = channelModel.parnetSection;

            if (self.tableView.selectIndexPath.row != parentSection) {
                [self handViewBackgroundColorIndex:parentSection];
                [self.tableView updateSelectIndex:parentSection];
            }

        } else {
            OSSVSecondsCategorysModel *secodCategoryModel = allCategorys[indexPath.section];
            NSInteger parentSection = secodCategoryModel.parnetSection;

            if (self.tableView.selectIndexPath.row != parentSection) {
                [self handViewBackgroundColorIndex:parentSection];
                [self.tableView updateSelectIndex:parentSection];
            }

        }
    }
}

- (void)categoryCollection:(OSSVCategroysCollectionView *)collectionView scrollEnd:(BOOL)end {
    self.isSelectingTalebing = NO;
}

- (void)categoryCollection:(OSSVCategroysCollectionView *)collectionView beginDragging:(BOOL)dragging {
    self.isSelectingTalebing = NO;
}

#pragma mark - LazyLoad

- (OSSVCategoryssViewsModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVCategoryssViewsModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}


- (OSSVCategoryNavigatiBar *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [[OSSVCategoryNavigatiBar alloc] init];
        [_navigationBar stl_showBottomLine:NO];
        _navigationBar.delegate = self;
        @weakify(self)
        _navigationBar.navBarActionBlock = ^(CategoryNavBarActionType actionType) {
            @strongify(self)
            if (actionType == CategorySearchAction) {
                [self actionSearch];
            } else if(actionType == CategoryNavBarRightCarAction) {
                [self actionCart];
            }
        };
    }
    return _navigationBar;
}

- (OSSVCategroysTablev *)tableView
{
    if (!_tableView)
    {
        _tableView = [[OSSVCategroysTablev alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight =  [OSSVCategroysTablev contnetCellHeight];
        _tableView.backgroundColor = [OSSVThemesColors stlClearColor];
        if (APP_TYPE == 3) {
            _tableView.backgroundColor = [OSSVThemesColors col_F8F8F8];
        }
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.myDelegate = self;
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        [_tableView setTableFooterView:view];
    }
    return _tableView;
}

- (OSSVCategroysCollectionView*)collectionView {
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[OSSVCategroysCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
//        _collectionView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        _collectionView.backgroundColor = [UIColor whiteColor];

        _collectionView.myDelegate = self;
        //隐藏滚动条
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _collectionView.bounces = NO;
    }
    return _collectionView;
}

- (UIScrollView *)emptyBackView {
    if (!_emptyBackView) {
        _emptyBackView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _emptyBackView.hidden = YES;
    }
    return _emptyBackView;
}

- (OSSVCategoryseAnalyseAP *)categoryAnalyticsManager {
    if (!_categoryAnalyticsManager) {
        _categoryAnalyticsManager = [[OSSVCategoryseAnalyseAP alloc] init];
    }
    return _categoryAnalyticsManager;
}

@end
