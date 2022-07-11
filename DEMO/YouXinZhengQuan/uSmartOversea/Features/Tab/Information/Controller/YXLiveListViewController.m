//
//  YXLiveListViewController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveListViewController.h"

#import "YXLiveListViewModel.h"
#import "YXLiveDetailCell.h"
#import "YXLiveHeaderView.h"
#import "YXLiveModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "YXPreLiveViewModel.h"
#import "YXPreLiveViewController.h"
#import "YXNewCourseModel.h"
#import "YXLivingAndAdvanceView.h"
#import "YXVideoListCell.h"
#import "YXCourseListCell.h"

@interface YXLiveListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readonly) YXLiveListViewModel *viewModel;

@property (nonatomic, strong, nullable) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) YXLivingAndAdvanceView *livingView;

@end

@implementation YXLiveListViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadLiveData];
    
    [self loadPauseListData];
}

- (void)setupUI {
    self.view.backgroundColor = UIColor.whiteColor;
    
    YXRefreshHeader *header =  [YXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.collectionView.mj_header = header;
    
    YXRefreshAutoNormalFooter *footer = [YXRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreCourseData)];
    self.collectionView.mj_footer = footer;
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.leading.trailing.equalTo(self.view);
    }];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[YXVideoListCell class] forCellWithReuseIdentifier:@"YXVideoListCell"];
    [self.collectionView registerClass:[YXCourseListCell class] forCellWithReuseIdentifier:@"YXCourseListCell"];
    [self.collectionView registerClass:[YXLiveRecommendDetailCell class] forCellWithReuseIdentifier:@"YXLiveRecommendDetailCell"];
    
    [self.collectionView registerClass:[YXLiveHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"YXLiveHeaderView"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableView"];
}

- (void)refreshData {
    
    if (self.collectionView.mj_header) {
        [self loadData];
    }
}

- (void)loadData {
    
    [self loadLiveData];
    
    [self loadReplayData];
    
    [self loadCourseData];
    
    [self loadRecommendData];
}

- (void)loadLiveData {
    @weakify(self)
    [[self.viewModel.refreshLiveCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView reloadData];
        self.livingView.liveList = self.viewModel.liveList;
    }];
}

- (void)loadReplayData {
    @weakify(self)
    [[self.viewModel.refreshReplayCommand execute:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView reloadData];
    }];
}

- (void)loadCourseData {
    @weakify(self)
    [[self.viewModel.refreshCourseCommand execute:@(YES)] subscribeNext:^(NSNumber *canLoadMore) {
        @strongify(self);
        [self.collectionView.mj_footer resetNoMoreData];
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView reloadData];
    }];
}

- (void)loadMoreCourseData {
    @weakify(self)
    [[self.viewModel.refreshCourseCommand execute:@(NO)] subscribeNext:^(NSNumber *canLoadMore) {
        @strongify(self);
        if (!canLoadMore.boolValue) {
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.collectionView.mj_footer endRefreshing];
        }
        [self.collectionView reloadData];
    }];
}

- (void)loadRecommendData {
    @weakify(self)
    [[self.viewModel.refreshRecommendCommand execute:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView reloadData];
    }];
}


- (void)loadPauseListData {
    @weakify(self)
    [[self.viewModel.getPauseLiveListCommand execute:nil] subscribeNext:^(NSArray *list) {
        @strongify(self);
        if (list.count > 0) {
            [YXPauseAlertTool showWithList:list :^(YXLiveDetailModel * _Nonnull model) {
                YXPreLiveViewModel *viewModel = [[YXPreLiveViewModel alloc] initWithServices:self.viewModel.services params:@{@"liveId": model.id?:@""}];
                [self.viewModel.services pushViewModel:viewModel animated:YES];
            }];
        }
    }];
}
    
