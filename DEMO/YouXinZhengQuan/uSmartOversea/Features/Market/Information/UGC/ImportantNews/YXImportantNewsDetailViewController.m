//
//  YXImportantNewsViewController.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXImportantNewsDetailViewController.h"
#import "uSmartOversea-Swift.h"
#import <IGListKit/IGListKit.h>
#import "YXImportantNewsDetailViewModel.h"
#import "YXNewsDetailMoreBtn.h"
#import <DTCoreText/DTCoreText.h>
#import "NSDictionary+Category.h"


@interface YXImportantNewsDetailViewController ()<IGListAdapterDataSource>

@property (nonatomic, strong) YXImportantNewsDetailViewModel *viewModel;
@property (nonatomic, strong) IGListAdapter *adapter;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) YXNewsDetailMoreBtn *moreBtn;

@property (nonatomic, assign) BOOL bigSize;

@property (nonatomic, assign) BOOL isCN;
@property (nonatomic, strong) NSString *enTitle;
@property (nonatomic, strong) NSString *enContent;


@property (nonatomic, strong) YXCommentDetailToolView *toolView;

@property (nonatomic, strong) NSMutableDictionary *shareDic;
@property (nonatomic, strong) YXUGCShareConfigModel *shareConfigModel;

@property (nonatomic, strong) NSString * postType;
@end

@implementation YXImportantNewsDetailViewController
@dynamic viewModel;

- (__kindof UIScrollView *)scrollView {
    return self.collectionView;
}

- (CGFloat)bottomHeight {
    return self.toolView.mj_h;
}

- (BOOL)alwaysShowNavBarPublisher {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [YXSensorAnalyticsTrack trackTimerStartWithEvent:YXSensorAnalyticsEventViewScreen];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postType = [NSString stringWithFormat:@"%ld",(long)YXInformationFlowTypeNews];
    self.bigSize = NO;
    self.isCN = YES;
    
    [self initUI];
    [self loadData];
    
    
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:YXUserManager.notiFollowAuthorSuccess object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
//        [YXSensorAnalyticsTrack trackWithEvent:YXSensorAnalyticsEventViewClick properties:@{
//            YXSensorAnalyticsPropsConstants.propViewPage: @"资讯详情页",
//            YXSensorAnalyticsPropsConstants.propViewName: @"点击关注",
//            YXSensorAnalyticsPropsConstants.propId: self.viewModel.newsId?:@"",
//            YXSensorAnalyticsPropsConstants.propTitle: self.viewModel.newsModel.title?:@"",
//        }];
    }];
}


- (void)initUI {

    [self.contentView addSubview:self.toolView];
    
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
    
}


//- (void)setNavMoreButton {
//
//    UIBarButtonItem *item = [UIBarButtonItem qmui_itemWithImage:[UIImage imageNamed:@"icon_ugc_more"] target:self action:@selector(moreBtnClick)];
//    self.navigationItem.rightBarButtonItems = @[item];
//}

