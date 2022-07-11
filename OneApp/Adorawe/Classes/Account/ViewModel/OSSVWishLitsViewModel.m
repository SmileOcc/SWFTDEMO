

//
//  WishViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVWishLitsViewModel.h"
#import "CartModel.h"
#import "OSSVDelCollectApi.h"
#import "OSSVWishListsTableCell.h"
#import "OSSVAccountMysWishsModel.h"
#import "OSSVAccountsMysWishListsAip.h"
#import "OSSVAccountMyWishListsModel.h"
#import "OSSVDetailsVC.h"
#import "OSSVDetailsBaseInfoModel.h"
#import "OSSVWishsListAnalyseAP.h"
#import "STLActionSheet.h"
#import "OSSVDetailsViewModel.h"

#import "Adorawe-Swift.h"

@interface OSSVWishLitsViewModel () <WishListCellDelegate>
@property (nonatomic,strong) OSSVAccountMyWishListsModel *myWishListModel;

@property (nonatomic, strong) OSSVWishsListAnalyseAP   *wishListAnalyticsManager;

@property (nonatomic, strong) STLActionSheet                *detailSheet; // 属性选择弹窗
@property (nonatomic, strong) OSSVDetailsViewModel         *baseInfoModel;
@end

@implementation OSSVWishLitsViewModel

- (void)dealloc {
    if (_detailSheet) {
        [_detailSheet removeFromSuperview];
        _detailSheet= nil;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.wishListAnalyticsManager];
    }
    return self;
}

#pragma mark Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        OSSVAccountsMysWishListsAip *api = [[OSSVAccountsMysWishListsAip alloc] init];
        
        {
            // 取缓存数据
            if (api.cacheJSONObject) {
                id requestJSON = api.cacheJSONObject;
                self.myWishListModel = [self dataAnalysisFromJson: requestJSON request:api];
                self.dataArray = [NSMutableArray arrayWithArray:self.myWishListModel.goodList];
                self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;

                if (completion) {
                    completion(nil);
                }
            }
        }
        
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
             @strongify(self)
//            self.myWishListModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.myWishListModel = [self dataAnalysisFromJson: requestJSON request:api];
            self.dataArray = [NSMutableArray arrayWithArray:self.myWishListModel.goodList];
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;

            
            if (completion) {
                completion(nil);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            @strongify(self)
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoNet;
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        @strongify(self)
        self.emptyViewShowType = EmptyViewShowTypeNoNet;
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestCollectDelNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {

    [[STLNetworkStateManager sharedManager] networkState:^{
        NSArray *array = (NSArray *)parmaters;
        OSSVDelCollectApi *api = [[OSSVDelCollectApi alloc] initWithAddCollectGoodsId:array[0] wid:array[1]];
//        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            if (completion) {
                completion(nil);
            }
            [self alertMessage:STLLocalizedString_(@"success",nil)];
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"failure");
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVAccountsMysWishListsAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVAccountMyWishListsModel yy_modelWithJSON:json[kResult]];
        }else if ([request isKindOfClass:[OSSVDelCollectApi class]]) {
            if ([json[kStatusCode] integerValue] == kStatusCode_200) {
                return @(YES);
            }
        } else {
//            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

#pragma mark TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count < 7) {
        tableView.mj_footer.hidden = YES;
    } else {
        tableView.mj_footer.hidden = NO;
    }
    return self.dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVWishListsTableCell *cell = [OSSVWishListsTableCell accountMyWishCellWithTableView:tableView andIndexPath:indexPath];
//    cell.delegate = self;
    cell.myDelegate = self;
    if (self.dataArray.count > indexPath.row) {
        cell.model = self.dataArray[indexPath.row];
        [cell showBottomLine:(indexPath.row == self.dataArray.count-1 ? NO : YES)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSSVAccountMysWishsModel *model = self.dataArray[indexPath.row];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"view_product_detail" parameters:@{
           @"screen_group":@"WishList",
           @"action":[NSString stringWithFormat:@"Check_%@",STLToString(model.goodsTitle)]}];
    
    OSSVDetailsVC *detailsVC = [OSSVDetailsVC new];
    detailsVC.goodsId = model.goodsId;
    detailsVC.wid = model.wid;
    detailsVC.sourceType = STLAppsflyerGoodsSourceWishlist;
    detailsVC.coverImageUrl = STLToString(model.goodsThumb);
    NSDictionary *dic = @{kAnalyticsAction:[OSSVAnalyticsTool sensorsSourceStringWithType:STLAppsflyerGoodsSourceWishlist sourceID:@""],
                          kAnalyticsUrl:@"",
                          kAnalyticsPositionNumber:@(indexPath.row+1),
    };
    [detailsVC.transmitMutDic addEntriesFromDictionary:dic];
    [self.controller.navigationController pushViewController:detailsVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 12)];
    headerView.backgroundColor = [OSSVThemesColors stlClearColor];
    if (APP_TYPE == 3) {
        return headerView;
    }

    UIView *cornerView = [[UIView alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH - 24, 12)];
    [cornerView stlAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
    cornerView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    [headerView addSubview:cornerView];
    
    if (self.dataArray.count <= 0) {
        headerView.hidden = YES;
    }
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 6)];
    footerView.backgroundColor = [OSSVThemesColors stlClearColor];
    if (APP_TYPE == 3) {
        return footerView;
    }
    UIView *cornerView = [[UIView alloc] initWithFrame:CGRectMake(12, -6, SCREEN_WIDTH - 24, 12)];
    [cornerView stlAddCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
    cornerView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    [footerView addSubview:cornerView];
    footerView.layer.masksToBounds = YES;
    if (self.dataArray.count <= 0) {
        footerView.hidden = YES;
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (APP_TYPE == 3) {
        return 138;
    }
    return 128;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.dataArray.count <= 0) {
        return 0.01;
    }
    if (APP_TYPE == 3) {
        return 0.01;
    }
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    if (self.dataArray.count <= 0) {
        return 0.01;
    }
    if (APP_TYPE == 3) {
        return 0.01;
    }
    return 6;
}


