//
//  CategorySubLevelViewModel.m
//  ListPageViewController
//
//  Created by YW on 26/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategorySubLevelViewModel.h"
#import "CategorySubLevelCell.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "CategoryDataManager.h"

@interface CategorySubLevelViewModel ()
@property (nonatomic, strong) CategoryNewModel           *model;
@property (nonatomic, strong) NSMutableArray             *subLevelArray;
@end

@implementation CategorySubLevelViewModel
#pragma mark - Public Methods
-(void)requestSubLevelDataWithParentID:(NSString *)parentID completion:(void (^)(void))completion {
    [CategoryDataManager shareManager].isVirtualCategory = NO;
    NSArray<CategoryNewModel *> *dataArray = [[CategoryDataManager shareManager] querySubCategoryDataWithParentID:parentID];
    CategoryNewModel *viewAllModel = [[CategoryNewModel alloc] init];
    viewAllModel.cat_name = ZFLocalizedString(@"TopicDetailView_ViewAll", nil);
    viewAllModel.cat_id = dataArray.firstObject.parent_id;
    viewAllModel.parent_id = @"0";
    viewAllModel.is_child = @"1"; // 1 有子级 0 没有
    [self.subLevelArray addObjectsFromArray:dataArray];
    [self.subLevelArray insertObject:viewAllModel atIndex:0];
    [self analyticsCateBannerWithCateArray:self.subLevelArray];

    if (completion) {
        completion();
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.subLevelArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CategorySubLevelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CategorySubLevelCell setIdentifier] forIndexPath:indexPath];
    cell.model = self.subLevelArray[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryNewModel *model = self.subLevelArray[indexPath.row];
    if (self.handler) {
        self.handler(model);
    }
    // 谷歌统计
    [ZFAnalytics clickButtonWithCategory:@"Category" actionName:@"Cate - subLevel" label:[NSString stringWithFormat:@"Cate - %@", model.cat_name]];
    NSString *GABannerId   = model.cat_id;
    NSString *GABannerName = [NSString stringWithFormat:@"%@_%@",ZFGACategoryInternalPromotion, model.cat_name];
    NSString *position     = @"";
    [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
}

#pragma mark - Getter
-(NSMutableArray *)subLevelArray {
    if (!_subLevelArray) {
        _subLevelArray = [NSMutableArray array];
    }
    return _subLevelArray;
}

#pragma mark - 谷歌统计
-(void)analyticsCateBannerWithCateArray:(NSArray<CategoryNewModel *> *)cateArray {
    NSMutableArray *screenNames = [NSMutableArray array];
    for (int i = 0; i < cateArray.count; i++) {
        CategoryNewModel * model = cateArray[i];
        NSString *screenName = [NSString stringWithFormat:@"%@_%@",ZFGACategoryInternalPromotion, model.cat_name];
        [screenNames addObject:@{@"name":screenName,@"position": @""}];
    }
    [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"Category"];
}

@end