- (void)setNavMoreButton {
    
    NSArray *arr = @[@(YXNewsDetailMoreTypeShare), @(YXNewsDetailMoreTypeFont)];
//    BOOL isHasTranslate = NO;
//    if ([self.viewModel.newsModel.language isEqualToString:@"en"]) {
//        isHasTranslate = YES;
//    }
//    if (isHasTranslate) {
//        arr = @[@(YXNewsDetailMoreTypeCollection), @(YXNewsDetailMoreTypeShare), @(YXNewsDetailMoreTypeFont), @(YXNewsDetailMoreTypeTranslate)];
//    }
    
    self.moreBtn = [[YXNewsDetailMoreBtn alloc] initWithFrame:CGRectMake(0, 0, 44, 44) andTypeArr:arr andNewsId:self.viewModel.newsId andType:YXNewsDetailTypeNews];
    
    @weakify(self);
    [self.moreBtn setSubItemCallBack:^(YXNewsDetailMoreType type) {
        @strongify(self);
        if (type == YXNewsDetailMoreTypeFont) {
            self.bigSize = !self.bigSize;
            // 刷新
            [self reloadLanguageOrFont];
        } else if (type == YXNewsDetailMoreTypeTranslate) {
            if (self.isCN) {
                // 翻译
                YXArticleDetailTranslateRequestModel *requestModel = [[YXArticleDetailTranslateRequestModel alloc] init];
                requestModel.newsid = self.viewModel.newsId;
                YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
                [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                    if (responseModel.code == YXResponseCodeSuccess) {
                        self.isCN = NO;
                        self.enTitle = [responseModel.data yx_stringValueForKey:@"title"];
                        self.enContent = [responseModel.data yx_stringValueForKey:@"content"];
                        
                        [self reloadLanguageOrFont];
                    }
                } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                                
                }];
            } else {
                self.isCN = YES;
                [self reloadLanguageOrFont];
            }
            
        } else if (type == YXNewsDetailMoreTypeShare) {
            if (![YXUserManager isLogin]) {
                [YXToolUtility handleBusinessWithLogin:^{
//                        [self sharePostHandle];
                }];
            } else {
                [self sharePostHandle];
            }
        }
    }];
    UIBarButtonItem *item = [UIBarButtonItem qmui_itemWithButton:self.moreBtn target:nil action:nil];
        self.navigationItem.rightBarButtonItems = @[item];
}


//- (void)moreBtnClick {
//
//    [YXUGCShareTool showShareWith:self.shareConfigModel shareDic:self.shareDic];
//    @weakify(self);
//    [[YXUGCShareTool shareInstance] setClickCallBack:^(enum YXUGCShareActionType actionType, YXUGCShareConfigModel * _Nullable configModel) {
//        @strongify(self);
//        if (actionType == YXUGCShareActionTypeFont) {
//            self.bigSize = !self.bigSize;
//            configModel.isBig = self.bigSize;
//            [self reloadLanguageOrFont];
//        } else if (actionType == YXUGCShareActionTypeTranslate) {
//            if (self.isCN) {
//                // 翻译
//                YXArticleDetailTranslateRequestModel *requestModel = [[YXArticleDetailTranslateRequestModel alloc] init];
//                requestModel.newsid = self.viewModel.newsId;
//                YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
//                [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
//                    if (responseModel.code == YXResponseCodeSuccess) {
//                        self.isCN = NO;
//                        self.shareConfigModel.isCn = NO;
//                        self.enTitle = [responseModel.data yx_stringValueForKey:@"title"];
//                        self.enContent = [responseModel.data yx_stringValueForKey:@"content"];
//
//                        [self reloadLanguageOrFont];
//                    }
//                } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//
//                }];
//            } else {
//                self.isCN = YES;
//                self.shareConfigModel.isCn = YES;
//                [self reloadLanguageOrFont];
//            }
//        }
//    }];
//}

- (void)bindViewModel {
    
}

