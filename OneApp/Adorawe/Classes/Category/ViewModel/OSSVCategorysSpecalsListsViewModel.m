//
//  OSSVCategorysSpecalsListsViewModel.m
// XStarlinkProject
//
//  Created by odd on 2020/9/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategorysSpecalsListsViewModel.h"
#import "OSSVCategorysSpecialListsAip.h"
#import "OSSVThemeZeroPrGoodsModel.h"
#import "OSSVCategorysSpecialssCCell.h"
#import "OSSVZeroCategorysSpecialsCCell.h"

#import "OSSVDetailsVC.h"
#import "OSSVCategorysNewZeroListAP.h"
#import "OSSVDetailsViewModel.h"
#import "STLActionSheet.h"

@interface OSSVCategorysSpecalsListsViewModel()

@property(nonatomic, assign) NSInteger curPage;
@property (nonatomic, strong) OSSVCategorysNewZeroListAP   *zeroListAnalyticsManager;
@property (nonatomic, strong) OSSVDetailsViewModel       *baseInfoModel;
@property (nonatomic, strong) STLActionSheet              *detailSheet;

@end

@implementation OSSVCategorysSpecalsListsViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.zeroListAnalyticsManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartRefreshAction:) name:kNotif_Cart object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)requestNetwork:(NSDictionary *)parmaters
            completion:(void (^)(id))completion
               failure:(void (^)(id))failure
{
    
    NSString *refreshOrLoadMore = (NSString *)[(NSDictionary *)parmaters objectForKey:@"refreshOrLoadmore"];
    if ([refreshOrLoadMore isEqualToString:STLRefresh]) {
        self.curPage = 1;
    }
    if ([refreshOrLoadMore isEqualToString:STLLoadMore]) {
        self.curPage ++ ;
    }

    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
//        OSSVCategorysSpecialListsAip *api = [[OSSVCategorysSpecialListsAip alloc] initCategorySpecial:STLToString(parmaters[@"specialId"])type:STLToString(parmaters[@"type"])];
        OSSVCategorysSpecialListsAip *api  = [[OSSVCategorysSpecialListsAip alloc] initWithCustomeId:STLToString(parmaters[@"specialId"]) type:STLToString(parmaters[@"type"]) page:self.curPage];
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSArray *tempArray = [self dataAnalysisFromJson: requestJSON request:api];
            if (self.curPage == 1){
                self.dataArray = [NSMutableArray arrayWithArray:tempArray];
            } else {
                [self.dataArray addObjectsFromArray:tempArray];
            }
            
            if (completion) {
                completion(self.dataArray);
            }
        }
                           failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
                               if (failure)
                               {
                                   failure(nil);
                               }
                           }];
    }
                                              exception:^{
                                                  if (failure)
                                                  {
                                                      failure(nil);
                                                  }
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];

                                              }];
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
            [self.controller.tabBarController.view addSubview:self.detailSheet];
            [UIView animateWithDuration: 0.25 animations: ^{
                [self.detailSheet shouAttribute];
                self.detailSheet.sourceType = STLAppsflyerGoodsSourceFlashList;
                self.detailSheet.type = GoodsDetailEnumTypeAdd;
            } completion: nil];
            
        }
    } failure:^(id obj) {
    }];
}

