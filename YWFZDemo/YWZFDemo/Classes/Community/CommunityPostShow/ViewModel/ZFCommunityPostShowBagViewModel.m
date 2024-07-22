//
//  ZFCommunityPostShowBagViewModel.m
//  ZZZZZ
//
//  Created by YW on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostShowBagViewModel.h"
#import "CartListApi.h"
#import "GoodListModel.h"
#import "ZFCommunityShowPostBagCell.h"
#import "ZFCommunityShowBagVC.h"
#import "ZFCommunityPostShowOrderListModel.h"
#import "ZFGoodsModel.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "YSAlertView.h"
#import "ZFRequestModel.h"
#import "Constants.h"

@interface ZFCommunityPostShowBagViewModel ()
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *allGoodsIDArray;
@end

@implementation ZFCommunityPostShowBagViewModel

- (void)requestBagNetwork:(id)parmaters
               completion:(void (^)(NSDictionary *pageDic))completion
{
    __block NSArray *goodsArray = nil;
    @weakify(self)
    CartListApi *carListApi = [[CartListApi alloc] init];
    [carListApi startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(carListApi.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200){
            goodsArray = [NSArray yy_modelArrayWithClass:[GoodListModel class] json:requestJSON[ZFResultKey]];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:goodsArray];
        }
        if (completion) {
            NSDictionary *pageDic = @{kTotalPageKey:@(1),
                                      kCurrentPageKey:@(1)};
            completion(pageDic);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityShowPostBagCell *cell = [ZFCommunityShowPostBagCell postBagCellWithTableView:tableView andIndexPath:indexPath];
    GoodListModel *model = self.dataArray[indexPath.row];
    ZFCommunityShowBagVC *bagVC = (ZFCommunityShowBagVC *)self.controller;
    [bagVC.bagDict[@"selectArray"] enumerateObjectsUsingBlock:^(GoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.goods_id isEqualToString:model.goods_id]) {
            model.isSelected = YES;
        }
    }];
    cell.goodListModel = model;
    
    @weakify(cell)
    cell.bagSelectBlock = ^(UIButton *selectBtn){
        @strongify(cell)
        [self.allGoodsIDArray removeAllObjects];
        @autoreleasepool {
            [bagVC.bagDict[@"selectArray"] enumerateObjectsUsingBlock:^(GoodListModel *bagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:bagModel.goods_id];
            }];
            
            [bagVC.bagDict[@"hotArray"] enumerateObjectsUsingBlock:^(GoodListModel *bagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:bagModel.goods_id];
            }];
            
            [bagVC.bagDict[@"wishArray"] enumerateObjectsUsingBlock:^(ZFGoodsModel *wishModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:wishModel.goods_id];
            }];
            
            [bagVC.bagDict[@"orderArray"] enumerateObjectsUsingBlock:^(ZFCommunityPostShowOrderListModel *orderModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:orderModel.goods_id];
            }];
            
            [bagVC.bagDict[@"recentArray"] enumerateObjectsUsingBlock:^(ZFGoodsModel *recentModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:recentModel.goods_id];
            }];
        }
        
            if ([self.allGoodsIDArray containsObject:cell.goodListModel.goods_id]) {
                if (!selectBtn.selected) {
                    YWLog(@"点击相同的商品");
                    ShowAlertSingleBtnView(ZFLocalizedString(@"Post_ViewModel_Alert_NoItem_Tip",nil), nil, ZFLocalizedString(@"OK", nil));
                }else{
                    selectBtn.selected = !selectBtn.selected;
                    
                    NSMutableArray *selectArray = bagVC.bagDict[@"selectArray"];
                    __block GoodListModel *goodListModel = nil;
                    [selectArray enumerateObjectsUsingBlock:^(GoodListModel *recentModel, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([recentModel.goods_id isEqualToString:cell.goodListModel.goods_id]) {
                            goodListModel = recentModel;
                            *stop = YES;
                        }
                    }];
                    
                    [bagVC.bagDict[@"selectArray"] removeObject:goodListModel];
                    [self.allGoodsIDArray removeObject:cell.goodListModel.goods_id];
                    [self sendSelectCountChangeNotific:self.allGoodsIDArray.count];
                }

            }else{
                if (self.allGoodsIDArray.count >= 6) {
                    YWLog(@"超过6个了");
                    ShowAlertSingleBtnView(ZFLocalizedString(@"Community_ProductMax6",nil), nil, ZFLocalizedString(@"OK", nil));
                }else{
                    selectBtn.selected = !selectBtn.selected;
                    cell.goodListModel.isSelected = selectBtn.selected;
                    [bagVC.bagDict[@"selectArray"]  addObject:model];
                    
                    [self sendSelectCountChangeNotific:(self.allGoodsIDArray.count + 1)];
                }
            }
    };
    return cell;
}


- (void)sendSelectCountChangeNotific:(NSInteger)count {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPostSelectGoodsCountNotification object:[NSString stringWithFormat:@"%ld",(long)count]];
}


#pragma mark - Setter/Getter
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray= [NSMutableArray new];
    }
    return _dataArray;
}

- (NSMutableArray *)allGoodsIDArray {
    if (!_allGoodsIDArray) {
        _allGoodsIDArray= [NSMutableArray new];
    }
    return _allGoodsIDArray;
}

@end
