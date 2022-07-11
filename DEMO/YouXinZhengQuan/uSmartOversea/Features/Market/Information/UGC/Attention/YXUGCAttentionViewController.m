//
//  YXUGCAttentionViewController.m
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXUGCAttentionViewController.h"
#import "YXReportViewModel.h"
#import "YXCommentViewModel.h"
#import "YXCommentViewController.h"
//#import "YXNavigationController.h"

#import "uSmartOversea-Swift.h"
#import <IGListKit/IGListKit.h>
#import "YXUGCAttentionViewModel.h"
#import <Masonry/Masonry.h>

@interface YXUGCAttentionViewController ()<IGListAdapterDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) YXUGCAttentionViewModel *viewModel;

@property (nonatomic, strong) IGListAdapter *adapter;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSString * recommandQueryToken ;  //推荐人用
@property (nonatomic, strong) NSString * feedQueryToken ;

@property (nonatomic, assign) BOOL isFirstData;

@property (nonatomic, strong) YXUGCFeedAttentionPostListModel * attentionModel; //正文的model
@property (nonatomic, strong) YXUGCAttentionCommentListModel * commentModel; //评论的数据

@end

@implementation YXUGCAttentionViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.recommandQueryToken = @"";
    self.feedQueryToken = @"";
    self.isFirstData = YES;
    
    [self initUI];
    
    [self loadData];
    
}

-(void)bindViewModel {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUUIDNotify) name:YXUserManager.notiUpdateUUID object:nil];
}

-(void)initUI {
    
    self.dataSource = [NSMutableArray array];
    [self.view addSubview:self.collectionView];
   
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    // 刷新
    @weakify(self);
    self.collectionView.mj_header = [YXRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        self.recommandQueryToken = @"";
        self.feedQueryToken = @"";
        [self loadData];

        if (self.isUserFeedListPage) {
            //TODO:屏蔽跳转个人中心
//            [[NSNotificationCenter defaultCenter] postNotificationName:YXUserHomePageViewController.ReloadUserHomePageDataNotification
//                                                                object:nil];
        }
    }];
    
    
    
}

-(void)loadData {
    if ([YXUserManager isLogin] == NO && !self.isUserFeedListPage) {
        self.attentionModel = nil;
        self.commentModel = nil;
    }else{
        [self reqAttentionSeedData:NO];
    }
   
}

-(void)reqAttentionData:(BOOL) isLoadMore {
   
    [self reqAttentionSeedData:isLoadMore];
}