- (void)loadData {
    

    @weakify(self);
    [[self.viewModel.loadDetailCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
                
        if ([self.viewModel.newsModel.language isEqualToString:@"en"]) {
            self.shareConfigModel.isHasTranslate = YES;
        } else {
            self.shareConfigModel.isHasTranslate = NO;
        }
        
        [self.toolView updateLikeCountWithLikeCount:self.viewModel.newsModel.like_count likeFlag:self.viewModel.newsModel.like_flag];
        
        [self setNavMoreButton];
        [self.collectionView.mj_header endRefreshing];

        [self loadCommentListData:NO];
//        [self loadZipData];
        
        
        YXListNewsUserModel *newsUserModel = self.viewModel.newsModel.user;
        NSString *releaseTime = @"";
        if (newsUserModel.uuid.length > 0) {
            YXCreateUserModel *realModel = [[YXCreateUserModel alloc] init];
            realModel.auth_user = newsUserModel.authUser;
            realModel.avatar = newsUserModel.avatar;
            realModel.nickName = newsUserModel.nickname;
            realModel.pro = newsUserModel.userRoleType;
            realModel.uid = newsUserModel.uuid;
            realModel.auth_info = newsUserModel.authExplain;
            
            YXNewsDetailUserModel *userModel = [[YXNewsDetailUserModel alloc] init];
            userModel.userModel = realModel;
            userModel.descText = [YXToolUtility dateStringWithTimeIntervalSince1970:self.viewModel.newsModel.date];
            
//            self.viewModel.topContentArr[YXImportantNewsTypeUser] = userModel;
            
            self.navBarPublisherView.userModel = realModel;
            self.navBarPublisherView.descLabel.text = userModel.descText;
            
            NSString *strDate = [[NSDate dateWithTimeIntervalSince1970:self.viewModel.newsModel.date] stringWithFormat:@"yyyy-MM-dd HH-mm-ss"];
            releaseTime =  [YXToolUtility compareCurrentTime:strDate];
        } else {
//            releaseTime = [YXToolUtility dateStringWithTimeIntervalSince1970:self.viewModel.newsModel.date];
            
            NSString *strDate = [[NSDate dateWithTimeIntervalSince1970:self.viewModel.newsModel.date] stringWithFormat:@"yyyy-MM-dd HH-mm-ss"];
            releaseTime =  [YXToolUtility compareCurrentTime:strDate];

            
            
        }
        NSString *source = self.viewModel.newsModel.source;
        // 来源和时间
        self.viewModel.topContentArr[YXImportantNewsTypePublishTime] = [NSString stringWithFormat:@"%@ %@", source, releaseTime];
        
        // 标题
        if (self.viewModel.newsModel.title.length > 0) {
            YXNewsTitleModel *titleModel = [[YXNewsTitleModel alloc] initWithContent:self.viewModel.newsModel.title fontSize:self.bigSize ? 28 : 24];
            self.viewModel.topContentArr[YXImportantNewsTypeTitle] = titleModel;
        }

        NSMutableArray *tagList = [NSMutableArray array];
        // 标签
        for (YXListNewsJumpTagModel *model in self.viewModel.newsModel.jump_tags) {
            if (model.jump_type > 0) {
                // 可跳转的
                [tagList addObject:model];
            }
        }

        if (tagList.count > 0) {
            YXNewsDetailTagModel *model = [[YXNewsDetailTagModel alloc] init];
            model.tagList = tagList;
            self.viewModel.topContentArr[YXImportantNewsTypeTag] = model;
        }

        // 股票列表
        NSMutableArray *stockList = [NSMutableArray array];


        for (int i = 0; i < self.viewModel.newsModel.related_stocks.count; ++i) {
            if (i > 3) {
                break;;
            }
            YXListNewsStockModel *model = self.viewModel.newsModel.related_stocks[i];
            if (model.code.length > 2) {
                NSString *sybmol = [model.code substringFromIndex:2];
                NSString *market = [model.code substringToIndex:2];
                Secu *secu = [[Secu alloc] initWithMarket:market symbol:sybmol];
                [stockList addObject:secu];
            }
        }



        if (stockList.count > 0) {
            [YXQuoteManager.sharedInstance onceRtSimpleQuoteWithSecus:stockList level:QuoteLevelUser handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
                YXNewsDetailStockListModel *model = [[YXNewsDetailStockListModel alloc] init];
                model.list = list;
                self.viewModel.topContentArr[YXImportantNewsTypeStock] = model;
                
                [self soreDataSource];
                [self.adapter performUpdatesAnimated:YES completion:nil];
            } failed:^{

            }];
        }

        // 内容
        if (self.viewModel.newsModel.content.length > 0) {
            YXNewsRichTextModel *model = [[YXNewsRichTextModel alloc] initWithContent:self.viewModel.newsModel.content fontSize:self.bigSize ? 22 : 18 isArticle:NO];
            self.viewModel.topContentArr[YXImportantNewsTypeContent] = model;
        }
                
        [self soreDataSource];
        [self.adapter performUpdatesAnimated:YES completion:nil];
        
//        [YXSensorAnalyticsTrack trackWithEvent:YXSensorAnalyticsEventViewClick properties:@{
//            YXSensorAnalyticsPropsConstants.propViewPage: @"资讯详情页",
//            YXSensorAnalyticsPropsConstants.propViewName: @"进入资讯详情页",
//            YXSensorAnalyticsPropsConstants.propId: self.viewModel.newsId?:@"",
//            YXSensorAnalyticsPropsConstants.propTitle: self.viewModel.newsModel.title?:@"",
//        }];
    }];
    
    

}


