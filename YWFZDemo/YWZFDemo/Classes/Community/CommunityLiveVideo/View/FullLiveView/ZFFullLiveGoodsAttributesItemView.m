//
//  ZFFullLiveGoodsAttributesItemView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveGoodsAttributesItemView.h"
#import "ZFProgressHUD.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFBranchAnalytics.h"

@interface ZFFullLiveGoodsAttributesItemView()

@property (nonatomic, strong) ZFGoodsDetailViewModel            *goodsDetailViewModel;

@end

@implementation ZFFullLiveGoodsAttributesItemView


- (void)dealloc {
    YWLog(@"ZFFullLiveGoodsAttributesItemView dealloc");
    if (_goodsDetailViewModel) {
        [_goodsDetailViewModel cancelAllDataTask];
    }
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = ZFCClearColor();
        [self addSubview:self.attributeView];
        
        [self.attributeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(8);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.top.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
    }
    return self;
}


- (void)zfWillViewAppear {
    if (!self.attributeView.model && self.attributeView.refreshButton.isHidden) {
        
        [self.attributeView changeCartNumberInfo];
        [self refreshRequestData:self.attributeView.firstGoodsId];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.attributeView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];

}

- (NSString *)currentGuideSizeUrl {
    return ZFToString(self.attributeView.model.size_url);
}

- (NSString *)currentGoodsId {
    if (self.attributeView.model) {
        return ZFToString(self.attributeView.model.goods_id);
    }
    return ZFToString(self.goodsModel.goods_id);
}

- (void)setRecommendGoodsId:(NSString *)recommendGoodsId {
    _recommendGoodsId = recommendGoodsId;
    
    if (self.attributeView.model) {
        self.attributeView.recommendGoodsId = ZFToString(recommendGoodsId);
        
    } else {
        self.attributeView.recommendGoodsId = ZFToString(recommendGoodsId);
        [self.attributeView changeCartNumberInfo];
        [self refreshRequestData:self.attributeView.firstGoodsId];
    }
}

- (void)setGoodsModel:(ZFGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    self.attributeView.firstGoodsId = ZFToString(goodsModel.goods_id);
}
- (ZFLiveGoodsAttributeView *)attributeView {
    if (!_attributeView) {
        NSString *bagTitle = ZFLocalizedString(@"Detail_Product_AddToBag", nil);
        _attributeView = [[ZFLiveGoodsAttributeView alloc] initSelectSizeView:YES bottomBtnTitle:bagTitle];
        
        @weakify(self)
        _attributeView.refreshBlock = ^{
            @strongify(self)
            if (!ZFIsEmptyString(self.attributeView.model.goods_id)) {
                [self refreshRequestData:self.attributeView.model.goods_id];
            } else {
                [self refreshRequestData:self.attributeView.firstGoodsId];
            }
        };
        
        _attributeView.addCartBlock = ^(NSString * _Nonnull goodsId, NSInteger count) {
            @strongify(self)
            [self addGoodsToCartOption:goodsId goodsCount:count];
        };
        
        _attributeView.cartBlock = ^{
            @strongify(self)
            if (self.goCartBlock) {
                self.goCartBlock();
            }
        };
        
        _attributeView.liveGoodsAttributeTypeBlock = ^(NSString * _Nonnull goodsId) {
            @strongify(self)
            [self refreshRequestData:goodsId];
        };
        
        _attributeView.liveGoodsAttributeSizeGuideBlock = ^(NSString * _Nonnull url) {
            @strongify(self)
            if (self.guideSizeBlock) {
                self.guideSizeBlock(url);
            }
        };
        
        _attributeView.commentBlock = ^(GoodsDetailModel * _Nonnull model) {
            @strongify(self)
            if (self.commentBlock) {
                self.commentBlock(self.attributeView.model);
            }
        };
        
    }
    return _attributeView;
}


- (void)refreshRequestData:(NSString *)goodsId {
    
    @weakify(self)
    [self requestGoodsDetailInfo:ZFToString(goodsId) successBlock:^(GoodsDetailModel *goodsDetailInfo) {
        @strongify(self)
        [self reviewCommnets:goodsDetailInfo];
        [self addToBagBeforeViewProduct:goodsDetailInfo];
    }];
    
}

- (void)reviewCommnets:(GoodsDetailModel *)goodsDetailInfo {
    
    @weakify(self)
    [self.goodsDetailViewModel requestGoodsReviewsPort:goodsDetailInfo completion:^(GoodsDetailsReviewsModel *reviewsModel) {
        @strongify(self)
        
        self.attributeView.reviewAllCounts = reviewsModel.reviewCount;
    }];
}