//关注信息流
-(void)reqAttentionSeedData:(BOOL) isLoadMore {
    @weakify(self);
    if (self.isFirstData) {
        [YXProgressHUD showLoading:@"" in:self.view];
    }

    void (^completion)(YXUGCFeedAttentionPostListModel * _Nullable) = ^void(YXUGCFeedAttentionPostListModel * _Nullable model) {
        @strongify(self);
        [YXProgressHUD hideHUDForView:self.view animated:YES];

        [self.collectionView.mj_header endRefreshing];
        if (isLoadMore == NO) {
            [self.dataSource removeAllObjects];
        }
        self.attentionModel = model;

        if (model) {
            self.isFirstData = NO;
            self.feedQueryToken = model.query_token;
            if (model.feed_list.count > 0) {
                if (isLoadMore == NO) {
                    [self addRefreshFooter];
                }

                if (self.isUserFeedListPage) { // 用户主页不显示评论
                    [self combineAttentionModel:isLoadMore];
                } else {
                    [self reqCommentListData:isLoadMore]; //请求评论
                }

            }else{
                if (isLoadMore == NO ) { //没数据获取推荐
                    self.commentModel = nil;
                    [self.dataSource removeAllObjects];
                    if (self.isUserFeedListPage) {
                        self.viewModel.noAttensionModel.title = [YXLanguageUtility kLangWithKey:@"no_content"];
                        self.dataSource = [NSMutableArray arrayWithObject:self.viewModel.noAttensionModel];
                        [self.adapter performUpdatesAnimated:YES completion:nil];
                        [self.adapter reloadObjects:@[self.viewModel.noAttensionModel]];
                    } else {
                    }

                }
                if (isLoadMore) {
                    [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                }

            }
        }else{
            if (self.dataSource.count == 0 && isLoadMore == NO ) { //没数据获取推荐
                if (self.isUserFeedListPage) {
                    self.viewModel.noAttensionModel.title = [YXLanguageUtility kLangWithKey:@"no_content"];
                    self.dataSource = [NSMutableArray arrayWithObject:self.viewModel.noAttensionModel];
                    [self.adapter performUpdatesAnimated:YES completion:nil];
                    [self.adapter reloadObjects:@[self.viewModel.noAttensionModel]];
                }
            }
            [self.collectionView.mj_footer endRefreshing];
        }
    };

    if (self.isUserFeedListPage) {
        [YXUGCCommentManager queryPersonFeedListDataWithUserID:self.userID
                                                    queryToken:self.feedQueryToken
                                                          type:self.homePageTabType
                                                    completion:completion];
    } else {
        [YXUGCCommentManager queryAttentionFeedListDataWithPageSize:10 queryToken:self.feedQueryToken completion:completion];
    }
}


//请求评论列表
-(void)reqCommentListData:(BOOL) isLoadMore {
    NSMutableArray * cids = [NSMutableArray array];
    for (int i = 0; i<self.attentionModel.feed_list.count; i++) {
        YXUGCFeedAttentionModel * model = self.attentionModel.feed_list[i];
        if(model.cid.length > 0 ) {
            [cids addObject:model.cid];
        }
    }
    
    if (cids.count > 0) {
        if ([self.dataSource containsObject:self.viewModel.noAttensionModel]) {
            [self.dataSource removeObject:self.viewModel.noAttensionModel];
        }
        
        NSString * jsonString = [cids yy_modelToJSONString];
        @weakify(self);

        [YXUGCCommentManager queryCommentListDataWithPost_ids:jsonString completion:^(YXUGCAttentionCommentListModel * _Nullable model) {
            
            @strongify(self)
            
            if (model) {
                self.commentModel = model;
                [self combineAttentionModel:isLoadMore];
                
                if (self.dataSource.count > 0 && self.attentionModel.feed_list.count > 0 && self.attentionModel.feed_list.count < 10) {
                    [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [self.collectionView.mj_footer resetNoMoreData];
                }
                
            }else{
                [self.collectionView.mj_footer endRefreshing];
            }
          
            if (self.dataSource.count == 0 && isLoadMore == NO) { //没数据获取推荐
                if (self.isUserFeedListPage) {
                    self.viewModel.noAttensionModel.title = [YXLanguageUtility kLangWithKey:@"no_content"];
                    self.dataSource = [NSMutableArray arrayWithObject:self.viewModel.noAttensionModel];
                    [self.adapter performUpdatesAnimated:YES completion:nil];
                    [self.adapter reloadObjects:@[self.viewModel.noAttensionModel]];
                } else {
                }
            }
        }];
    }
    
}

-(void)combineAttentionModel:(BOOL) isLoadMore {
    
    if (isLoadMore == NO) {
        [self.dataSource removeAllObjects];
    }
    
    if (self.attentionModel.feed_list.count > 0) {
        
        for (int i=0; i<self.attentionModel.feed_list.count; i++) {
            
            YXUGCFeedAttentionSumItemModel * itemModel = [[YXUGCFeedAttentionSumItemModel alloc] init];
            
            YXUGCFeedAttentionModel * postModel = self.attentionModel.feed_list[i];
            [YXUGCCommentManager transformAttentionPostLayoutWithModel:postModel];
            itemModel.attentionPostModel = postModel;
            
            for ( YXUGCAttentionCommentListItemModel * model  in self.commentModel.list) {
                if ([model.post_id isEqualToString:postModel.cid]) {
                    
                    for (YXSquareStockPostListCommentModel * commentItem in model.comment_list) {
                        
                        [YXUGCCommentManager transformAttentionCommentLayoutWithModel:commentItem];
                        itemModel.attentionCommentModel =  model;
                    }

                    break;
                }
            }
            [self.dataSource addObject:itemModel];
        }
       
        [self.adapter performUpdatesAnimated:YES completion:nil];
    }
}

-(void)addRefreshFooter {
    @weakify(self)
    YXRefreshAutoNormalFooter *footer = [YXRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self reqAttentionData:YES];
    }];

    self.collectionView.mj_footer = footer;
}

