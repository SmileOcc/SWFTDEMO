//
//  OSSVSearchVC.m
// OSSVSearchVC
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSearchVC.h"
#import "OSSVSearchResultVC.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "UICollectionViewRightAlignedLayout.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "OSSVSearchsHistoyViewsModel.h"
#import "OSSVSearchHistoryBtnCell.h"
#import "OSSVHotSearchCCCell.h"
#import "OSSVSearchHistryHeadeView.h"
#import "SearchHistoryManager.h"

#import "OSSVHotSearchsHeadeView.h"
#import "OSSVHotsSearchWordsModel.h"
#import "OSSVSearchAssociateViewModel.h"
#import "OSSVSearchMatchResultView.h"
#import "OSSVSearchKeyWordMatchView.h"

#import "OSSVCategorysListVC.h"
#import "OSSVDetailsVC.h"
#import "Adorawe-Swift.h"

#define PopularString @"Popular Searches"



@interface OSSVSearchVC ()


@property (nonatomic, weak) UICollectionView                    *collectionView;
@property (nonatomic, strong) OSSVSearchMatchResultView          *matchView;
@property (nonatomic, strong) OSSVSearchKeyWordMatchView         *keyWordView;
@property (nonatomic, strong) OSSVSearchsHistoyViewsModel            *viewModel;
@property (nonatomic, strong) OSSVSearchAssociateViewModel       *associateViewModel;
@property (nonatomic, strong) NSMutableArray                    *searchHistorymArray;

@end

@implementation OSSVSearchVC

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.enterName = @"Catetory";
        self.catId = @"";
    }
    return self;
}

- (void)dealloc {
    STLLog(@"=================kkkk: SearchViewController");
    if (_viewModel) {
        [_viewModel freesource];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ///因为searchBar 自带一个点击非点击事件的隐藏键盘的功能，所以把IQ的enable关了  
    [IQKeyboardManager sharedManager].enable = NO;
    
    if (!self.matchView.isHidden && (STLIsEmptyString(self.searchNavbar.searchKey) || ![self.searchNavbar.searchKey isEqualToString:self.matchView.searchKey])) {
        self.matchView.hidden = YES;
        self.matchView.searchKey = @"";
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    
    if (!self.matchView.isHidden && (STLIsEmptyString(self.searchNavbar.searchKey) || ![self.searchNavbar.searchKey isEqualToString:self.matchView.searchKey])) {
        self.matchView.hidden = YES;
        self.matchView.searchKey = @"";
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    
    self.currentPageCode = @"";

    self.searchHistorymArray = [NSMutableArray arrayWithArray:[[SearchHistoryManager singleton] loadLocalSearchHistory]];

    [self initSearchBar];
    [self historySearch];
    [self.searchNavbar becomeEditFirst];
    
    //请求热门搜索数据
    [self requestHotSearchWords];
}


#pragma mark - MakeUI
- (void)initSearchBar {
    [self.view addSubview:self.searchNavbar];
    
    [self.searchNavbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo(kNavHeight);
    }];
}

- (void)historySearch {
    
    UICollectionViewFlowLayout *layout;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        layout = [[UICollectionViewRightAlignedLayout alloc] init];
    } else {
        layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    }
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self.viewModel;
    collectionView.delegate = self.viewModel;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchNavbar.mas_bottom);
    }];
    [self.collectionView registerClass:[OSSVSearchHistoryBtnCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVSearchHistoryBtnCell.class)];
    [self.collectionView registerClass:[OSSVHotSearchCCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVHotSearchCCCell.class)];
    [self.collectionView registerClass:[OSSVHotSearchsHeadeView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(OSSVHotSearchsHeadeView.class)];
    [self.collectionView registerClass:[OSSVSearchHistryHeadeView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(OSSVSearchHistryHeadeView.class)];
    [self.collectionView registerClass:[UICollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:[OSSVSearchsHistoyViewsModel hotSearchFootCellID]];
    [_collectionView registerClass:[UICollectionReusableView class]
    forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
           withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
    [_collectionView registerClass:[UICollectionReusableView class]
    forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
           withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
    _viewModel.collectionView = self.collectionView;
    
    
    [self.view addSubview:self.matchView];
    [self.view addSubview:self.keyWordView];
    
    [self.matchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchNavbar.mas_bottom);
    }];
    
    [self.keyWordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-kIPHONEX_BOTTOM);
        make.top.mas_equalTo(self.searchNavbar.mas_bottom);
    }];

    [self.view sendSubviewToBack:self.searchNavbar];
}

