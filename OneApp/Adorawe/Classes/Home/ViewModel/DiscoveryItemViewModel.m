//
//  DiscoveryItemViewModel.m
//  Yoshop
//
//  Created by Qiu on 16/6/21.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "DiscoveryItemViewModel.h"
#import "DiscoveryItemCell.h"
#import "DiscoveryHeaderView.h"
#import "DiscoveryItemApi.h"

#import "DiscoveryItemModel.h"
#import "DiscoveryHeaderModel.h"

#import "JumpModel.h"
#import "JumpManager.h"

@interface DiscoveryItemViewModel ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) DiscoveryHeaderModel *discoverHeaderModel;
@property (nonatomic, strong) DiscoveryItemModel *discoveryModel;

@end

@implementation DiscoveryItemViewModel
#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {

    @weakify(self)
    [[YSNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        NSString *refreshOrLoadMore = (NSString *)parmaters;
        NSInteger page = 1;
        if ([refreshOrLoadMore integerValue] == 0) {
            // 假如最后一页的时候
            if (self.discoveryModel.page == self.discoveryModel.pageCount) {
                if (completion) {
                    completion(YSNoMoreToLoad);
                }
                return; // 直接返回
            }
            page = self.discoveryModel.page  + 1;
        }
        DiscoveryItemApi *api = [[DiscoveryItemApi alloc] initWithDiscoveryPage:page pageSize:kYSPageSize];
        //    [api.accessoryArray addObject:[[YSRequestAccessory alloc] init]];
        [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
            @strongify(self)
            id requestJSON = [NSStringUtils desEncrypt:request];
            self.discoveryModel = [self dataAnalysisFromJson: requestJSON request:api];
            // 列表数据
            if (page == 1) {
                self.dataArray = [NSMutableArray arrayWithArray:self.discoveryModel.listArray];
                
                // 谷歌统计
                if (self.discoveryModel.bannerArray.count>0) {
                    [self analyticsHomeBannerWithBannerArray:self.discoveryModel.bannerArray position:@"Home - Rolling Banner Tab - P"];
                }else if (self.discoveryModel.topicArray.count>0){
                    [self analyticsHomeBannerWithBannerArray:self.discoveryModel.topicArray position:@"Home - Activity Banner Tab - P"];
                }else if (self.discoveryModel.threeArray.count>0){
                    [self analyticsHomeBannerWithBannerArray:self.discoveryModel.threeArray position:@"Home - Small Banner Tab - P"];
                }else if (self.discoveryModel.listArray.count>0){
                    [self analyticsHomeBannerWithBannerArray:self.discoveryModel.listArray position:@"Home - Session Banner Tab - P"];
                }
            } else {
                [self.dataArray addObjectsFromArray:self.discoveryModel.listArray];
                
                // 谷歌统计
                if (self.discoveryModel.listArray.count>0) {
                    [self analyticsHomeBannerWithBannerArray:self.discoveryModel.listArray position:@"Home - Session Banner Tab - P"];
                }
            }
            // 头部数据
            [self getDiscoverHeaderDataModel];
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewHideType : EmptyShowNoDataType;
            if (completion) {
                completion(nil);
            }
        } failure:^(__kindof SYBaseRequest *request, NSError *error) {
            @strongify(self)
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewHideType : EmptyShowNoNetType;
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        @strongify(self)
        self.emptyViewShowType = EmptyShowNoNetType;
        if (failure) {
            failure(nil);
        }
    }];

    
}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request {
    
//    YSLog(@"json === %@",json);
    if ([request isKindOfClass:[SYBaseRequest class]]) {
        if ([json[@"statusCode"] integerValue] == 200) {
            return [DiscoveryItemModel yy_modelWithJSON:json[@"result"]];
        }
        else {
            if ([json[@"statusCode"] integerValue] == 202) return nil; // 此处也隐藏某些不必要的提示
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

#pragma mark 转换头部数据
- (void)getDiscoverHeaderDataModel {
    
    // 必须在discoveryModel 获取成功后
    self.discoverHeaderModel = [[DiscoveryHeaderModel alloc] init];
    self.discoverHeaderModel.bannerArray = self.discoveryModel.bannerArray;
    self.discoverHeaderModel.topicArray = self.discoveryModel.topicArray;
//     必须等于三个否则不返回
    if (self.discoveryModel.threeArray.count == 3) {
        self.discoverHeaderModel.threeArray = self.discoveryModel.threeArray;
    }
 
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count > kYSPageSize - 1) {
        tableView.mj_footer.hidden = NO;
    } else {
        tableView.mj_footer.hidden = YES;
    }
    return self.dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    DiscoveryHeaderView *headerView = [[DiscoveryHeaderView alloc] initWithFrame:CGRectZero];
    headerView.controller = self.controller;
    headerView.model =  self.discoverHeaderModel;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    #pragma mark Prviate 确定其DiscoverHeader动态高度
    CGFloat height = CGFLOAT_MIN;
    if (self.discoverHeaderModel.bannerArray.count > 0) {
        height += kDiscoverHeaderTopViewHeight;
    }
    if (self.discoverHeaderModel.topicArray.count > 0) {
        height += kDiscoverHeaderMiddleViewHeight;
    }
    else {
        // 增加底部View空隙的预留
        if (self.discoverHeaderModel.bannerArray.count > 0 && self.discoverHeaderModel.threeArray.count > 0) {
            height += kDiscoverHeaderBottomToOtherSpace;
        }
    }
    if (self.discoverHeaderModel.threeArray.count > 0) {
        height += kDiscoverHeaderBottomViewHeight + kDiscoverHeaderBottomToOtherSpace;
    }
    else {
        // 此处是对底部空隙的一种预留
        if (self.discoverHeaderModel.bannerArray.count > 0 && !(self.discoverHeaderModel.topicArray.count > 0)) {
            height += kDiscoverHeaderBottomToOtherSpace;
        }
    }
    return height;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN; // 防止底部出现 footerView
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  kDiscoveryCellImageHeight * DSCREEN_WIDTH_SCALE + kDiscoveryCellSpace;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DiscoveryItemCell *cell = [DiscoveryItemCell discoveryItemCellWithTableView:tableView andIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.bannerModel = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //TODO :
    YSLog(@"discovery cell index == %lu",(long)indexPath.row);
    // 跳转到我们指定的地方去
    JumpModel *jumpModel = self.dataArray[indexPath.row];
    [JumpManager doJumpActionTarget:self.controller withJumpModel:jumpModel];
    
    // 谷歌统计
    NSString *GABannerId = jumpModel.url;
    NSString *GABannerName = [NSStringUtils bannerScreenKeyWithBannerName:jumpModel.name screenName:@"HomeBanner"];
    NSString *position = [NSString stringWithFormat:@"Home - Session Banner Tab - P%ld", indexPath.row+1];
    [YSAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
    [YSAnalytics clickButtonWithCategory:@"Home" actionName:@"Home - Banner" label:@"Home - Session Banner Tab"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DZNEmptyDataSetSource Methods
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    
    self.emptyViewManager.customNoDataView = [self makeCustomNoDataView];
    return [self.emptyViewManager accordingToTypeReBackView:self.emptyViewShowType];
}

#pragma mark make - privateCustomView(NoDataView)
- (UIView *)makeCustomNoDataView {
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectZero];
    customView.backgroundColor = [UIColor whiteColor];
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"loading_failed"];
    imageView.userInteractionEnabled = YES;
    [customView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_top).offset(80);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = YSBlACK_COLOR;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = NSLocalizedString(@"load_failed", nil);;
    [customView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = YSMAIN_COLOR;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:YSCOLOR(51, 51, 51, 1.0) forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"retry", nil) forState:UIControlStateNormal];
    /**
        emptyOperationTouch
        emptyJumpOperationTouch
        暂时两个动态选择
     */
    [button addTarget:self action:@selector(emptyOperationTouch) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [customView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(30);
        make.centerX.mas_equalTo(customView.mas_centerX);
        make.width.mas_equalTo(@180);
        make.height.mas_equalTo(@40);
    }];
    return customView;
}

#pragma mark - 谷歌统计
- (void)analyticsHomeBannerWithBannerArray:(NSArray<JumpModel *> *)banners position:(NSString *) positionCate{
    NSMutableArray *screenNames = [NSMutableArray array];
    for (int i = 0; i < banners.count; i++) {
        JumpModel * banner = banners[i];
        NSString *screenName = [self bannerScreenKeyWithBannerName:banner.name];
        NSString *position = @"";
        if ([positionCate isEqualToString:@"Home - Session Banner Tab - P"]) {
            if (self.discoveryModel.page == 1) {
                position = [NSString stringWithFormat:@"%@%d", positionCate, i+1];
            }else{
                position = [NSString stringWithFormat:@"%@%lu", positionCate, kYSPageSize*(self.discoveryModel.page-1)+i+1];
            }
        }else{
            position = [NSString stringWithFormat:@"%@%d", positionCate, i+1];
        }
        [screenNames addObject:@{@"name":screenName,@"position":position}];
    }
    [YSAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"Home"];
}

- (NSString *)bannerScreenKeyWithBannerName:(NSString *)name {
    return [NSString stringWithFormat:@"HomeBanner - %@",name];
}

@end