#pragma mark - ListAdapterMoveDelegate

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {

    return [self.dataSource qmui_filterWithBlock:^BOOL(id  _Nonnull item) {
        return [item conformsToProtocol:@protocol(IGListDiffable)];
    }];
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {

    @weakify(self);
    if ([object isKindOfClass:[YXUGCNoAttensionUserModel class]]) { //无关注
        YXUGCNoAttentionSectionController * noAttentionVC = [[YXUGCNoAttentionSectionController alloc] init];
        
        return noAttentionVC;
    }else if([object isKindOfClass:[YXUGCFeedAttentionSumItemModel class]]) {  //关注信息流
        YXUGCAttentionISectionController * attentionVC = [[YXUGCAttentionISectionController alloc] init];
        attentionVC.isUserFeedListPage = self.isUserFeedListPage;

        attentionVC.refreshDataBlock = ^(id _Nullable model,  CommentRefreshDataType type) {
            @strongify(self)
            if (type == CommentRefreshDataTypeRefreshDataOnly) {
                if (model) {
                    YXUGCFeedAttentionSumItemModel * sumModel = object;
                    YXUGCFeedAttentionSumItemModel * newItemModel = [[YXUGCFeedAttentionSumItemModel alloc] init];
                    newItemModel.attentionCommentModel = model;
                    newItemModel.attentionPostModel = sumModel.attentionPostModel;
                  
                    NSInteger index = [self.dataSource indexOfObject:object];
                    [self.dataSource replaceObjectAtIndex:index withObject:newItemModel];
                    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
                        NSLog(@"%d",finished);
                    }];
                
                }
            }
        };
        
        attentionVC.jumpToBlock = ^(NSDictionary<NSString *,NSString *> * paramDic) {
            @strongify(self)

            YXUGCFeedAttentionSumItemModel * sumModel = object;

            NSString * showTime = sumModel.attentionPostModel.show_time;
            NSString * cid = sumModel.attentionPostModel.cid;

            NSDictionary * params = @{
                @"show_time":showTime,
                @"cid":cid,
                @"query_token":self.feedQueryToken
            };

            YXInformationFlowType flowType = sumModel.attentionPostModel.content_type;

            if (flowType == YXInformationFlowTypeCustomUrl) {
                if (sumModel.attentionPostModel.link_url.length > 0) {
                    if (sumModel.attentionPostModel.link_type == 1) {
                     
                        NSDictionary * dic = @{YXWebViewModel.kWebViewModelUrl: sumModel.attentionPostModel.link_url};
                        YXWebViewModel * webUViewModel = [[YXWebViewModel alloc] initWithDictionary:dic];
                        [self.viewModel.services pushPath:YXModulePathsWebView context:webUViewModel animated:YES];
                        
                    }else if (sumModel.attentionPostModel.link_type == 2) {
                        [YXGoToNativeManager.shared gotoNativeViewControllerWithUrlString:sumModel.attentionPostModel.link_url];
                    }
                }
            }else if (flowType == YXInformationFlowTypeChatRoom) {
                NSString *ID = sumModel.attentionPostModel.text_live_info.broadcast_id;
                NSDictionary * dic = @{YXWebViewModel.kWebViewModelUrl: [YXH5Urls chatRoomUrlWithId:ID]};
                YXWebViewModel * webUViewModel = [[YXWebViewModel alloc] initWithDictionary:dic];
                [self.viewModel.services pushPath:YXModulePathsWebView context:webUViewModel animated:YES];
                
            }else {
                [YXUGCCommentManager jumpToSeedVCWithParams:params flowType:flowType];
            }

            // 埋点
            NSString *adName = @"";
            switch (flowType) {
                case YXInformationFlowTypeLive:
                    adName = @"点击直播";
                    break;
                case YXInformationFlowTypeImageText:
                    adName = @"点击文章";
                    break;
                case YXInformationFlowTypeNews:
                    adName = @"点击资讯";
                    break;
                case YXInformationFlowTypeReplay:
                    adName = @"点击回放";
                    break;
                case YXInformationFlowTypeStockdiscuss:
                    adName = @"点击讨论";
                    break;
                case YXInformationFlowTypeCustomUrl:
                    adName = @"点击自定义链接";
                    break;

                default:
                    break;
            }
//            [YXSensorAnalyticsTrack trackWithEvent:YXSensorAnalyticsEventViewClick properties:@{
//                YXSensorAnalyticsPropsConstants.propViewPage: @"盈财经-关注",
//                YXSensorAnalyticsPropsConstants.propViewName: adName,
//                YXSensorAnalyticsPropsConstants.propId: sumModel.attentionPostModel.cid?:@"",
//                YXSensorAnalyticsPropsConstants.propTitle: sumModel.attentionPostModel.title?:@"",
//            }];
        };
        
        return  attentionVC;
        
    }

    return [[YXUGCNoAttentionSectionController alloc] init] ;
}


- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    
    return nil;
}

#pragma mark - Notify
-(void)updateUUIDNotify {
    [self loadData];
}


#pragma mark - lazy load
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout: [[UICollectionViewFlowLayout alloc] init]];
        _collectionView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _collectionView;
}

- (IGListAdapter *)adapter {
    if (_adapter == nil) {
        _adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
        _adapter.scrollViewDelegate = self;
    }
    return _adapter;
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}
@end