#pragma mark - Request

- (void)requestHotSearchWords {
    
    NSString *groupId = @"";
    if ([self.enterName isEqualToString:@"Catetory"]) {
        groupId = @"category";
    }else if ([self.enterName isEqualToString:@"Home"]){
        groupId = @"index";
    } else {
        groupId = @"category";
    }
    
    OSSVHotsSearchsWordsAip *api = [[OSSVHotsSearchsWordsAip alloc] initWithGroupId:groupId cateId:self.catId];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200){
            
            self.viewModel.hotDataArr = [NSArray yy_modelArrayWithClass:[OSSVHotsSearchWordsModel class] json:requestJSON[kResult]];
            
            [self.collectionView reloadData];
            
        }else{
            
            [HUDManager showHUDWithMessage:requestJSON[@"message"]];
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkNotAvailable", nil)];
    }];
}




#pragma mark - Action
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if (searchBar.text.length == 0) {return;}
    
//    [[SearchHistoryManager singleton] saveSearchHistory:searchBar.text];
//    [searchBar resignFirstResponder];
//    SearchResultViewController * searchResultVC = [[SearchResultViewController alloc]init];
//    searchResultVC.keyword = searchBar.text;
//    searchResultVC.title = searchBar.text;
//    //    searchResultVC.isFromSearchVC = YES;
//    searchResultVC.searchHistoryRefreshBlock = ^{
//        self.searchBar.placeholder = STLLocalizedString_(@"search", nil);
//        self.searchBar.text = nil;
//        self.searchHistorymArray = [NSMutableArray arrayWithArray:[[SearchHistoryManager singleton] loadLocalSearchHistory]];
//        _viewModel.historyDataArr = self.searchHistorymArray;
//        [self.collectionView reloadData];
//    };
//    [self.navigationController pushViewController:searchResultVC animated:YES];
}

#pragma mark ---字符串长度 > 3 开始请求
- (void)searchAssociate:(NSString *)searchKey {
    
    @weakify(self)
    self.matchView.searchKey = searchKey;
    self.keyWordView.searchKey = searchKey;
    [self.associateViewModel associateRequest:@{@"keyword":STLToString(searchKey)} completion:^(OSSVSearchAssociateModel *model) {
        @strongify(self)
        if (model && [model isKindOfClass:[OSSVSearchAssociateModel class]] && (model.cat.count > 0 || model.goods.count > 0 || model.keywords.count > 0)) {
            
            if ([searchKey isEqualToString:self.keyWordView.searchKey]) {
                if (STLJudgeNSArray(model.keywords) && model.keywords.count > 0) {
                    self.keyWordView.hidden = NO;
                    self.keyWordView.keywords = model.keywords;
                    self.matchView.hidden = YES;
                }else{
                    self.matchView.hidden = NO;
                    self.keyWordView.hidden = YES;
                    self.matchView.recommendArray = model.cat;
                    self.matchView.matchResult = model.goods;
                }
            } else {
                self.matchView.hidden = YES;
                self.keyWordView.hidden = YES;
            }
        } else {
            self.matchView.hidden = YES;
            self.keyWordView.hidden = YES;
        }
    } failure:^(id error) {
        @strongify(self)
//        self.matchView.hidden = YES;
        self.keyWordView.hidden = YES;
    }];
}


#pragma mark - Lazy
- (OSSVSearchsHistoyViewsModel *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [[OSSVSearchsHistoyViewsModel alloc] init];
        _viewModel.controller = self;
        _viewModel.historyDataArr = self.searchHistorymArray;
    }
    return _viewModel;
}


- (OSSVSearchAssociateViewModel *)associateViewModel {
    if (!_associateViewModel) {
        _associateViewModel = [[OSSVSearchAssociateViewModel alloc] init];
    }
    return _associateViewModel;
}

