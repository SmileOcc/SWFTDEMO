//
//  ZFCollectionSectionProtocol.h
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCollectionCellDatasourceProtocol.h"
#import <UIKit/UIKit.h>

static NSString * const CustomerLayoutHeader = @"CustomerLayoutHeader";
static NSString * const CustomerLayoutFooter = @"CustomerLayoutFooter";

@protocol ZFCollectionSectionProtocol <NSObject>

@property (nonatomic, strong) NSMutableArray <id<ZFCollectionCellDatasourceProtocol>> *sectionDataSource;
@property (nonatomic, strong) NSMutableArray *registerKeys;

-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section;

-(CGFloat)sectionBottom;

@optional;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
//一行几个
@property (nonatomic, assign) NSInteger lineRows;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
-(UICollectionViewLayoutAttributes *)headerFooterKind:(NSString *)kind bottomOffset:(CGFloat)bottomOffset section:(NSUInteger)section;

@end

