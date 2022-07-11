//
//  OSSVScrollViewMould.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVScrollViewMould.h"

///设计给的图片尺寸
#define LabelTopBottomPadding 15
#define ProductImageWidth (ceilf(SCREEN_WIDTH / 3.2) - 5 * 4)
#define ProductImageHeight ceilf(ProductImageWidth * (133.0 / 100.0))
#define LabelPadding 6
#define PriceLabelHeight 12
#define MarketPriceLabelHeight 9
#define ProductCollectionHeight (ProductImageHeight + LabelTopBottomPadding + PriceLabelHeight + LabelPadding + MarketPriceLabelHeight + LabelTopBottomPadding + 5)

@interface OSSVScrollViewMould ()

@property (nonatomic, assign) CGFloat bottomOffset;
@property (nonatomic, assign) ScrollerType type;

@end

@implementation OSSVScrollViewMould
@synthesize minimumInteritemSpacing = _minimumInteritemSpacing;
@synthesize sectionDataList = _sectionDataList;
@synthesize discoverBlockModel = _discoverBlockModel;

-(instancetype)initWithType:(ScrollerType)type
{
    self = [super init];
    
    if (self) {
        self.sectionDataList = [[NSMutableArray alloc] init];
        self.type = type;
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.sectionDataList = [[NSMutableArray alloc] init];
        self.type = ScrollerType_Scroller;
    }
    return self;
}

-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section
{
    NSInteger rows = [self rowsNumInSection];
    
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:rows];
    
    CGFloat screenWidth = SCREEN_WIDTH;
    CGFloat height = floor(SCREEN_WIDTH*(130.0/750.0));
    
    id<CollectionCellModelProtocol>model = self.sectionDataList[0];
    CGSize firstCustomerSize = [model customerSize];
    if (!CGSizeEqualToSize(CGSizeZero, firstCustomerSize)) {
        height = firstCustomerSize.height;
    }

    UICollectionViewLayoutAttributes *firstAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    firstAttributes.frame = CGRectMake(0, bottomoffset, screenWidth, height);
    
    [attributeList addObject:firstAttributes];
    
    CGFloat firstBottom = CGRectGetMaxY(firstAttributes.frame);
    CGFloat countDownBottom = firstBottom;
    NSInteger bottomIndex = 1;
    if (self.type == ScrollerType_CountDown) {//倒计时
        bottomIndex = 2;
        UICollectionViewLayoutAttributes *countDownAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:section]];
        countDownAttributes.frame = CGRectMake(0, firstBottom, firstAttributes.frame.size.width, 55);
        countDownBottom = CGRectGetMaxY(countDownAttributes.frame);
        [attributeList addObject:countDownAttributes];
    }
    
    UICollectionViewLayoutAttributes *secondAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:bottomIndex inSection:section]];
  
    secondAttributes.frame = CGRectMake(0, countDownBottom, firstAttributes.frame.size.width, floor(ProductCollectionHeight));
    
    if (_type == ScrollerType_Cart) {
        secondAttributes.frame = CGRectMake(0, countDownBottom, firstAttributes.frame.size.width, 100);
    }
 
    [attributeList addObject:secondAttributes];
    
    self.bottomOffset = CGRectGetMaxY(secondAttributes.frame);
    
    return [attributeList copy];
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