- (OSSVSearchNavBar *)searchNavbar {
    if (!_searchNavbar) {
        _searchNavbar = [[OSSVSearchNavBar alloc] init];
        if (!self.searchTitle.length) {
            self.searchTitle = STLLocalizedString_(@"search", nil);
        }
        _searchNavbar.inputPlaceHolder = self.searchTitle;

        
        @weakify(self);
        _searchNavbar.searchInputCancelCompletionHandler = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        _searchNavbar.searchInputSearchKeyCompletionHandler = ^(NSString *searchKey) {
            @strongify(self);
            if (STLIsEmptyString(searchKey) || searchKey.length < 3) {
//                self.matchView.searchKey = STLToString(searchKey);
//                self.matchView.hidden = YES;
                self.keyWordView.searchKey = STLToString(searchKey);
                self.keyWordView.hidden = YES;
            } else {
                self.keyWordView.searchKey = STLToString(searchKey);
                [self searchAssociate:searchKey];
            }
        };
        
        _searchNavbar.searchInputReturnCompletionHandler = ^(NSString *searchKey) {
            @strongify(self);
            
            [self.view endEditing:YES];
            if (STLIsEmptyString(searchKey)) {return;}
        
            
            
            NSDictionary *sensorsDic = @{@"key_word":STLToString(searchKey),
                                     @"key_word_type":@"custom",
            };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchInitiate" parameters:sensorsDic];
            [ABTestTools.shared searchInitWithKeyWord:STLToString(searchKey) keyWordsType:@"custom"];
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"search" parameters:@{
                @"screen_group":@"Search",
                @"search_term":[NSString stringWithFormat:@"Nomal_%@",STLToString(searchKey)]}];
            
            
            [[SearchHistoryManager singleton] saveSearchHistory:searchKey];
           
            OSSVSearchResultVC * searchResultVC = [[OSSVSearchResultVC alloc]init];
            searchResultVC.keyword = searchKey;
            searchResultVC.keyWordType = sensorsDic[@"key_word_type"];
            searchResultVC.title = searchKey;
            NSDictionary *dic = @{kAnalyticsAction:@"",
                                  kAnalyticsUrl:@"",
                                  kAnalyticsKeyWord:STLToString(searchKey)
            };
            [searchResultVC.transmitMutDic addEntriesFromDictionary:dic];
            //    searchResultVC.isFromSearchVC = YES;
            searchResultVC.searchHistoryRefreshBlock = ^{
                //[self.searchNavbar clearSearchInfoOption];
                self.searchHistorymArray = [NSMutableArray arrayWithArray:[[SearchHistoryManager singleton] loadLocalSearchHistory]];
                self.viewModel.historyDataArr = self.searchHistorymArray;
                [self.collectionView reloadData];
            };
            [self.navigationController pushViewController:searchResultVC animated:YES];
            
            searchResultVC.popCompleteBlock = ^{
                self.searchNavbar.searchKey = @"";
//                [self.searchNavbar becomeEditFirst];
            };
         
            searchResultVC.popCompleteWithTextBlock = ^(NSString *searchKey) {
                self.searchNavbar.searchKey = searchKey;
                [self.searchNavbar becomeEditFirst];

            };
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.searchHistorymArray = [NSMutableArray arrayWithArray:[[SearchHistoryManager singleton] loadLocalSearchHistory]];
                self.viewModel.historyDataArr = self.searchHistorymArray;
                [self.collectionView reloadData];
            });
        
            [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
                   @"screen_group":@"Search",
                   @"button_name":@"Search_button"}];
        };
    }
    return _searchNavbar;
}

