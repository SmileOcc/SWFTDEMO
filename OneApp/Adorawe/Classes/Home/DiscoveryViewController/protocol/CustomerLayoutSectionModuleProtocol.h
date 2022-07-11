//
//  CustomerLayoutSectionModuleProtocol.h
//  TestCollectionView
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OSSVCustomMathTool.h"
#import "CollectionCellModelProtocol.h"
#import "OSSVDiscoverBlocksModel.h"
static NSString * const CustomerLayoutHeader = @"CustomerLayoutHeader";
static NSString * const CustomerLayoutFooter = @"CustomerLayoutFooter";

///布局底部对齐方式
typedef NS_ENUM(NSInteger) {
    AlignBottom_Horizontal,
    AlignBottom_Waterfail
}AlignBottom;

@protocol CustomerLayoutSectionModuleProtocol <NSObject>

///section 的底部最小间距
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

///数据源
@property (nonatomic, strong) NSMutableArray <id<CollectionCellModelProtocol>>*sectionDataList;
@property (nonatomic, strong) OSSVDiscoverBlocksModel *discoverBlockModel;

@optional;

-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section;

-(CGFloat)rowsNumInSection;

-(CGFloat)sectionBottom;

@end