#pragma mark - 评论

-(void)loadCommentListData:(BOOL) isLoadMore {
    if (isLoadMore == NO) {
        self.viewModel.commentListOffset = 0;
    }

    @weakify(self);
    [[self.viewModel.getCommentList execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        
        self.viewModel.commentTitleModel.title = [NSString stringWithFormat:@"%@(%ld)",[YXLanguageUtility kLangWithKey:@"stock_detail_discuss"],self.viewModel.commentListModel.total];
        if ([self.viewModel.commentTotalDatas containsObject:self.viewModel.commentTitleModel] == NO) {
            [self.viewModel.commentTotalDatas addObject:self.viewModel.commentTitleModel];
        }

        if (self.viewModel.commentListModel.list.count > 0) {
            //有数据时移除无数据模型
            if ([self.viewModel.commentTotalDatas containsObject:self.viewModel.commentNodataModel]) {
                [self.viewModel.commentTotalDatas removeObject:self.viewModel.commentNodataModel];
            }
            if (isLoadMore == NO) {
                //先移除掉原来的
                NSMutableArray * tempDataSource = [NSMutableArray arrayWithArray:self.viewModel.commentListArr];
                [tempDataSource enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[YXCommentDetailCommentModel class]]) {
                        [self.viewModel.commentTotalDatas removeObject:obj];
                    }
                }];
                [self.viewModel.commentListArr removeAllObjects];
                self.viewModel.commentListOffset = self.viewModel.commentListModel.list.count;
            }else{
                self.viewModel.commentListOffset = self.viewModel.commentListOffset + self.viewModel.commentListModel.list.count;
            }
       
            [self.viewModel.commentListArr addObjectsFromArray:self.viewModel.commentListModel.list];
            [self.viewModel.commentTotalDatas addObjectsFromArray:self.viewModel.commentListArr];
            NSInteger sumlistCount = self.viewModel.commentListArr.count;
            if (sumlistCount > 0 && self.viewModel.commentListModel.total > sumlistCount) {

                if ([self.viewModel.commentTotalDatas containsObject:self.viewModel.footerTitleModel] == NO) {
                    [self.viewModel.commentTotalDatas addObject:self.viewModel.footerTitleModel];
                }else{
                    [self.viewModel.commentTotalDatas removeObject:self.viewModel.footerTitleModel];
                    [self.viewModel.commentTotalDatas addObject:self.viewModel.footerTitleModel];
                }
            }else{
                if ([self.viewModel.commentTotalDatas containsObject:self.viewModel.footerTitleModel] == YES) {
                    [self.viewModel.commentTotalDatas removeObject:self.viewModel.footerTitleModel];
                }
            }
        }else{
            if (isLoadMore == NO) {
                self.viewModel.commentNodataModel.post_id = self.viewModel.newsModel.newsId;
                self.viewModel.commentNodataModel.post_type = [NSString stringWithFormat:@"%ld",YXInformationFlowTypeNews];
                if ([self.viewModel.commentTotalDatas containsObject:self.viewModel.commentNodataModel] == NO) {
                    [self.viewModel.commentTotalDatas addObject:self.viewModel.commentNodataModel];
                    if ([self.viewModel.commentTotalDatas containsObject:self.viewModel.footerTitleModel] == YES) {
                        [self.viewModel.commentTotalDatas removeObject:self.viewModel.footerTitleModel];
                    }
                }
            }
        }
        
        [self soreDataSource];
        
        [self.adapter performUpdatesAnimated:YES completion:nil];
        
    }];
}

