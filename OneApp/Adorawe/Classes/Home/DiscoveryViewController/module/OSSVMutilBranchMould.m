//
//  OSSVMutilBranchMould.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMutilBranchMould.h"
#import "OSSVMutilBranchLayoutUtls.h"

@interface OSSVMutilBranchMould ()

@property (nonatomic, assign) CGFloat bottomOffset;

@end

@implementation OSSVMutilBranchMould

@synthesize minimumInteritemSpacing = _minimumInteritemSpacing;
@synthesize sectionDataList = _sectionDataList;
@synthesize discoverBlockModel = _discoverBlockModel;

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.sectionDataList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section
{
    NSInteger rows = [self rowsNumInSection];

    if (self.isNewBranch) {
        
        NSArray *attributesList = [OSSVMutilBranchLayoutUtls newMoreBranchLayout:self.discoverBlockModel section:section bottomOffset:bottomoffset];
        
        UICollectionViewLayoutAttributes *attribute = [attributesList lastObject];
        self.bottomOffset = floorf(CGRectGetMaxY(attribute.frame));
        
        return attributesList;
    }
    NSArray *attributesList = [OSSVMutilBranchLayoutUtls moreBranchLayout:rows section:section bottomOffset:bottomoffset];
    
    UICollectionViewLayoutAttributes *attribute = [attributesList lastObject];
    self.bottomOffset = floorf(CGRectGetMaxY(attribute.frame));
    
    return attributesList;
}

-(CGFloat)rowsNumInSection
{
    return [self.sectionDataList count];
}

-(CGFloat)sectionBottom
{
    return self.bottomOffset + self.minimumInteritemSpacing;
}

@end
