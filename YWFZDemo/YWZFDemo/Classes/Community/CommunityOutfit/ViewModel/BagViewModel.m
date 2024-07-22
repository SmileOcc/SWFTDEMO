//
//  BagViewModel.m
//  Zaful
//
//  Created by TsangFa on 16/11/28.
//  Copyright © 2016年 Y001. All rights reserved.
//

#import "ZFCommunityPostShowBagViewModel.h"
#import "CartListApi.h"
#import "GoodListModel.h"
#import "ZFCommunityShowPostBagCell.h"
#import "ZFCommunityShowBagVC.h"
#import "ZFCommunityPostShowOrderListModel.h"
#import "ZFGoodsModel.h"


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
                    ZFLog(@"点击相同的商品");
                    ShowAlertSingleBtnView(ZFLocalizedString(@"Post_ViewModel_Alert_NoItem_Tip",nil), nil, ZFLocalizedString(@"OK", nil));
                }else{
                    selectBtn.selected = !selectBtn.selected;
                    [bagVC.bagDict[@"selectArray"] removeObject:model];
                    [self.allGoodsIDArray removeObject:cell.goodListModel.goods_id];
                    [self sendSelectCountChangeNotific:self.allGoodsIDArray.count];
                }

            }else{
                if (self.allGoodsIDArray.count >= 6) {
                    ZFLog(@"超过6个了");
                    ShowAlertSingleBtnView(ZFLocalizedString(@"Post_ViewModel_Alert_MaxItem_Tip",nil), nil, ZFLocalizedString(@"OK", nil));
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