- (void)loadZipData {
    
    [[self.viewModel.loadBannerAndRecommendCommand execute:nil] subscribeNext:^(RACTuple * _Nullable x) {
        YXBannerActivityModel *topBanner = x.second;
        YXBannerActivityModel *bottomBanner = x.third;
        if (topBanner.bannerList.count > 0) {
            self.viewModel.topContentArr[YXImportantNewsTypeTopBanner] = topBanner;
        }
        if (bottomBanner.bannerList.count > 0) {
            self.viewModel.topContentArr[YXImportantNewsTypeBottomBanner] = bottomBanner;
        }
        [self soreDataSource];
        [self.adapter performUpdatesAnimated:YES completion:nil];
    }];
}

- (void)configShareDic {
    [self showLoading:@""];

    NSString *shortUrl = [self.shareDic objectForKey:@"shortUrl"];
    if (shortUrl.length > 0) {
        [self hideHud];
        [self initShareBottomView:shortUrl];
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    self.shareDic = dic;
    
    if (self.viewModel.newsModel) {
        [dic setValue:self.viewModel.newsModel.title?:@"" forKey:@"title"];
                
        NSString *inviteCode = @"";
        if ([YXUserManager isLogin]) {
            inviteCode = [[YXUserManager shared] inviteCode];
        }
        NSString *pageUrl = [YXH5Urls importantNewsDetailUrlWithNewsId:self.viewModel.newsId inviteCode:inviteCode];
        
        [dic setValue:pageUrl forKey:@"pageUrl"];
        
        NSData *data = [self.viewModel.newsModel.content dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *att = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:nil];
        NSString *str = att.string;
        if (str.length > 80) {
            str = [str substringToIndex:80];
        }
        [dic setValue:str?:@"" forKey:@"description"];
        
        [dic setValue:@(YXSharePlatformWXMiniProgram) forKey:@"subPlatform"];
//        [dic setValue:[YXH5Urls wxMiniProgramPath:self.viewModel.newsId content:YXInformationFlowTypeNews] forKey:@"wxPath"];
        
        // 获取短链
        NSString *longUrl = pageUrl;
        YXShortUrlRequestModel *requestModel = [[YXShortUrlRequestModel alloc] init];
        requestModel.long_ = longUrl;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            [self hideHud];
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                NSString *url = [responseModel.data yx_stringValueForKey:@"url"];
                if (url && [url isNotEmpty]) {
                    [dic setValue:[NSString stringWithFormat:@"%@/%@", [YXUrlRouterConstant staticResourceBaseUrlForShare], url] forKey:@"shortUrl"];
                    
                    [self initShareBottomView:[dic objectForKey:@"shortUrl"]];

                }
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            
//            [self initShareBottomView:longUrl];
        }];
    } else {
        [self hideHud];
    }
}

- (void)reloadLanguageOrFont {
    
    NSString *title;
    NSString *content;
    
    if (self.isCN) {
        title = self.viewModel.newsModel.title;
        content = self.viewModel.newsModel.content;
    } else {
        title = self.enTitle;
        content = self.enContent;
    }
    
    // 刷新
    if (content.length > 0) {
        YXNewsRichTextModel *model = [[YXNewsRichTextModel alloc] initWithContent:content fontSize:self.bigSize ? 22 : 18 isArticle:NO];
        self.viewModel.topContentArr[YXImportantNewsTypeContent] = model;
    }
    
    if (title.length > 0) {
        YXNewsTitleModel *titleModel = [[YXNewsTitleModel alloc] initWithContent:title fontSize:self.bigSize ? 28 : 24];
        self.viewModel.topContentArr[YXImportantNewsTypeTitle] = titleModel;
    }
    
    [self soreDataSource];
    [self.adapter performUpdatesAnimated:YES completion:nil];
    
}