- (void)requesData:(NSString*)goodsId wid:(NSString*)wid withSpecialId:(NSString *)specialId{
    @weakify(self)
    NSDictionary *dic = dic = @{@"goods_id":STLToString(goodsId),
                                @"loadState":STLRefresh,
                                @"wid":STLToString(wid),
                                @"specialId":STLToString(specialId)};
    [self.baseInfoModel requestNetwork:dic completion:^(OSSVDetailsBaseInfoModel *obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            if (self.themeModel) {
                self.detailSheet.cart_exits = self.themeModel.cart_exists;
            }
            self.detailSheet.baseInfoModel = baseInfoModel;
            self.detailSheet.hadManualSelectSize = YES;
            if (STLIsEmptyString(baseInfoModel.specialId) && baseInfoModel.flash_sale && !STLIsEmptyString(baseInfoModel.flash_sale.active_discount) && [baseInfoModel.flash_sale.active_discount floatValue] > 0) {
                _detailSheet.hasFirtFlash = YES;
            }else{
                _detailSheet.hasFirtFlash = NO;
            }
            
            [self.detailSheet addCartAnimationTop:0 moveLocation:CGRectZero showAnimation:NO];
            [self.controller.tabBarController.view addSubview:self.detailSheet];
            [UIView animateWithDuration: 0.25 animations: ^{
                [self.detailSheet shouAttribute];
                self.detailSheet.sourceType = STLAppsflyerGoodsSourceFlashList;
                self.detailSheet.type = GoodsDetailEnumTypeAdd;
            } completion: nil];
            
        }
    } failure:^(id obj) {
    }];
}

