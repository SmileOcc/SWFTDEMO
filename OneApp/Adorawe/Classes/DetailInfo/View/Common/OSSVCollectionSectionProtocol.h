//
//  OSSVCollectionSectionProtocol.h
// XStarlinkProject
//
//  Created by odd on 2021/4/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVCollectionCellDatasourceProtocol.h"


typedef NS_ENUM(NSInteger, STLGoodsDetailSectionType) {
    STLGoodsDetailSectionTypeDefault = 0,
    STLGoodsDetailSectionTypeGoodsInfo,
    STLGoodsDetailSectionTypeAcitvity,
    STLGoodsDetailSectionTypeService,
    STLGoodsDetailSectionTypeSizeDesc,
    STLGoodsDetailSectionTypeReviewNew,
    STLGoodsDetailSectionTypeReviewStar,
    STLGoodsDetailSectionTypeReview,
    STLGoodsDetailSectionTypeReviewViewAll,
    STLGoodsDetailSectionTypeAdvertizeView,
    STLGoodsDetailSectionTypeRecommendHeader,
    STLGoodsDetailSectionTypeRecommend,
};

static NSString * const DetailCustomerLayoutHeader = @"DetailCustomerLayoutHeader";
static NSString * const DetailCustomerLayoutFooter = @"DetailCustomerLayoutFooter";


@protocol OSSVCollectionSectionProtocol <NSObject>

//@property (nonatomic, strong) NSMutableArray <id<OSSVCollectionCellDatasourceProtocol>> *sectionDataSource;
@property (nonatomic, strong) NSMutableArray <id> *sectionDataSource;
@property (nonatomic, strong) NSMutableArray *registerKeys;

-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section;

-(CGFloat)sectionBottom;

//临时商品详情用的，用时判断一下
-(CGFloat)sectionTop;

@optional;
@property (nonatomic, assign) STLGoodsDetailSectionType sectionType;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
//一行几个
@property (nonatomic, assign) NSInteger lineRows;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
-(UICollectionViewLayoutAttributes *)headerFooterKind:(NSString *)kind bottomOffset:(CGFloat)bottomOffset section:(NSUInteger)section;

@end
