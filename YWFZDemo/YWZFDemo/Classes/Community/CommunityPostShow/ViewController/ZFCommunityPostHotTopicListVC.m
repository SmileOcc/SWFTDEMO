//
//  ZFCommunityPostHotTopicListVC.m
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostHotTopicListVC.h"

#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "ZFCommunityNavBarView.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "YWCFunctionTool.h"
#import "ZFRefreshHeader.h"

#import "ZFCommunityHotTopicCell.h"

@interface ZFCommunityPostHotTopicListVC ()
<
ZFInitViewProtocol,
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) ZFCommunityNavBarView      *showNavigationBar;

@property (nonatomic, strong) UITableView                *topicTableView;

@property (nonatomic, strong) ZFCommunityViewModel   *communityViewModel;

@property (nonatomic, strong) NSMutableArray <ZFCommunityHotTopicModel*> *hotTopicArrays;

@property (nonatomic, strong) NSIndexPath *selectIndexPath;

@end

@implementation ZFCommunityPostHotTopicListVC

- (void)showParentController:(UIViewController *)parentViewController topGapHeight:(CGFloat)topGapHeight {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        ZFCommunityShowPostTransitionDelegate *transitionDelegate = [[ZFCommunityShowPostTransitionDelegate alloc] init];
        self.modalTransitionStyle = UIModalPresentationCustom;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.transitionDelegate = transitionDelegate;
        self.transitioningDelegate = transitionDelegate;
        self.topGapHeight = topGapHeight;
        transitionDelegate.height = KScreenHeight - self.topGapHeight;
        
        if (parentViewController) {
            [parentViewController presentViewController:self animated:YES completion:nil];
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
    
    [self.topicTableView.mj_header beginRefreshing];
}

- (void)zfInitView {
    self.view.backgroundColor = ZFCClearColor();
    [self.view addSubview:self.showNavigationBar];
    [self.view addSubview:self.topicTableView];
}

- (void)zfAutoLayoutView {
    [self.topicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.showNavigationBar.mas_bottom);
    }];
}

- (void)setHotTopicModel:(ZFCommunityHotTopicModel *)hotTopicModel {
    _hotTopicModel = hotTopicModel;
    if (!ZFIsEmptyString(hotTopicModel.label)) {
        self.showNavigationBar.confirmButton.hidden = NO;
    } else {
        self.showNavigationBar.confirmButton.hidden = YES;
    }
}
- (void)loadHotTopic {
    
    @weakify(self)
    [self.communityViewModel requestHotTopicList:YES completion:^(NSArray<ZFCommunityHotTopicModel *> *results) {
        @strongify(self)
        [self handleHotTopic:results];
    }];
}

- (void)handleHotTopic:(NSArray <ZFCommunityHotTopicModel*> *)hotDatas {
    
    if (self.hotTopicModel) {
        [hotDatas enumerateObjectsUsingBlock:^(ZFCommunityHotTopicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.idx isEqualToString:self.hotTopicModel.idx]) {
                obj.isMark = YES;
                *stop = YES;
            }
        }];
    }
    [self.hotTopicArrays removeAllObjects];
    [self.hotTopicArrays addObjectsFromArray:hotDatas];
    [self.topicTableView reloadData];
    [self.topicTableView showRequestTip:hotDatas ? @{} : nil];

}
#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hotTopicArrays.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityHotTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFCommunityHotTopicCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.hotTopicArrays.count > indexPath.row) {
        ZFCommunityHotTopicModel *hotTopicModel = self.hotTopicArrays[indexPath.row];
        cell.hotTopicModel = hotTopicModel;
        
        if (hotTopicModel.isMark) {
            self.selectIndexPath = indexPath;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.hotTopicArrays.count > indexPath.row) {
        ZFCommunityHotTopicModel *hotTopicModel = self.hotTopicArrays[indexPath.row];
        if (hotTopicModel.isMark) {
            return;
        }
        
        if (self.selectIndexPath) {
            ZFCommunityHotTopicModel *selectHotTopicModel = self.hotTopicArrays[self.selectIndexPath.row];
            selectHotTopicModel.isMark = NO;
            ZFCommunityHotTopicCell *cell = (ZFCommunityHotTopicCell *)[tableView cellForRowAtIndexPath:self.selectIndexPath];
            cell.hotTopicModel = selectHotTopicModel;
        }
        
        hotTopicModel.isMark = YES;
        ZFCommunityHotTopicCell *currentCell = (ZFCommunityHotTopicCell *)[tableView cellForRowAtIndexPath:indexPath];
        currentCell.hotTopicModel = hotTopicModel;
        self.selectIndexPath = indexPath;
        
        if (self.selectTopic) {
            self.selectTopic(hotTopicModel);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Public Method

- (NSMutableArray<ZFCommunityHotTopicModel *> *)hotTopicArrays {
    if (!_hotTopicArrays) {
        _hotTopicArrays = [[NSMutableArray alloc] init];
    }
    return _hotTopicArrays;
}
- (ZFCommunityViewModel *)communityViewModel {
    if (!_communityViewModel) {
        _communityViewModel = [[ZFCommunityViewModel alloc] init];
    }
    return _communityViewModel;
}


- (ZFCommunityNavBarView *)showNavigationBar {
    if (!_showNavigationBar) {
        _showNavigationBar = [[ZFCommunityNavBarView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44) withMaxWidth:100];
        _showNavigationBar.confirmButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _showNavigationBar.confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_showNavigationBar.closeButton setImage:[UIImage imageNamed:@"z-me_outfits_post_close"] forState:UIControlStateNormal];
        _showNavigationBar.titleLabel.text = ZFLocalizedString(@"Community_HotEvents", nil);
        [_showNavigationBar.confirmButton setTitle:ZFLocalizedString(@"ZZZZZ_DontJoin", nil) forState:UIControlStateNormal];
        [_showNavigationBar.confirmButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        _showNavigationBar.backgroundColor = ZFC0xFFFFFF();
        [_showNavigationBar zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(22, 22)];
        
        @weakify(self)
        _showNavigationBar.closeBlock = ^(BOOL flag) {
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        _showNavigationBar.confirmBlock = ^(BOOL flag) {
            @strongify(self)
            if (self.cancelTopic) {
                self.cancelTopic(YES);
            }
            if (self.selectIndexPath) {
                
                ZFCommunityHotTopicModel *selectHotTopicModel = self.hotTopicArrays[self.selectIndexPath.row];
                selectHotTopicModel.isMark = NO;
                ZFCommunityHotTopicCell *cell = (ZFCommunityHotTopicCell *)[self.topicTableView cellForRowAtIndexPath:self.selectIndexPath];
                cell.hotTopicModel = selectHotTopicModel;
                self.selectIndexPath = nil;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        };

    }
    return _showNavigationBar;
}

- (UITableView *)topicTableView {
    if (!_topicTableView) {
        _topicTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _topicTableView.backgroundColor = ZFC0xFFFFFF();
        _topicTableView.delegate = self;
        _topicTableView.dataSource = self;
        _topicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _topicTableView.emptyDataImage = [UIImage imageNamed:@"blank_activity"];
        _topicTableView.emptyDataTitle = @"No Activity";
        [_topicTableView registerClass:[ZFCommunityHotTopicCell class] forCellReuseIdentifier:NSStringFromClass(ZFCommunityHotTopicCell.class)];
        
        @weakify(self);
        ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self loadHotTopic];
        }];
        [self.topicTableView setMj_header:header];
    }
    return _topicTableView;
}



@end