- (OSSVWishsListAnalyseAP *)wishListAnalyticsManager {
    if (!_wishListAnalyticsManager) {
        _wishListAnalyticsManager = [[OSSVWishsListAnalyseAP alloc] init];
    }
    return _wishListAnalyticsManager;
}

///1.3.6
#pragma mark -WishList Delegate

- (OSSVDetailsViewModel *)baseInfoModel {
    if (!_baseInfoModel) {
        _baseInfoModel = [[OSSVDetailsViewModel alloc] init];
    }
    return _baseInfoModel;
}

- (void)requesData:(NSString*)goodsId wid:(NSString*)wid {
    @weakify(self)
    NSDictionary *dic = dic = @{@"goods_id":STLToString(goodsId),
                                @"loadState":STLRefresh,
                                @"wid":STLToString(wid),
                                @"specialId":STLToString(@"")};
    [self.baseInfoModel requestGoodsListBaseInfo:dic completion:^(OSSVDetailsBaseInfoModel *obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            self.detailSheet.baseInfoModel = baseInfoModel;
            self.detailSheet.hadManualSelectSize = YES;
            
            if (STLIsEmptyString(baseInfoModel.specialId) && baseInfoModel.flash_sale && !STLIsEmptyString(baseInfoModel.flash_sale.active_discount) && [baseInfoModel.flash_sale.active_discount floatValue] > 0) {
                _detailSheet.hasFirtFlash = YES;
            }else{
                _detailSheet.hasFirtFlash = NO;
            }
            [self.detailSheet addCartAnimationTop:0 moveLocation:CGRectZero showAnimation:NO];
            [self.controller.navigationController.view addSubview:self.detailSheet];
            [UIView animateWithDuration: 0.25 animations: ^{
                [self.detailSheet shouAttribute];
                self.detailSheet.sourceType = STLAppsflyerGoodsSourceFlashList;
                self.detailSheet.type = GoodsDetailEnumTypeAdd;
            } completion: nil];
            
        }
    } failure:^(id obj) {
    }];
}

- (void)requesData:(NSString*)goodsId wid:(NSString*)wid specialId:(NSString *)specialId{
    @weakify(self)
    NSDictionary *dic = dic = @{@"goods_id":STLToString(goodsId),
                                @"loadState":STLRefresh,
                                @"wid":STLToString(wid),
                                @"specialId":STLToString(specialId)};
    [self.baseInfoModel requestGoodsListBaseInfo:dic completion:^(OSSVDetailsBaseInfoModel *obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            self.detailSheet.baseInfoModel = baseInfoModel;
            self.detailSheet.hadManualSelectSize = YES;
            
            if (STLIsEmptyString(baseInfoModel.specialId) && baseInfoModel.flash_sale && !STLIsEmptyString(baseInfoModel.flash_sale.active_discount) && [baseInfoModel.flash_sale.active_discount floatValue] > 0) {
                _detailSheet.hasFirtFlash = YES;
            }else{
                _detailSheet.hasFirtFlash = NO;
            }
            [self.detailSheet addCartAnimationTop:0 moveLocation:CGRectZero showAnimation:NO];
            [self.controller.navigationController.view addSubview:self.detailSheet];
            [UIView animateWithDuration: 0.25 animations: ^{
                [self.detailSheet shouAttribute];
                self.detailSheet.sourceType = STLAppsflyerGoodsSourceFlashList;
                self.detailSheet.type = GoodsDetailEnumTypeAdd;
            } completion: nil];
            
        }
    } failure:^(id obj) {
    }];
}
#pragma mark ---加购弹窗
-(void)accountMyWishCell:(OSSVWishListsTableCell *)cell addToCart:(OSSVAccountMysWishsModel *)wishModel{
    NSInteger index = 0;
    if (self.dataArray) {
        index = [self.dataArray indexOfObject:wishModel];
    }
    self.detailSheet.analyticsDic = @{kAnalyticsPositionNumber:@(index+1)}.mutableCopy;
    [OSSVAnalyticsTool analyticsGAEventWithName:@"item_pop_ups" parameters:@{@"screen_group" : @"WishList",
                                                                        @"position"     : @"WishList",
                                                                        @"content"      : STLToString(wishModel.goodsTitle)
 }];
    self.detailSheet.screenGroup = @"WishList_Pop-ups_";
    self.detailSheet.position    = @"WishList_Pop-ups";
    [self requesData:wishModel.goodsId wid:wishModel.wid];
}