#pragma mark - collectionview
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1 + self.viewModel.replayList.count + self.viewModel.courseList.count + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger replayListCount = self.viewModel.replayList.count;
    if (section == 0) {
        if (self.viewModel.liveList.count > 0) {
            return 1;
        }
        return 0;
    } else if (section > replayListCount) {
        if (section == replayListCount + 1) {
            return self.viewModel.recommendModel.special_topic_video_json_info.count;
        } else {
            return 1;
        }
    } else {
        YXLiveCategoryModel *cateModel = self.viewModel.replayList[section - 1];
        return cateModel.show_list.count > 0 ? 1 : 0;
    }
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    @weakify(self);
    NSInteger replayListCount = self.viewModel.replayList.count;
    if (indexPath.section == 0) {
        UICollectionViewCell *livingCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
        [livingCell addSubview:self.livingView];
        [self.livingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(livingCell);
            make.top.equalTo(livingCell).offset(20);
            make.bottom.equalTo(livingCell).offset(-20);
        }];
        return livingCell;
                
    } else if (indexPath.section > replayListCount) {
        if (indexPath.section == replayListCount + 1) {
            YXLiveRecommendDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YXLiveRecommendDetailCell" forIndexPath:indexPath];
            cell.courseModel = self.viewModel.recommendModel.special_topic_video_json_info[indexPath.row].video_info;
            return cell;
        } else {
            YXNewCourseHomeManagerModel *manager = self.viewModel.courseList[indexPath.section - replayListCount - 2];
            YXCourseListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YXCourseListCell" forIndexPath:indexPath];
            cell.list = manager.special_topic_video_json_info;
            
            [cell setClickSetItemCallBack:^(YXNewCourseSetVideoInfoSubModel * _Nonnull setModel, NSString *videoId) {
                
                // 合集

                NSString *url;
                if (videoId.length > 0) {
                    url = [YXH5Urls playCollectionVideoUrlWith:setModel.set_id videoId:videoId];
                } else {
                    url = [YXH5Urls collectonVideoUrlWith:setModel.set_id];
                }
                [YXWebViewModel pushToWebVC:[YXH5Urls collectonVideoUrlWith:setModel.set_id]];

            }];
            
            [cell setClickVideoItemCallBack:^(YXNewCourseVideoInfoSubModel * _Nonnull videoModel) {
                [YXWebViewModel pushToWebVC:[YXH5Urls playVideoUrlWith:manager.special_topic_video_info.special_topic_id videoId:videoModel.video_id]];
            }];
            
            return cell;
        }
    } else {
        YXVideoListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YXVideoListCell" forIndexPath:indexPath];
        YXLiveCategoryModel *cateModel = self.viewModel.replayList[indexPath.section - 1];
        cell.replayList = cateModel.show_list;
        
        [cell setClickItemCallBack:^(YXLiveModel * _Nonnull model) {
            [self jumpLiveWebWithModel:model];
        }];
        
        return cell;
    }

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        YXLiveHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"YXLiveHeaderView" forIndexPath:indexPath];
        NSInteger replayListCount = self.viewModel.replayList.count;

        if (indexPath.section == 0) {

        } else if (indexPath.section > replayListCount) {
            header.arrowView.hidden = NO;
            YXNewCourseHomeManagerModel *manager = nil;
            if (indexPath.section == replayListCount + 1) {
                manager = self.viewModel.recommendModel;
            } else {
                manager = self.viewModel.courseList[indexPath.section - replayListCount - 2];
            }
            header.titleLabel.text = manager.special_topic_video_info.title.show;
            [header setArrowCallBack:^{
                if (manager.isRecommend) {
                    [YXWebViewModel pushToWebVC:[YXH5Urls recommendVideoUrl]];
                } else {
                    [YXWebViewModel pushToWebVC:[YXH5Urls videoSetUrlWithType:@"0" id:manager.special_topic_video_info.special_topic_id?:@""]];
                }
            }];
        } else {
            header.arrowView.hidden = NO;
            YXLiveCategoryModel *cateModel = self.viewModel.replayList[indexPath.section - 1];
            header.titleLabel.text = cateModel.name;
            [header setArrowCallBack:^{
                [YXWebViewModel pushToWebVC:[YXH5Urls videoSetUrlWithType:@"1" id:cateModel.id?:@""]];
            }];
        }
        
        return header;
    } else {
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableView" forIndexPath:indexPath];
        footer.backgroundColor = UIColor.whiteColor;
        return footer;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeZero;
    }
    
    // 推荐的组头高度
    NSInteger replayListCount = self.viewModel.replayList.count;
    if (section > replayListCount) {
        if (section == replayListCount + 1) {
            if (self.viewModel.recommendModel.special_topic_video_json_info.count == 0) {
                return CGSizeMake(YXConstant.screenWidth, 0);
            }
        }
    }
    return CGSizeMake(YXConstant.screenWidth, 45);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        return CGSizeZero;
    }
    
    NSInteger replayListCount = self.viewModel.replayList.count;
    if (section > replayListCount) {
        YXNewCourseHomeManagerModel *manager = nil;
        if (section == replayListCount + 1) {
            manager = self.viewModel.recommendModel;
        } else {
            manager = self.viewModel.courseList[section - replayListCount - 2];
        }
        if (manager.isRecommend) {
            return CGSizeMake(YXConstant.screenWidth, 26);
        }
    }
    return CGSizeMake(YXConstant.screenWidth, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return CGSizeMake(YXConstant.screenWidth, (YXConstant.screenWidth - 56) * 9 / 16 + 42 + 40);
    }
    
    NSInteger replayListCount = self.viewModel.replayList.count;
    
    // 计算高度
    CGFloat leftPadding = 12;
    CGFloat margin = 9;
    CGFloat width = (YXConstant.screenWidth - leftPadding * 2 - margin) * 0.5;
    
    if (indexPath.section > replayListCount) {
        YXNewCourseHomeManagerModel *manager = nil;
        if (indexPath.section == replayListCount + 1) {
            manager = self.viewModel.recommendModel;
        } else {
            manager = self.viewModel.courseList[indexPath.section - replayListCount - 2];
        }
        
        if (manager.isRecommend) {
            if (0 == indexPath.row) {
                return CGSizeMake(YXConstant.screenWidth - 24, 9 / 16.0 * width + 14 + 14);
            } else {
                return CGSizeMake(YXConstant.screenWidth - 24, 9 / 16.0 * width + 14);
            }
        } else {
            BOOL hasSet = NO;
            BOOL hasVideo = NO;
            for (YXNewCourseVideoInfoModel *model in manager.special_topic_video_json_info) {
                if (model.type == 1) {
                    hasVideo = YES;
                }
                if (model.type == 2) {
                    hasSet = YES;
                }
            }
            CGFloat height = 0;
            if (hasSet) {
                height += 274;
            }
            if (hasVideo) {
                CGFloat cellHeight = 118;
                for (YXNewCourseVideoInfoModel *model in manager.special_topic_video_json_info) {
                    if (model.video_info.height > cellHeight) {
                        cellHeight = model.video_info.height;
                    }
                }                
                height += cellHeight;
            }
            if (hasSet && hasVideo) {
                height += 14;
            }
            
            return CGSizeMake(YXConstant.screenWidth, height);
        }
    }
    
    CGFloat height = 118;
    YXLiveCategoryModel *cateModel = self.viewModel.replayList[indexPath.section - 1];
    for (YXLiveModel *model in cateModel.show_list) {
        if (model.height > height) {
            height = model.height;
        }
    }    
    return CGSizeMake(YXConstant.screenWidth, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
        
    NSInteger replayListCount = self.viewModel.replayList.count;
    
    if (indexPath.section == replayListCount + 1) {
        YXNewCourseHomeManagerModel *manager = self.viewModel.recommendModel;
        YXNewCourseVideoInfoModel *model = manager.special_topic_video_json_info[indexPath.row];
        [YXWebViewModel pushToWebVC:[YXH5Urls playRecommendVideoUrlWith:model.video_info.video_id]];
    }
}