-(void)refreshSingleComment:(NSString * )commentId {
    if (commentId.length == 0) {
        return;
    }
    @weakify(self)
    [YXUGCCommentManager querySingleCommentDataWithComment_id:commentId limit:5 offset:0 completion:^(YXSingleCommentModel * _Nullable model) {
        @strongify(self)
        if (model) {
            //这里相当于增加
            YXCommentDetailCommentModel * newModel = model.comment;
            [YXSquareCommentManager transformCommentDetailCommentListLayoutWithModel:newModel];

            YXNewsOrLiveCommentListModel * newListMode = [[YXNewsOrLiveCommentListModel alloc] init];
            NSMutableArray * listArr = [NSMutableArray array];
            [listArr addObject:newModel];
            if (self.viewModel.commentListModel) {
                newListMode.total = self.viewModel.commentListModel.total + 1;
             
                if (self.viewModel.commentListModel.list.count > 0) {
                    [listArr addObjectsFromArray:self.viewModel.commentListModel.list];
                }
            }else{
                newListMode.total =  1;
            }
            newListMode.list = listArr;
         
            self.viewModel.commentListModel = newListMode;

            self.viewModel.commentTitleModel.title = [NSString stringWithFormat:@"%@(%ld)", [YXLanguageUtility kLangWithKey:@"stock_detail_discuss"],newListMode.total];
            if ([self.viewModel.commentTotalDatas containsObject:self.viewModel.commentTitleModel] == NO) {
                [self.viewModel.commentTotalDatas addObject:self.viewModel.commentTitleModel];
            }
           
            NSInteger titleIndex = [self.viewModel.commentTotalDatas indexOfObject:self.viewModel.commentTitleModel];
            [self.viewModel.commentTotalDatas insertObject:newModel atIndex:titleIndex + 1];
            [self.viewModel.commentListArr insertObject:newModel atIndex:0];
            
            //有数据时移除无数据模型
            if ([self.viewModel.commentTotalDatas containsObject:self.viewModel.commentNodataModel]) {
                [self.viewModel.commentTotalDatas removeObject:self.viewModel.commentNodataModel];
            }
        
            self.viewModel.commentListOffset = self.viewModel.commentListArr.count;

            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:self.viewModel.topContentArr];
            [self.dataSource addObjectsFromArray:self.viewModel.commentTotalDatas];
            
            [self.adapter performUpdatesAnimated:YES completion:nil];
            [self.adapter reloadObjects:@[self.viewModel.commentTitleModel]];
            
        }
        
    }];
}

//分享帖子
-(void)sharePostHandle {
    [self configShareDic];
}

- (void)initShareBottomView:(NSString *)shareUrl {

    YXShareCommonView *shareView = [[YXShareCommonView alloc] initWithFrame:UIScreen.mainScreen.bounds sharetype:YXShareTypeLink isShowCommunity:false];
    shareView.shareTitle = [self.shareDic objectForKey:@"title"];
    shareView.shareText = [self.shareDic objectForKey:@"description"];
    shareView.shareUrl = shareUrl;
    shareView.shareLongUrl = [self.shareDic objectForKey:@"pageUrl"];
    [shareView showShareView];
}

#pragma mark - ListAdapterMoveDelegate

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {

    return [self.dataSource qmui_filterWithBlock:^BOOL(id  _Nonnull item) {
        return [item conformsToProtocol:@protocol(IGListDiffable)];
    }];
}


- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    @weakify(self);
    if ([object isKindOfClass:[YXNewsRichTextModel class]]) {
        return [[YXNewsRichTextContentVC alloc] init];
    } else if ([object isKindOfClass:[YXNewsDetailStockListModel class]]) {
        return [[YXNewsDetailStockListVC alloc] init];
    } else if ([object isKindOfClass:[YXBannerActivityModel class]]) {
        return [[YXNewsBannerVC alloc] init];
    } else if ([object isKindOfClass:[YXNewsDetailTagModel class]]) {
        return [[YXNewsDetailTagVC alloc] init];
    } else if ([object isKindOfClass:[YXNewsRecommendListModel class]]) {
        return [[YXNewsRecommendListVC alloc] init];
    } else if ([object isKindOfClass:[YXNewsDetailUserModel class]]) {
        return [[YXNewsDetailUserVC alloc] init];
    } else if ([object isKindOfClass:[YXCommentSectionTitleModel class]]) {
        return [[YXUGCCommentTitleSectionController alloc] init];
    } else if ([object isKindOfClass:[NSString class]] && [(NSString *)object length] > 0) {
        return [[YXNewsPublishTimeVC alloc] init];
    } else if ([object isKindOfClass:[YXCommentDetailNoDataModel class]]) {
        YXCommentDetailNoDataSectionController * nodataVC = [[YXCommentDetailNoDataSectionController alloc] init];
        nodataVC.refreshDataBlock = ^{
            @strongify(self);
            [self loadCommentListData:NO];
        };
        return nodataVC;
    } else if ([object isKindOfClass:[YXCommentDetailCommentModel class]]){
        YXCommentDetailIGViewController * detailVC = [[YXCommentDetailIGViewController alloc] init];
        
        detailVC.postType = self.postType;
        detailVC.postId = self.viewModel.newsModel.newsId;
        detailVC.refreshDataBlock = ^(id _Nullable model, CommentRefreshDataType type) {
            @strongify(self);
            if (type == CommentRefreshDataTypeDeleteData) { //直接删除
               
                [self.dataSource removeObject:object];
               self.viewModel.commentListModel.total = self.viewModel.commentListModel.total - 1;
                self.viewModel.commentTitleModel.title = [NSString stringWithFormat:@"%@(%ld)",[YXLanguageUtility kLangWithKey:@"stock_detail_discuss"],self.viewModel.commentListModel.total];
                NSInteger comentIndex = [self.viewModel.commentListArr indexOfObject:object];
                [self.viewModel.commentListArr removeObject:object];
                [self.viewModel.commentTotalDatas removeObject:object];
                
                 if (self.viewModel.commentListArr.count == 0) {
                     [self loadCommentListData:NO];
                 }else{
                     NSMutableArray * loadArr = [NSMutableArray array];
            
                     [loadArr addObject:self.viewModel.commentTitleModel];
             
                     [self.adapter performUpdatesAnimated:NO completion:nil];
                     [self.adapter reloadObjects:loadArr];
                 }
               
            }else if(type == CommentRefreshDataTypeRefreshDataReplace) { //替换数据
                if (model) {
                    NSInteger index = [self.dataSource indexOfObject:object];

                    NSInteger comentIndex = [self.viewModel.commentListArr indexOfObject:object];
                    if (comentIndex < self.viewModel.commentListArr.count) {
                        [self.viewModel.commentListArr replaceObjectAtIndex:comentIndex withObject:model];
                    }
                    
                    NSInteger comentTotalIndex = [self.viewModel.commentTotalDatas indexOfObject:object];
                    if (comentTotalIndex < self.viewModel.commentTotalDatas.count) {
                        [self.viewModel.commentTotalDatas replaceObjectAtIndex:comentTotalIndex withObject:model];
                    }
                    [self.dataSource replaceObjectAtIndex:index withObject:model];
                    [self.adapter performUpdatesAnimated:YES completion:nil];
                    [self.adapter reloadObjects:@[model]];
                }
            }
        };
        
        return detailVC;
    }else if ([object isKindOfClass:[YXCommentSectionFooterTitleModel class]]) {
        YXCommentDetailFooterController * footeVC = [[YXCommentDetailFooterController alloc] init];
        [footeVC setShowMoreCommentBlock:^{
            @strongify(self)
            [self loadCommentListData:YES];
        }];
        return footeVC;
    }
    
    return [[YXNewsTitleVC alloc] init];
}


- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    
    return nil;
}


-(NSInteger )commentListCountInDataSource {
    __block NSInteger sum = 0;
    [self.viewModel.commentListArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([ obj isKindOfClass:[YXCommentDetailCommentModel class]]) {
            sum = sum + 1;
        }
    }];
    
    return sum;
}


- (void)soreDataSource {
    NSMutableArray *arrM = [NSMutableArray array];
    
    [arrM addObjectsFromArray:self.viewModel.topContentArr];
    [arrM addObjectsFromArray:self.viewModel.commentTotalDatas];
    if (self.viewModel.recommendModel) {
        [arrM addObject:self.viewModel.recommendModel];
    }
    self.dataSource = [NSMutableArray arrayWithArray:arrM];
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
//        _adapter.performanceDelegate = self;
    }
    return _adapter;
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}


-(YXCommentDetailToolView *)toolView {
    if (!_toolView) {
        _toolView = [[YXCommentDetailToolView alloc] initWithFrame:CGRectMake(0, YXConstant.screenHeight - YXConstant.navBarHeight - 54 - YXConstant.safeAreaInsetsBottomHeight, YXConstant.screenWidth, 54 + YXConstant.safeAreaInsetsBottomHeight)];
       
        @weakify(self)
        _toolView.toolActionBlock = ^( CommentButtonType type) {
            @strongify(self)
  
            if (YXUserManager.isLogin == NO) {
                [YXToolUtility handleBusinessWithLogin:^{
              
                }];
                return;
            }
            if (type == CommentButtonTypeComment) {
                NSString * post_id = self.viewModel.newsModel.newsId;
                NSDictionary * paraDic = @{
                    @"post_id":post_id.length > 0 ? post_id : @"",
                    @"post_type":self.postType
                                           
                };
                YXCommentViewModel *viewModel = [[YXCommentViewModel alloc] initWithServices:self.viewModel.services params:paraDic];
                viewModel.isReply = NO;
                @weakify(self);
                [viewModel setSuccessBlock:^(NSString *  commentId) {
                    @strongify(self);
                    if (post_id.length == 0) {
                        return;
                    }
                    [self refreshSingleComment:commentId];

                }];
                
                YXCommentViewController *viewController = [[YXCommentViewController alloc] initWithViewModel:viewModel];
                
                [YXToolUtility alertNoFullScreen:viewController];

            }else if (type == CommentButtonTypeLike) {
                NSInteger opration = (self.viewModel.newsModel.like_flag) ? 0 : 1;
                @weakify(self)
                
                [YXUGCCommentManager queryLikeWithDirection:opration bizId:self.viewModel.newsId bizPreFix:YXLikeBizPreFixPost postType:YXInformationFlowTypeNews completion:^(BOOL isSuc, int64_t count) {
                    if (isSuc) {
                        self.viewModel.newsModel.like_flag = !self.viewModel.newsModel.like_flag;
                        self.viewModel.newsModel.like_count = count;
                        [self.toolView updateLikeCountWithLikeCount:count likeFlag:self.viewModel.newsModel.like_flag];
                    }
                }];

                
            }else if(type == CommentButtonTypeShare){
                [self sharePostHandle];

            }
        };
    }
    
    return _toolView;
}


- (YXUGCShareConfigModel *)shareConfigModel {
    if (_shareConfigModel == nil) {
        _shareConfigModel = [[YXUGCShareConfigModel alloc] init];
        _shareConfigModel.isHasFavorite = true;
        _shareConfigModel.isHasFont = true;
        _shareConfigModel.isBig = false;
        _shareConfigModel.cid = self.viewModel.newsId;
    }
    return _shareConfigModel;
}

@end