- (void)addToBagBeforeViewProduct:(GoodsDetailModel *)detailModel {
    
    //用户点击查看商品
    NSMutableDictionary *valuesDic     = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId]   = ZFToString(detailModel.goods_sn);
    valuesDic[AFEventParamContentType] = @"product";
    valuesDic[AFEventParamPrice]       = ZFToString(detailModel.shop_price);
    valuesDic[AFEventParamCurrency]    = @"USD";
    valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeZMeLiveDetail sourceID:ZFToString(self.liveId)];
    valuesDic[@"af_changed_size_or_color"] = @"1";
    valuesDic[BigDataParams]           = [detailModel gainAnalyticsParams];
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_view_product" withValues:valuesDic];
    [ZFGrowingIOAnalytics ZFGrowingIOProductDetailShow:detailModel];
}

#pragma mark - 获取商品详情

/**
 获取商品详情
 */
- (void)requestGoodsDetailInfo:(NSString *)goodsId successBlock:(void(^)(GoodsDetailModel *goodsDetailInfo))successBlock{
    
    NSDictionary *dict = @{@"goods_id"    : ZFToString(goodsId)};
    
    if(!self.goodsDetailViewModel) {
        self.goodsDetailViewModel = [[ZFGoodsDetailViewModel alloc] init];
        self.goodsDetailViewModel.isNotShowError = YES;
    }
    
    [self.attributeView showLoadActivityView:YES];
    self.userInteractionEnabled = NO;
    
    @weakify(self);
    [self.goodsDetailViewModel requestGoodsDetailData:dict completion:^(GoodsDetailModel *detaidlModel) {
        @strongify(self);
        
        self.userInteractionEnabled = YES;
        [self.attributeView showLoadActivityView:NO];

        if (detaidlModel.detailMainPortSuccess && [detaidlModel isKindOfClass:[GoodsDetailModel class]]) {
            self.attributeView.model = detaidlModel;
            [self.attributeView.collectionView reloadData];
            self.attributeView.refreshButton.hidden = YES;
            if (successBlock) {
                successBlock(detaidlModel);
            }
        }
    } failure:^(NSError *error) {
        @strongify(self)
        self.userInteractionEnabled = YES;
        [self.attributeView showLoadActivityView:NO];
        if (!self.attributeView.model) {
            self.attributeView.refreshButton.hidden = NO;
        }
    }];
}

//添加购物车
- (void)addGoodsToCartOption:(NSString *)goodsId goodsCount:(NSInteger)goodsCount {
    
    if (!self.attributeView.model) {
        return;
    }
    
    [self.attributeView bottomCartViewEnable:YES];
    @weakify(self);
    [self.goodsDetailViewModel requestAddToCart:ZFToString(goodsId) loadingView:self goodsNum:goodsCount completion:^(BOOL isSuccess) {
        @strongify(self);
        
        if (isSuccess) {
//            [self startAddCartSuccessAnimation];
            [self changeCartNumAction];
            
            //添加商品至购物车事件统计
            self.attributeView.model.buyNumbers = goodsCount;
            NSString *goodsSN = self.attributeView.model.goods_sn;
            NSString *spuSN = @"";
            if (goodsSN.length > 7) {  // sn的前7位为同款id
                spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
            }else{
                spuSN = goodsSN;
            }
            
            NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
            valuesDic[AFEventParamContentId] = ZFToString(goodsSN);
            valuesDic[@"af_spu_id"] = ZFToString(spuSN);
            valuesDic[AFEventParamPrice] = ZFToString(self.attributeView.model.shop_price);
            valuesDic[AFEventParamQuantity] = [NSString stringWithFormat:@"%zd",goodsCount];
            valuesDic[AFEventParamContentType] = @"product";
            valuesDic[@"af_content_category"] = ZFToString(self.attributeView.model.long_cat_name);
            valuesDic[AFEventParamCurrency] = @"USD";
            valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeZMeLiveDetail sourceID:ZFToString(self.liveId)];
            
            valuesDic[@"af_changed_size_or_color"] = (goodsCount > 0) ? @"1" : @"0";
            if (self.attributeView.model) {
                valuesDic[BigDataParams]           = @[[self.attributeView.model gainAnalyticsParams]];
            }
            valuesDic[@"af_purchase_way"]      = @"1";//V5.0.0增加, 判断是否为一键购买(0)还是正常加购(1)
            [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
            //Branch
            if (self.attributeView.model) {
                [[ZFBranchAnalytics sharedManager] branchAddToCartWithProduct:self.attributeView.model number:goodsCount];
                [ZFFireBaseAnalytics addToCartWithGoodsModel:self.attributeView.model];
                [ZFGrowingIOAnalytics ZFGrowingIOAddCart:self.attributeView.model];
            }
            
        } else {
            [self changeCartNumAction];
        }
        [self.attributeView bottomCartViewEnable:YES];
    }];
}

- (void)changeCartNumAction {
    [self.attributeView changeCartNumberInfo];
}

@end