- (void)jumpLiveWebWithModel:(YXLiveModel *)model {
    
    NSString *url = @"";
    
    if (model.status == 1) {
        // 预告
        url = [YXH5Urls playNewsNoticeUrlWith:model.id];
    } else if (model.status == 2) {
        // 直播
//        url = [YXH5Urls playNewsLiveUrlWith:model.id];
    } else if (model.status == 4) {
        // 点播
        url = [YXH5Urls playNewsRecordUrlWith:model.id];
       // propNameValue = YXSensorAnalyticsPropsConstants.propVideoName;
    }
    
    if (model.status == 2) {
        YXWatchLiveViewModel *viewModel = [[YXWatchLiveViewModel alloc] initWithServices:self.viewModel.services params:@{@"liveId": model.id}];
        [self.viewModel.services pushViewModel:viewModel animated:YES];
    } else {
        [YXWebViewModel pushToWebVC:url];
    }
    

    
}



#pragma mark - 懒加载
- (UICollectionViewFlowLayout *)layout {
    if (_layout == nil) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = 9;
//        _layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
    }
    return _layout;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    
        _collectionView.backgroundColor = UIColor.whiteColor;
    }
    return _collectionView;
}

- (YXLivingAndAdvanceView *)livingView {
    if (_livingView == nil) {
        _livingView = [[YXLivingAndAdvanceView alloc] init];
        @weakify(self);
        [_livingView setClickItemCallBack:^(YXLiveModel * _Nonnull liveModel) {
            @strongify(self);
            [self jumpLiveWebWithModel:liveModel];
            
        }];
    }
    return _livingView;
}

@end