- (void)accountMyWishCell:(OSSVWishListsTableCell *)cell deleteModel:(OSSVAccountMysWishsModel *)wishModel {
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"wishList_action" parameters:@{
           @"screen_group":@"WishList",
           @"action":[NSString stringWithFormat:@"%@",@"Delete"],
           @"content":STLToString(wishModel.goodsTitle)}];
    
    OSSVAccountMysWishsModel *model = wishModel;
    NSArray *upperTitle = @[STLLocalizedString_(@"cancel",nil).uppercaseString,STLLocalizedString_(@"yes", nil).uppercaseString];
    NSArray *lowserTitle = @[STLLocalizedString_(@"cancel",nil),STLLocalizedString_(@"yes", nil)];
    
    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:STLLocalizedString_(@"removeItems", nil) buttonTitles:APP_TYPE == 3 ? lowserTitle : upperTitle buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
        if (index==1) {
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"wishList_action" parameters:@{
                   @"screen_group":@"WishList",
                   @"action":[NSString stringWithFormat:@"%@",@"Remove_Confirm"],
                   @"content":STLToString(wishModel.goodsTitle)
            }];
            
            [self requestCollectDelNetwork:@[model.goodsId,model.wid] completion:^(id obj) {
                [self.dataArray removeObject:model];
                self.completeExecuteBlock();
            } failure:^(id obj) {
                
            }];
        } else {
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"wishList_action" parameters:@{
                   @"screen_group":@"WishList",
                   @"action":[NSString stringWithFormat:@"%@",@"Remove_Cancel"],
                   @"content":STLToString(wishModel.goodsTitle)
            }];
        }
    }];

    
}

- (STLActionSheet *)detailSheet {
    if (!_detailSheet) {
        CGFloat detailSheetY = kIS_IPHONEX? 88.f : 64.f;
        _detailSheet = [[STLActionSheet alloc] initWithFrame:CGRectMake(0, -detailSheetY, SCREEN_WIDTH, SCREEN_HEIGHT+detailSheetY)];
        _detailSheet.type = GoodsDetailEnumTypeAdd;
//        _detailSheet.hasFirtFlash = YES;
        _detailSheet.isListSheet = YES;
        _detailSheet.addCartType = 1;
        _detailSheet.showCollectButton = NO;
        _detailSheet.gaAnalyticsDic = @{kGA_screen_group: @"WishList",kGA_position: @"WishList"}.mutableCopy;
        @weakify(self)
        _detailSheet.cancelViewBlock = ^{   // cancel block
            
//            [self restoreTransform];
        };
        _detailSheet.attributeBlock = ^(NSString *goodsId,NSString *wid) {
            @strongify(self)
            [self requesData:goodsId wid:wid];
        };
        
        _detailSheet.attributeNewBlock = ^(NSString *goodsId, NSString *wid, NSString *specialId) {
            @strongify(self)
            [self requesData:goodsId wid:wid specialId:specialId];
        };
        
        _detailSheet.addCartEventBlock = ^(BOOL flag) {
            
        };
        
        _detailSheet.attributeHadManualSelectSizeBlock = ^{
            //@strongify(self)
//            self.baseInfoModel.hadManualSelectSize = YES;
        };
        
        _detailSheet.goNewToDetailBlock = ^(NSString *goodsId, NSString *wid, NSString *specialId, NSString *goodsImageUrl) {
            @strongify(self)
            OSSVDetailsVC *detailVC = [[OSSVDetailsVC alloc] init];
            detailVC.goodsId = goodsId;
            detailVC.wid = wid;
            detailVC.specialId = specialId;
            detailVC.sourceType = STLAppsflyerGoodsSourceWishlist;
            detailVC.coverImageUrl = STLToString(goodsImageUrl);
            [self.controller.navigationController pushViewController:detailVC animated:YES];
            
            [self.detailSheet dismiss];
        };
    }
    return _detailSheet;
}
@end
