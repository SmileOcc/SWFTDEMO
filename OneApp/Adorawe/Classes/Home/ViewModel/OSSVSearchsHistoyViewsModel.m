//
//  SearchHistoryViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/19.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSearchsHistoyViewsModel.h"
#import "OSSVSearchHistoryBtnCell.h"
#import "OSSVHotSearchCCCell.h"
#import "OSSVSearchHistryHeadeView.h"
#import "SearchHistoryManager.h"
#import "OSSVSearchResultVC.h"
#import "OSSVSearchsAnalytAip.h"
#import "OSSVSearchVC.h"

//热门搜索
#import "OSSVHotSearchsHeadeView.h"
#import "OSSVHotsSearchWordsModel.h"

#import "OSSVAdvsEventsManager.h"
#import "Adorawe-Swift.h"

@interface OSSVSearchsHistoyViewsModel ()

@end

@implementation OSSVSearchsHistoyViewsModel

- (void)searchAnalyticsRequestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        OSSVSearchsAnalytAip *api = [[OSSVSearchsAnalytAip alloc] initWithTrendsId:parmaters];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            STLLog(@"%@", [OSSVNSStringTool desEncrypt:request]);
            if (completion) {
                completion(nil);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

+ (NSString *)hotSearchFootCellID {
    return @"hotSearchFootCell";
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.hotDataArr.count > 0 && self.historyDataArr.count > 0) {
        return 2;
    }
    if (self.hotDataArr.count > 0 || self.historyDataArr.count > 0) {
        return 1;
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (APP_TYPE == 3) {
        if (self.historyDataArr.count == 0) {
            return self.hotDataArr.count;
        }
        if (section == 0) return self.historyDataArr.count;
        return self.hotDataArr.count;

    }
    
    if (self.hotDataArr.count == 0) {
        return self.historyDataArr.count;
    }
    
    if (section == 0) return self.hotDataArr.count;
    return self.historyDataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    
    if (APP_TYPE == 3) {
        
        if (indexPath.section == 0 && self.historyDataArr.count != 0) {
            
            OSSVSearchHistoryBtnCell *historyCell = (OSSVSearchHistoryBtnCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVSearchHistoryBtnCell.class) forIndexPath:indexPath];
            historyCell.textLab.text = self.historyDataArr[indexPath.item];
            cell = historyCell;
        }else{
            OSSVHotSearchCCCell *hotCell = (OSSVHotSearchCCCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVHotSearchCCCell.class) forIndexPath:indexPath];
            OSSVHotsSearchWordsModel *model = self.hotDataArr[indexPath.item];
            hotCell.titleLabel.text = model.word;
            hotCell.is_hot = model.is_hot;
            cell = hotCell;
            
        }
        
        return cell;
    }
    
    if (indexPath.section == 0 && self.hotDataArr.count != 0) {
        
        OSSVHotSearchCCCell *hotCell = (OSSVHotSearchCCCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVHotSearchCCCell.class) forIndexPath:indexPath];
        OSSVHotsSearchWordsModel *model = self.hotDataArr[indexPath.item];
        hotCell.titleLabel.text = model.word;
        hotCell.is_hot = model.is_hot;
        cell = hotCell;
    }else{
        
        OSSVSearchHistoryBtnCell *historyCell = (OSSVSearchHistoryBtnCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVSearchHistoryBtnCell.class) forIndexPath:indexPath];
        historyCell.textLab.text = self.historyDataArr[indexPath.item];
        cell = historyCell;
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (APP_TYPE == 3) {
            if (indexPath.section == 0 && self.historyDataArr.count != 0){
                OSSVSearchHistryHeadeView *historyHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(OSSVSearchHistryHeadeView.class) forIndexPath:indexPath];
                historyHeader.delegate = (id <SearchHistoryHeaderViewDelegate>)self;
                reusableView = historyHeader;
            }else{
                OSSVHotSearchsHeadeView *hotHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(OSSVHotSearchsHeadeView.class) forIndexPath:indexPath];
                reusableView = hotHeader;
            }

        } else {
            
            if (indexPath.section == 0 && self.hotDataArr.count != 0){
                OSSVHotSearchsHeadeView *hotHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(OSSVHotSearchsHeadeView.class) forIndexPath:indexPath];
                reusableView = hotHeader;
            }else{
                OSSVSearchHistryHeadeView *historyHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(OSSVSearchHistryHeadeView.class) forIndexPath:indexPath];
                historyHeader.delegate = (id <SearchHistoryHeaderViewDelegate>)self;
                reusableView = historyHeader;
            }
        }
    } else {
        UICollectionViewCell *hotHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:[OSSVSearchsHistoyViewsModel hotSearchFootCellID] forIndexPath:indexPath];
        reusableView = hotHeader;
        if (indexPath.section == 0){
            hotHeader.backgroundColor = [OSSVThemesColors stlWhiteColor];
        } else {
            hotHeader.backgroundColor = [OSSVThemesColors stlWhiteColor];
        }
    }
    
    if (reusableView) {
        return reusableView;
    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = OSSVThemesColors.col_F1F1F1;
    headerView.hidden = YES;
    
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *searchWord =  nil;
    BOOL isHot = NO;
    if (APP_TYPE == 3) {
        if (!(indexPath.section == 0 && self.historyDataArr.count != 0)) {
            isHot = YES;
        }
    } else if (indexPath.section == 0 && self.hotDataArr.count != 0) {
        isHot = YES;
    }
    
    if (isHot) {
        if (self.hotDataArr.count <= indexPath.item) {
            return;
        }
        OSSVHotsSearchWordsModel *model = self.hotDataArr[indexPath.item];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if (model.url){
            model.url = URLENCODING(model.url);
            NSString *queryStr = [model.url decodeFromPercentEscapeString:model.url];
            NSArray *availableArr = [queryStr componentsSeparatedByString:@"?"];
            
            if (availableArr.count > 1) {
                NSArray *arr = [availableArr[1] componentsSeparatedByString:@"&"];
                
                for (NSString *str in arr) {
                    NSRange range = [str rangeOfString:@"="];
                    if (range.location != NSNotFound) {
                        NSString *key   = [str substringToIndex:range.location];
                        NSString *value = [str substringFromIndex:range.location+1];
                        [dic setObject:value forKey:key];
                    }
                }
            }
        }
        
        
        
        
        OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
        advEventModel.sourceDeeplinkUrl = STLToString(model.url);
        advEventModel.actionType = AdvEventTypeDefault;
        advEventModel.url  = @"";
        advEventModel.name = @"";
        advEventModel.keyCotent = @"recommend";
        if (dic.count>0) {
            advEventModel.actionType = [dic[@"actiontype"] integerValue];
            advEventModel.url        = STLToString(dic[@"url"]);
            advEventModel.name       = STLToString(dic[@"name"]);
        }
        
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                     @"attr_node_1":@"home_search",
                                     @"attr_node_2":@"home_search_recommend",
                                     @"attr_node_3":@"",
                                     @"position_number":@(0),
                                    @"venue_position":@(0),
                                    @"action_type":@([advEventModel advActionType]),
                                    @"url":[advEventModel advActionUrl],
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
        
        
        NSDictionary *sensorsDic = @{@"key_word":STLToString(model.word),
                                     @"url":STLToString([advEventModel advActionUrl]),
                                 @"key_word_type":@"recommend",
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchInitiate" parameters:sensorsDic];
        
        if(advEventModel.actionType == 4){//搜索结果才埋
            [ABTestTools.shared searchInitWithKeyWord:STLToString(model.word) keyWordsType:@"recommend"];
        }
        
        //数据GA 是否需要历史搜索词
            
         [OSSVAnalyticsTool analyticsGAEventWithName:@"search" parameters:@{
                @"screen_group":@"Search",
                @"search_term":[NSString stringWithFormat:@"Popularl_%@",STLToString(model.word)]}];
        
        [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:advEventModel];
        
        // 后台数据统计
        NSString *trendsId = [OSSVNSStringTool isEmptyString:model.trendsId] ? @"" : model.trendsId;
        [self searchAnalyticsRequestNetwork:trendsId completion:^(id obj) {
        
        } failure:^(id obj) {
            
        }];
        
        
    } else {
        if (self.historyDataArr.count <= indexPath.item) {
            return;
        }
        
        
        searchWord = self.historyDataArr[indexPath.item];
        OSSVSearchResultVC * searchResultVC = [[OSSVSearchResultVC alloc]init];
        searchResultVC.keyword = searchWord;
        searchResultVC.title = searchWord;
        searchResultVC.keyWordType = @"history";
        NSDictionary *dic = @{kAnalyticsAction:@"",
                              kAnalyticsUrl:@"",
                              kAnalyticsKeyWord:STLToString(searchWord)
        };
        [searchResultVC.transmitMutDic addEntriesFromDictionary:dic];
        [self.controller.navigationController pushViewController:searchResultVC animated:YES];
        @weakify(self);
        searchResultVC.popCompleteBlock = ^{
            @strongify(self);
            if ([self.controller isKindOfClass:[OSSVSearchVC class]]) {
                OSSVSearchVC *searchVC = (OSSVSearchVC *)self.controller;
                [searchVC.searchNavbar becomeEditFirst];
            }
        };
        
        searchResultVC.popCompleteWithTextBlock = ^(NSString *searchKey) {
            OSSVSearchVC *searchVC = (OSSVSearchVC *)self.controller;
            searchVC.searchNavbar.searchKey = searchKey;
            [searchVC.searchNavbar becomeEditFirst];
        };
        

        NSDictionary *sensorsDic = @{@"key_word":STLToString(searchWord),
                                 @"key_word_type":@"history",
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchInitiate" parameters:sensorsDic];
        [ABTestTools.shared searchInitWithKeyWord:STLToString(searchWord) keyWordsType:@"history"];

    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 12, 0, 12);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return CGSizeMake(SCREEN_WIDTH, 12);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize itemSize = CGSizeZero;
    if (APP_TYPE == 3) {
        if (indexPath.section == 0 && self.historyDataArr.count != 0) {
            NSString *word = self.historyDataArr[indexPath.item];
            NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
            itemSize = [word boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
            itemSize = CGSizeMake(itemSize.width + 24, 32);
            return itemSize;
            
        } else {
            OSSVHotsSearchWordsModel *model = self.hotDataArr[indexPath.item];
            NSString *word = model.word;
            NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
            itemSize = [word boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
            if (model.is_hot == 1) {
                itemSize = CGSizeMake(itemSize.width + 40, 32);
            }else{
                itemSize = CGSizeMake(itemSize.width + 24, 32);
            }
            return itemSize;
        }

        
    } else {
        
        if (indexPath.section == 0 && self.hotDataArr.count != 0) {
            OSSVHotsSearchWordsModel *model = self.hotDataArr[indexPath.item];
            NSString *word = model.word;
            NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
            itemSize = [word boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
            if (model.is_hot == 1) {
                itemSize = CGSizeMake(itemSize.width + 40, 32);
            }else{
                itemSize = CGSizeMake(itemSize.width + 24, 32);
            }
            
            return itemSize;
            
        } else {
            NSString *word = self.historyDataArr[indexPath.item];
            NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
            itemSize = [word boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
            itemSize = CGSizeMake(itemSize.width + 24, 32);
            return itemSize;
        }
    }
}

#pragma mark - 删除所有搜索记录
- (void)deleteSearchHistory {
    [[SearchHistoryManager singleton] removeSearchHistory];
    [self.historyDataArr removeAllObjects];
    [self.collectionView reloadData];
}

- (void)updateSearchHistory:(NSMutableArray *)historyDataArr {
    self.historyDataArr = historyDataArr;
    [self.collectionView reloadData];
}

@end