#pragma mark ---搜索匹配出热搜的词
- (OSSVSearchMatchResultView *)matchView {
    if (!_matchView) {
        _matchView = [[OSSVSearchMatchResultView alloc] initWithFrame:CGRectZero];
        _matchView.hidden = YES;
        @weakify(self);
        _matchView.searchMatchCloseKeyboardCompletionHandler = ^{
            @strongify(self);
            [self.view endEditing:YES];
        };
        
        _matchView.searchMatchResultSelectCompletionHandler = ^(STLSearchAssociateCatModel *category, STLSearchAssociateGoodsModel *match) {
            
            @strongify(self);
            [self.view endEditing:YES];
            //跳转到分类列表
            if (category) {
                OSSVCategorysListVC *categoriesVC = [OSSVCategorysListVC new];
                categoriesVC.childId = category.cat_id;
                categoriesVC.childDetailTitle = category.cat_name;
                [self.navigationController pushViewController:categoriesVC animated:YES];
                NSString *str = [NSString stringWithFormat:@"adorawe://action?actiontype=2&url=%@&name=%@&source=deeplink",category.cat_id,category.cat_name];
                NSDictionary *dic1 = @{@"key_word":STLToString(category.cat_name),
                                       @"url":str,
                                       @"key_word_type":@"associate",
                };
                
                NSDictionary *dic2 = @{@"key_word":STLToString(category.cat_name),
                                       @"url":str,
                                       @"key_word_type":@"associate",
                                       @"result_number":@(0)

                };

                NSDictionary *dic3 = @{@"key_word":STLToString(category.cat_name),
                                       @"url":str,
                                       @"key_word_type":@"associate",
                                       @"position_number":@(0),
                                       @"goods_sn"       :@(0),
                                       @"goods_name"     : @""
                };

                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchInitiate" parameters:dic1];
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchRequest" parameters:dic2];
                //[OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchResultClick" parameters:dic3];
                [ABTestTools.shared searchInitWithKeyWord:STLToString(category.cat_name) keyWordsType:@"associate"];
//                [ABTestTools.shared searchRequestWithKeyWord:STLToString(category.cat_name) keyWordsType:@"associate" resultNumber:0];
            } else if(match) {
                
                NSString *str = [NSString stringWithFormat:@"adorawe://action?actiontype=3&url=%@%@&name=%@&source=deeplink",match.goods_id,match.wid,match.goods_title];
                NSDictionary *dic1 = @{@"key_word":STLToString(category.cat_name),
                                       @"url":str,
                                       @"key_word_type":@"associate",
                };
                
                NSDictionary *dic2 = @{@"key_word":STLToString(category.cat_name),
                                       @"url":str,
                                       @"key_word_type":@"associate",
                                       @"result_number":@(0)

                };

                NSDictionary *dic3 = @{@"key_word":STLToString(category.cat_name),
                                       @"url":str,
                                       @"key_word_type":@"associate",
                                       @"position_number":@(0),
                                       @"goods_sn"       :@(0),
                                       @"goods_name"     : @"",
                };

                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchInitiate" parameters:dic1];
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchRequest" parameters:dic2];
                //[OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchResultClick" parameters:dic3];
                [ABTestTools.shared searchInitWithKeyWord:STLToString(category.cat_name) keyWordsType:@"associate"];
//                [ABTestTools.shared searchRequestWithKeyWord:STLToString(category.cat_name) keyWordsType:@"associate" resultNumber:0];

                OSSVDetailsVC *goodsDetailVC = [[OSSVDetailsVC alloc] init];
                goodsDetailVC.goodsId = match.goods_id;
                goodsDetailVC.wid = match.wid;
                goodsDetailVC.sourceType = STLAppsflyerGoodsSourceSearchResult;
                [self.navigationController pushViewController:goodsDetailVC animated:YES];
            }
        };
        
  
        _matchView.searchMatchHideMatchViewCompletionHandler = ^{
            @strongify(self);
            self.matchView.hidden = YES;
            [self.view endEditing:YES];
        };
    }
    return _matchView;
}

- (OSSVSearchKeyWordMatchView *)keyWordView{
    if (!_keyWordView) {
        _keyWordView = [OSSVSearchKeyWordMatchView new];
        _keyWordView.hidden = YES;
        @weakify(self);
        _keyWordView.keyWordHandler = ^(NSString * _Nonnull keyWord) {
            @strongify(self);
//            [self.searchNavbar changeKeyWordForTextField:keyWord];
            if (self.searchNavbar.searchInputReturnCompletionHandler) {
                self.searchNavbar.searchInputReturnCompletionHandler(keyWord);
            }
        };
        _keyWordView.copyHandler = ^(NSString * _Nonnull keyWord) {
            @strongify(self);
            [self.searchNavbar changeKeyWordForTextField:keyWord];
        };
    }
    return _keyWordView;
}
@end
