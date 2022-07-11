//
//  OSSVDetailsHeaderScrollverAdvView.m
// XStarlinkProject
//
//  Created by odd on 2020/12/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVDetailsHeaderScrollverAdvView.h"
#import "STLPageCircleControlView.h"
#import "OSSVDetailBannerAdvAnalyticsAOP.h"

@interface OSSVDetailsHeaderScrollverAdvView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView          *collectionView;
@property (nonatomic, strong) STLPageCircleControlView  *circleControlView;
@property (nonatomic, strong) OSSVDetailBannerAdvAnalyticsAOP    *analyticsAop;

@end

@implementation OSSVDetailsHeaderScrollverAdvView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.analyticsAop];

        self.backgroundColor = [OSSVThemesColors col_F5F5F5];
        self.advBanners = @[];
        [self addSubview:self.collectionView];
        [self addSubview:self.circleControlView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self);
            make.top.mas_equalTo(0);
        }];
        
        [self.circleControlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        }];

    }
    return self;
}

- (OSSVDetailBannerAdvAnalyticsAOP *)analyticsAop {
    if (!_analyticsAop) {
        _analyticsAop = [[OSSVDetailBannerAdvAnalyticsAOP alloc] init];
    }
    return _analyticsAop;
}


//+ (CGFloat)heightGoodsScrollerAdvView:(NSArray<OSSVAdvsEventsModel *> *)advBanners {
//
//    __block CGFloat h = 0;
//    if (STLJudgeNSArray(advBanners)) {
//
//        [advBanners enumerateObjectsUsingBlock:^(OSSVAdvsEventsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj.width floatValue] > 0) {
//                CGFloat tempH = (SCREEN_WIDTH - 12*2) * [obj.height floatValue] / [obj.width floatValue];
//                if (tempH > h) {
//                    h = tempH;
//                }
//            }
//        }];
//
//        if(h > 0) {
//            h += 8; //间隙
//        }
//    }
//
//    return h;
//}

- (void)setGoodsInforModel:(OSSVDetailsBaseInfoModel *)goodsInforModel {
    _goodsInforModel = goodsInforModel;
    self.analyticsAop.anyObject = STLToString(goodsInforModel.goods_sn);
}
- (void)setAdvBanners:(NSArray<OSSVAdvsEventsModel *> *)advBanners {
    _advBanners = advBanners;
    if (!STLJudgeNSArray(advBanners)) {
        _advBanners = @[];
    }
    
    if (APP_TYPE == 3) {
        [self.circleControlView updateDotHighColor:[OSSVThemesColors col_000000:0.3] defaultColor:[OSSVThemesColors col_000000:1.0] counts:self.advBanners.count currentIndex:0];
    } else {
        [self.circleControlView updateDotHighColor:[OSSVThemesColors col_ffffff:1.0] defaultColor:[OSSVThemesColors col_ffffff:0.5] counts:self.advBanners.count currentIndex:0];
    }
   
    [self.collectionView reloadData];
    
    self.circleControlView.hidden = YES;
    if (_advBanners.count > 1) {
        self.circleControlView.hidden = NO;
    }
}



#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.advBanners.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsHeaderScrollerItemCCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GoodsHeaderScrollerItemCCell class]) forIndexPath:indexPath];
    
    if (self.advBanners.count > indexPath.row) {
        OSSVAdvsEventsModel *advModel = self.advBanners[indexPath.row];
        imageCell.model = advModel;
        [imageCell.imgView yy_setImageWithURL:[NSURL URLWithString:STLToString(advModel.imageURL)]
                                  placeholder:[UIImage imageNamed:@"placeholder_banner_pdf"]
                                      options:kNilOptions
                                     progress:nil
                                    transform:nil
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        }];
    }
        
    
    return imageCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(SCREEN_WIDTH-2*12, CGRectGetHeight(self.collectionView.frame));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.advBanners.count > indexPath.row) {
        OSSVAdvsEventsModel *advEventModel = self.advBanners[indexPath.row];
        
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                          @"attr_node_1":@"other",
                                          @"attr_node_2":@"goods_banner",
                                          @"attr_node_3":@"",
                                          @"position_number":@(indexPath.row+1),
                                          @"venue_position":@(0),
                                          @"action_type":@([advEventModel advActionType]),
                                          @"url":[advEventModel advActionUrl],
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
        
        //数据GA埋点曝光 广告点击
                            
                            // item
                            NSMutableDictionary *item = [@{
                        //          kFIRParameterItemID: $itemId,
                        //          kFIRParameterItemName: $itemName,
                        //          kFIRParameterItemCategory: $itemCategory,
                        //          kFIRParameterItemVariant: $itemVariant,
                        //          kFIRParameterItemBrand: $itemBrand,
                        //          kFIRParameterPrice: $price,
                        //          kFIRParameterCurrency: $currency
                            } mutableCopy];


                            // Prepare promotion parameters
                            NSMutableDictionary *promoParams = [@{
                        //          kFIRParameterPromotionID: $promotionId,
                        //          kFIRParameterPromotionName:$promotionName,
                        //          kFIRParameterCreativeName: $creativeName,
                        //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                        //          @"screen_group":@"Home"
                            } mutableCopy];

                            // Add items
                            promoParams[kFIRParameterItems] = @[item];
                            
                        //        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
        
        if (self.advBlock && !STLIsEmptyString(advEventModel.bannerId)) {
            self.advBlock(advEventModel);
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
       NSInteger arIndex = scrollView.contentOffset.x / (SCREEN_WIDTH -2*12);
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            arIndex = self.advBanners.count - arIndex - 1;
        }
        [self.circleControlView selectIndex:arIndex];
    }
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.pagingEnabled = YES;
        
        [_collectionView registerClass:[GoodsHeaderScrollerItemCCell class] forCellWithReuseIdentifier:NSStringFromClass([GoodsHeaderScrollerItemCCell class])];
    }
    return _collectionView;
}

- (STLPageCircleControlView *)circleControlView {
    if (!_circleControlView) {
        _circleControlView = [[STLPageCircleControlView alloc] initWithFrame:CGRectZero];
        [_circleControlView configeMaxWidth:8 minWidth:8 maxHeight:8 minHeight:8 limitCorner:4.0 space:8];
    }
    return _circleControlView;
}

@end



@implementation GoodsHeaderScrollerItemCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imgView];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.contentView);
        }];
    }
    return self;
}

- (YYAnimatedImageView *)imgView {
    if (!_imgView) {
        _imgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}

@end