#pragma mark - private methods

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request
{
    if ([request isKindOfClass:[OSSVCategorysSpecialListsAip class]]){
        if ([json[kStatusCode] integerValue] == kStatusCode_200){
            self.name = STLToString(json[kResult][@"name"]);
            self.themeModel = [OSSVHomeCThemeModel yy_modelWithDictionary:json[kResult]];
            return [NSArray yy_modelArrayWithClass:[OSSVThemeZeroPrGoodsModel class] json:json[kResult][@"goodsList"]];
        }
        else
        {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

- (void)setIsFromZeroYuan:(BOOL)isFromZeroYuan {
    _isFromZeroYuan = isFromZeroYuan;
    if (isFromZeroYuan) {
        self.zeroListAnalyticsManager.source = STLAppsflyerGoodsSourceZeroActivity;
    } else {
        self.zeroListAnalyticsManager.source = STLAppsflyerGoodsSourceThemeActivity;
    }

}

#pragma mark -- 0元购刷新界面
-(void)cartRefreshAction:(NSNotification *)noti{
    if (self.themeModel) {
        self.themeModel.cart_exists = 1;
        [self.controller refreshCollectionview];
    }
}


#pragma mark - UICollectionViewDelegate
//指定单元格的个数 ，这个是一个组里面有多少单元格，e.g : 一个单元格就是一张图片
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //为防万一，APP上拉加载的判断逻辑调整，由之前判定返回的数量<请求的数量即认为无更多商品，改为判断返回的数量=0。
    //    if (self.dataArray.count > kSTLPageSize - 1) {
    if (self.dataArray.count > 0) {
        collectionView.mj_footer.hidden = NO;
    } else {
        collectionView.mj_footer.hidden = YES;
    }
    return self.dataArray.count;
}

//构建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // banner
    if (self.themeModel.type == 12 || self.themeModel.type == 19) {
        OSSVZeroCategorysSpecialsCCell *cell = [OSSVZeroCategorysSpecialsCCell categorySpecialCCellWithCollectionView:collectionView andIndexPath:indexPath];
        cell.backgroundColor = OSSVThemesColors.col_FFFFFF;
        cell.cart_exits = self.themeModel.cart_exists;
        cell.model = self.dataArray[indexPath.row];
        cell.getFreeblock = ^(OSSVThemeZeroPrGoodsModel * _Nonnull zeroModel) {
            if (zeroModel.sold_out == 1) {
                return;
            }
            if (self.freeBtnblock) {
                self.freeBtnblock(zeroModel);
            }
        };
        return cell;
    }else{
        OSSVCategorysSpecialssCCell *cell = [OSSVCategorysSpecialssCCell categorySpecialCCellWithCollectionView:collectionView andIndexPath:indexPath];
        cell.backgroundColor = OSSVThemesColors.col_FFFFFF;
        cell.model = self.dataArray[indexPath.row];
        return cell;
    }
    
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.themeModel.type == 12 || self.themeModel.type == 19) {
        CGFloat w = collectionView.bounds.size.width - 16;
        return CGSizeMake(w, w*128/339);
    }else{
        
        OSSVThemeZeroPrGoodsModel *oneModel = self.dataArray[indexPath.row];
        OSSVThemeZeroPrGoodsModel *twoModel = nil;
        NSInteger count = indexPath.row % 2;
        if (count == 0) {
            if (self.dataArray.count > indexPath.row+1) {
                twoModel = self.dataArray[indexPath.row+1];
            }
        } else {
            if (indexPath.row > 0) {
                twoModel = self.dataArray[indexPath.row-1];
            }
        }
        
        CGFloat height = [OSSVCategorysSpecialssCCell categorySpecialCCellRowHeightOneModel:oneModel twoModel:twoModel];
        CGFloat w = kGoodsWidth;
        return CGSizeMake(w, height);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    OSSVThemeZeroPrGoodsModel *modelSoldOut = self.dataArray[indexPath.row];
    if (modelSoldOut.sold_out == 1) {
        return;
    }
    
    //不是从0元购专题进入
    if (!self.isFromZeroYuan) {
        OSSVThemeZeroPrGoodsModel *model = self.dataArray[indexPath.row];
        OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
        goodsDetailsVC.goodsId = model.goods_id;
        goodsDetailsVC.wid = model.wid;
        goodsDetailsVC.specialId = model.specialId;
        goodsDetailsVC.coverImageUrl = model.goods_img;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceThemeActivity;
        goodsDetailsVC.coverImageUrl = STLToString(model.goods_img);
        if (self.controller) {
            NSDictionary *dic = @{kAnalyticsAction          :[OSSVAnalyticsTool sensorsSourceStringWithType:STLAppsflyerGoodsSourceThemeActivity sourceID:@""],
                                  kAnalyticsUrl             :STLToString(self.controller.specialId),
                                  kAnalyticsKeyWord         :@"",
                                  kAnalyticsPositionNumber  :@(indexPath.row+1),
                                  
                                  
            };
            [goodsDetailsVC.transmitMutDic addEntriesFromDictionary:dic];
            [self.controller.navigationController pushViewController:goodsDetailsVC animated:YES];
        }
    } else {
        if (![OSSVAccountsManager sharedManager].isSignIn) {
            
            SignViewController *sign = [SignViewController new];
            sign.modalPresentationStyle = UIModalPresentationFullScreen;
            @weakify(self)
            //如果登录后自动执行，可以在block中填写代码
            sign.signBlock = ^{
                @strongify(self)
                OSSVThemeZeroPrGoodsModel *model = self.dataArray[indexPath.row];
                OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
                goodsDetailsVC.goodsId = model.goods_id;
                goodsDetailsVC.wid = model.wid;
                goodsDetailsVC.specialId = model.specialId;
                goodsDetailsVC.coverImageUrl = model.goods_img;
                goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceZeroActivity;
                goodsDetailsVC.coverImageUrl = STLToString(model.goods_img);

                if (self.controller) {
                    [self.controller.navigationController pushViewController:goodsDetailsVC animated:YES];
                }
            };
            [self.controller presentViewController:sign animated:YES completion:nil];
            
        } else {
            OSSVThemeZeroPrGoodsModel *model = self.dataArray[indexPath.row];
            OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
            goodsDetailsVC.goodsId = model.goods_id;
            goodsDetailsVC.wid = model.wid;
            goodsDetailsVC.specialId = model.specialId;
            goodsDetailsVC.coverImageUrl = model.goods_img;
            goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceZeroActivity;
            goodsDetailsVC.coverImageUrl = STLToString(model.goods_img);
            
            if (self.controller) {
                NSDictionary *dic = @{kAnalyticsAction          :[OSSVAnalyticsTool sensorsSourceStringWithType:STLAppsflyerGoodsSourceZeroActivity sourceID:@""],
                                      kAnalyticsUrl             :STLToString(self.controller.specialId),
                                      kAnalyticsKeyWord         :@"",
                                      kAnalyticsPositionNumber  :@(indexPath.row+1),
                                      
                                      
                };
                [goodsDetailsVC.transmitMutDic addEntriesFromDictionary:dic];
                [self.controller.navigationController pushViewController:goodsDetailsVC animated:YES];
            }
        }

    }
    
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
        make.top.mas_equalTo(customView.mas_top).offset(52 * DSCREEN_HEIGHT_SCALE);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];

    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = OSSVThemesColors.col_333333;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = STLLocalizedString_(@"load_failed", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [customView addSubview:titleLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(36);
        make.width.mas_equalTo(SCREEN_WIDTH - 30);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [OSSVThemesColors col_262626];
    button.titleLabel.font = [UIFont stl_buttonFont:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (APP_TYPE == 3) {
        [button setTitle:STLLocalizedString_(@"retry", nil) forState:UIControlStateNormal];
    } else {
        [button setTitle:STLLocalizedString_(@"retry", nil).uppercaseString forState:UIControlStateNormal];
    }
    /**
        emptyOperationTouch
        emptyJumpOperationTouch
        暂时两个动态选择
     */
    [button addTarget:self action:@selector(emptyOperationTouch) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [customView addSubview:button];

    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(33);
        make.centerX.mas_equalTo(customView.mas_centerX);
        make.width.mas_equalTo(@180);
        make.height.mas_equalTo(@40);
    }];
    return customView;
}

- (void)setAnalyticDic:(NSMutableDictionary *)analyticDic {
    _analyticDic = analyticDic;
    self.zeroListAnalyticsManager.sourecDic = analyticDic;
}

- (OSSVCategorysNewZeroListAP *)zeroListAnalyticsManager {
    if (!_zeroListAnalyticsManager) {
        _zeroListAnalyticsManager = [[OSSVCategorysNewZeroListAP alloc] init];
        _zeroListAnalyticsManager.source = STLAppsflyerGoodsSourceZeroActivity;
    }
    return _zeroListAnalyticsManager;
}

- (OSSVDetailsViewModel *)baseInfoModel {
    if (!_baseInfoModel) {
        _baseInfoModel = [[OSSVDetailsViewModel alloc] init];
    }
    return _baseInfoModel;
}

- (STLActionSheet *)detailSheet {
    if (!_detailSheet) {
        CGFloat detailSheetY = kIS_IPHONEX? 88.f : 64.f;
        _detailSheet = [[STLActionSheet alloc] initWithFrame:CGRectMake(0, -detailSheetY, SCREEN_WIDTH, SCREEN_HEIGHT+detailSheetY)];
        _detailSheet.type = GoodsDetailEnumTypeAdd;
//        _detailSheet.hasFirtFlash = YES;
        _detailSheet.isListSheet = YES;
        _detailSheet.addCartType = 1;
        _detailSheet.showCollectButton = YES;
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
            [self requesData:goodsId wid:wid withSpecialId:specialId];
        };
        
        _detailSheet.addCartEventBlock = ^(BOOL flag) {
            
        };
        
        _detailSheet.attributeHadManualSelectSizeBlock = ^{
            @strongify(self)
//            self.baseInfoModel.hadManualSelectSize = YES;
        };
        
        _detailSheet.goNewToDetailBlock = ^(NSString *goodsId, NSString *wid, NSString *specialId, NSString *goodsImageUrl) {
            @strongify(self)
            OSSVDetailsVC *detailVC = [[OSSVDetailsVC alloc] init];
            detailVC.goodsId = goodsId;
            detailVC.wid = wid;
            detailVC.specialId = specialId;
            detailVC.sourceType = STLAppsflyerGoodsSourceZeroActivity;
            detailVC.coverImageUrl = STLToString(goodsImageUrl);
            [self.controller.navigationController pushViewController:detailVC animated:YES];
            
            [self.detailSheet dismiss];
        };
    }
    return _detailSheet;
}

@end
