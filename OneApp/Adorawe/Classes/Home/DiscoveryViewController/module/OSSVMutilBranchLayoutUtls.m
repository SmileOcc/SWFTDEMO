//
//  OSSVMutilBranchLayoutUtls.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMutilBranchLayoutUtls.h"

#define TopHeight (44 * DSCREEN_WIDTH_375_SCALE)

@implementation OSSVMutilBranchLayoutUtls

+(NSArray <UICollectionViewLayoutAttributes *> *)moreBranchLayout:(MoreBranchLayout)layout section:(CGFloat)section bottomOffset:(CGFloat)bottomOffset
{
    NSArray *attributesList = [[NSArray alloc] init];
    BOOL rightToLeft = [OSSVSystemsConfigsUtils isRightToLeftShow];
    switch (layout) {
        case MoreBranchLayout_One:
            attributesList = [OSSVMutilBranchLayoutUtls oneBranchLayout:layout section:section bottomOffset:bottomOffset];
            break;
        case MoreBranchLayout_Two:
            attributesList = [OSSVMutilBranchLayoutUtls twoBranchLayout:layout section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
            break;
        case MoreBranchLayout_Three:
            attributesList = [OSSVMutilBranchLayoutUtls threeBranchLayout:layout section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
            break;
        case MoreBranchLayout_Four:
            attributesList = [OSSVMutilBranchLayoutUtls fourBranchLayout:layout section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
            break;
        case MoreBranchLayout_Five:
            attributesList = [OSSVMutilBranchLayoutUtls fiveBranchLayout:layout section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
            break;
        case MoreBranchLayout_Eight:
            attributesList = [OSSVMutilBranchLayoutUtls eightBranchLayout:layout section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
            break;
        case MoreBranchLayout_Sixteen:
            attributesList = [OSSVMutilBranchLayoutUtls sixteenBranchLayout:layout section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
            break;
        default:
            break;
    }
    return attributesList;
}


+(NSArray <UICollectionViewLayoutAttributes *> *)newMoreBranchLayout:(OSSVDiscoverBlocksModel *)blockModel section:(CGFloat)section bottomOffset:(CGFloat)bottomOffset {
    
    NSArray *attributesList = [[NSArray alloc] init];
    if (blockModel) {
        BOOL rightToLeft = [OSSVSystemsConfigsUtils isRightToLeftShow];
        NSInteger layout = [blockModel.type integerValue];
        switch (layout) {
            case 1:
                attributesList = [OSSVMutilBranchLayoutUtls newOneBranchLayout:blockModel section:section bottomOffset:bottomOffset];
                break;
            case 2:
                attributesList = [OSSVMutilBranchLayoutUtls newTwoBranchLayout:blockModel section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
                break;
            case 3:
                attributesList = [OSSVMutilBranchLayoutUtls newThreeBranchLayout:blockModel section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
                break;
            case 301:
                attributesList = [OSSVMutilBranchLayoutUtls newThree301BranchLayout:blockModel section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
                break;
            case 4:
                attributesList = [OSSVMutilBranchLayoutUtls newFourBranchLayout:blockModel section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
                break;
            case 5:
                attributesList = [OSSVMutilBranchLayoutUtls newFiveBranchLayout:blockModel section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
                break;
            case 8:
                attributesList = [OSSVMutilBranchLayoutUtls newEightBranchLayout:blockModel section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
                break;
            case 16:
                attributesList = [OSSVMutilBranchLayoutUtls newSixteenBranchLayout:blockModel section:section bottomOffset:bottomOffset rightToLeft:rightToLeft];
                break;
            default:
                break;
        }
    }
    
    return attributesList;
}

//一分馆布局代码
+(NSArray <UICollectionViewLayoutAttributes *> *)oneBranchLayout:(MoreBranchLayout)laytou
                                                         section:(CGFloat)section
                                                    bottomOffset:(CGFloat)bottomOffset
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    topAttributes.frame = CGRectMake(0, bottomOffset, SCREEN_WIDTH, STLFloatToLastOne(TopHeight));
    
    UICollectionViewLayoutAttributes *bottomAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:section]];
    CGFloat topBottom = CGRectGetMaxY(topAttributes.frame);
    bottomAttributes.frame = CGRectMake(0, topBottom, SCREEN_WIDTH, STLFloatToLastOne(SCREEN_WIDTH * 188.0 / 375.0));
    
    [attributesList addObjectsFromArray:@[topAttributes, bottomAttributes]];
    
    return [attributesList copy];
}


//一分馆布局代码--new
+(NSArray <UICollectionViewLayoutAttributes *> *)newOneBranchLayout:(OSSVDiscoverBlocksModel *)blockModel
                                                         section:(CGFloat)section
                                                    bottomOffset:(CGFloat)bottomOffset
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    CGFloat currentBottomOffset = bottomOffset;
    NSInteger row = 0;
    
    if (blockModel.banner) {
        if (!STLIsEmptyString(blockModel.banner.imageURL) && [blockModel.banner.width floatValue] > 0 && [blockModel.banner.height floatValue] > 0) {
            
            CGFloat height = STLFloatToLastOne(SCREEN_WIDTH * [blockModel.banner.height floatValue] / [blockModel.banner.width floatValue]);
            UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            topAttributes.frame = CGRectMake(0, currentBottomOffset, SCREEN_WIDTH, height);
            currentBottomOffset = CGRectGetMaxY(topAttributes.frame);
            [attributesList addObject:topAttributes];
            row++;
        }
    } else if(blockModel.specialModelBanner) {//原生专题优惠券
        if (!STLIsEmptyString(blockModel.specialModelBanner.images) && [blockModel.specialModelBanner.imagesWidth floatValue] > 0 && [blockModel.specialModelBanner.imagesHeight floatValue] > 0) {
            
            CGFloat height = STLFloatToLastOne(SCREEN_WIDTH * [blockModel.specialModelBanner.imagesHeight floatValue] / [blockModel.specialModelBanner.imagesWidth floatValue]);
            UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            topAttributes.frame = CGRectMake(0, currentBottomOffset, SCREEN_WIDTH, height);
            currentBottomOffset = CGRectGetMaxY(topAttributes.frame);
            [attributesList addObject:topAttributes];
            row++;
        }
    }

    if (blockModel.images.count > 0) {
        OSSVAdvsEventsModel *advModel = blockModel.images.firstObject;
        CGFloat advWidth = [advModel.width floatValue];
        CGFloat advHeight = [advModel.height floatValue];
        if (advWidth > 0) {
            advHeight = SCREEN_WIDTH * advHeight / advWidth;
        }
        UICollectionViewLayoutAttributes *bottomAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        bottomAttributes.frame = CGRectMake(0, currentBottomOffset, SCREEN_WIDTH, STLFloatToLastOne(advHeight));
        [attributesList addObject:bottomAttributes];
    }
    
    
    
    return [attributesList copy];
}

//二分馆布局代码
+(NSArray <UICollectionViewLayoutAttributes *> *)twoBranchLayout:(MoreBranchLayout)laytou
                                                         section:(CGFloat)section
                                                    bottomOffset:(CGFloat)bottomOffset
                                                     rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    topAttributes.frame = CGRectMake(0, bottomOffset, SCREEN_WIDTH, floor(TopHeight));
    
    CGFloat width = SCREEN_WIDTH / 2;
    
    CGFloat x = 0;
    
    if (rightToLeft) {
        x = SCREEN_WIDTH - width;
    }
    
    UICollectionViewLayoutAttributes *bottomLeftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:section]];
    CGFloat topBottom = CGRectGetMaxY(topAttributes.frame);
    bottomLeftAttributes.frame = CGRectMake(x, topBottom, width, STLFloatToLastOne(width * 238.0 / 187.0));
    
    UICollectionViewLayoutAttributes *bottomRightAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:section]];
    CGFloat bottmRight = CGRectGetMaxX(bottomLeftAttributes.frame);
    if (rightToLeft) {
        bottmRight = SCREEN_WIDTH - CGRectGetMinX(bottomLeftAttributes.frame) - width;
    }
    bottomRightAttributes.frame = CGRectMake(bottmRight, topBottom, width, STLFloatToLastOne(width * 238.0 / 187.0));
    
    [attributesList addObjectsFromArray:@[topAttributes, bottomLeftAttributes, bottomRightAttributes]];
    
    return [attributesList copy];
}

//二分馆布局代码---new
+(NSArray <UICollectionViewLayoutAttributes *> *)newTwoBranchLayout:(OSSVDiscoverBlocksModel *)blockModel
                                                         section:(CGFloat)section
                                                    bottomOffset:(CGFloat)bottomOffset
                                                     rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    
    CGFloat currentBottomOffset = bottomOffset;
    NSInteger row = 0;
    if (!STLIsEmptyString(blockModel.banner.imageURL) && [blockModel.banner.width floatValue] > 0 && [blockModel.banner.height floatValue] > 0) {
        
        CGFloat height = STLFloatToLastOne(SCREEN_WIDTH * [blockModel.banner.height floatValue] / [blockModel.banner.width floatValue]);

        UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        topAttributes.frame = CGRectMake(0, currentBottomOffset, SCREEN_WIDTH, height);
        currentBottomOffset = CGRectGetMaxY(topAttributes.frame);
        [attributesList addObject:topAttributes];
        row++;
    }
    
    
    CGFloat width = SCREEN_WIDTH / 2;
    CGFloat height = 0;
    
    if (blockModel.images.count > 0) {
        OSSVAdvsEventsModel *firstAdv = blockModel.images.firstObject;
        CGFloat advWidth = [firstAdv.width floatValue];
        CGFloat advHeight = [firstAdv.height floatValue];
        if (advWidth > 0) {
            height = width * advHeight / advWidth;
        }
    }

    CGFloat x = 0;
    
    if (rightToLeft) {
        x = SCREEN_WIDTH - width;
    }
    
    UICollectionViewLayoutAttributes *bottomLeftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    bottomLeftAttributes.frame = CGRectMake(x, currentBottomOffset, width, STLFloatToLastOne(height));
    
    UICollectionViewLayoutAttributes *bottomRightAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row+1 inSection:section]];
    CGFloat bottmRight = CGRectGetMaxX(bottomLeftAttributes.frame);
    if (rightToLeft) {
        bottmRight = SCREEN_WIDTH - CGRectGetMinX(bottomLeftAttributes.frame) - width;
    }
    bottomRightAttributes.frame = CGRectMake(bottmRight, currentBottomOffset, width,STLFloatToLastOne(height));
    
    [attributesList addObjectsFromArray:@[bottomLeftAttributes, bottomRightAttributes]];
    
    return [attributesList copy];
}

///三分管布局代码
+(NSArray <UICollectionViewLayoutAttributes *> *)threeBranchLayout:(MoreBranchLayout)laytou
                                                           section:(CGFloat)section
                                                      bottomOffset:(CGFloat)bottomOffset
                                                       rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    topAttributes.frame = CGRectMake(0, bottomOffset, SCREEN_WIDTH, floor(TopHeight));
    [attributesList addObject:topAttributes];
    
    CGFloat width = STLFloatToLastOne(SCREEN_WIDTH / 3);
    CGFloat height = STLFloatToLastOne(width * 167.0 / 125.0);

    CGFloat lastWidth = SCREEN_WIDTH - 2 * width;
    
    for (int i = 0; i < 3; i++) {
        UICollectionViewLayoutAttributes *bottomLeftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:section]];
        CGFloat topBottom = CGRectGetMaxY(topAttributes.frame);
        CGFloat x = i * width;
        
        CGFloat tempWidth = i < 2 ? width : lastWidth;
        if (rightToLeft) {
            x = SCREEN_WIDTH - x - tempWidth;
        }
        bottomLeftAttributes.frame = CGRectMake(x, topBottom, tempWidth, height);
        [attributesList addObject:bottomLeftAttributes];
    }

    return [attributesList copy];
}

+(NSArray <UICollectionViewLayoutAttributes *> *)newThreeBranchLayout:(OSSVDiscoverBlocksModel *)blockModel
                                                           section:(CGFloat)section
                                                      bottomOffset:(CGFloat)bottomOffset
                                                       rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    CGFloat currentBottomOffset = bottomOffset;
    
    NSInteger row = 0;
    if (!STLIsEmptyString(blockModel.banner.imageURL) && [blockModel.banner.width floatValue] > 0 && [blockModel.banner.height floatValue] > 0) {
        
        CGFloat height = STLFloatToLastOne(SCREEN_WIDTH * [blockModel.banner.height floatValue] / [blockModel.banner.width floatValue]);

        UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        topAttributes.frame = CGRectMake(0, currentBottomOffset, SCREEN_WIDTH, height);
        [attributesList addObject:topAttributes];
        [attributesList addObject:topAttributes];

        currentBottomOffset = CGRectGetMaxY(topAttributes.frame);
        row++;
    }
    
    CGFloat width = STLFloatToLastOne(SCREEN_WIDTH / 3.0);
    CGFloat height = STLFloatToLastOne(width * 167.0 / 125.0);
    CGFloat lastWidth = SCREEN_WIDTH - 2 * width;

    for (int i = 0; i < 3; i++) {
        UICollectionViewLayoutAttributes *bottomLeftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i+row inSection:section]];
        CGFloat x = i * width;
        
        CGFloat tempWidth = i < 2 ? width : lastWidth;
        if (rightToLeft) {
            x = SCREEN_WIDTH - x - tempWidth;
        }
        bottomLeftAttributes.frame = CGRectMake(x, currentBottomOffset, tempWidth, height);
        [attributesList addObject:bottomLeftAttributes];
    }

    return [attributesList copy];
}

+(NSArray <UICollectionViewLayoutAttributes *> *)newThree301BranchLayout:(OSSVDiscoverBlocksModel *)blockModel
                                                           section:(CGFloat)section
                                                      bottomOffset:(CGFloat)bottomOffset
                                                       rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    CGFloat currentBottomOffset = bottomOffset;
    
    NSInteger row = 0;
    if (!STLIsEmptyString(blockModel.banner.imageURL) && [blockModel.banner.width floatValue] > 0 && [blockModel.banner.height floatValue] > 0) {
        
        CGFloat height = STLFloatToLastOne(SCREEN_WIDTH * [blockModel.banner.height floatValue] / [blockModel.banner.width floatValue]);
        
        UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        topAttributes.frame = CGRectMake(0, currentBottomOffset, SCREEN_WIDTH, height);
        [attributesList addObject:topAttributes];
        
        currentBottomOffset = CGRectGetMaxY(topAttributes.frame);
        row++;
    }
    
    CGFloat leftBannerH = 0;
    CGFloat leftBannerW =  STLFloatToLastOne(SCREEN_WIDTH * 175.0 / 375.0);
    CGFloat secondBannerW = SCREEN_WIDTH - leftBannerW;
    CGFloat secondRightTopBannerH = 0;
    
    if (blockModel.images.count > 2) {
        OSSVAdvsEventsModel *leftAdv = blockModel.images.firstObject;
        CGFloat advWidth = [leftAdv.width floatValue];
        CGFloat advHeight = [leftAdv.height floatValue];
        if (advWidth > 0) {
            leftBannerH = STLFloatToLastOne(leftBannerW * advHeight / advWidth);
        }
        
        OSSVAdvsEventsModel *topRightAdv = blockModel.images[1];
        CGFloat topRightAdvWidth = [topRightAdv.width floatValue];
        CGFloat topRightAdvHeight = [topRightAdv.height floatValue];
        if (topRightAdvWidth > 0) {
            secondRightTopBannerH = STLFloatToLastOne(secondBannerW * topRightAdvHeight / topRightAdvWidth);
            
            if (secondRightTopBannerH > leftBannerH) {
                secondRightTopBannerH = leftBannerH;
            }
        }
    }
    
    
    CGFloat rightTopBottomOffset = 0;
    for (int i = 0; i < 3; i++) {
        UICollectionViewLayoutAttributes *bottomLeftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i+row inSection:section]];
        CGFloat x = 0;
        if (i == 0) {
            if (rightToLeft) {
                x = SCREEN_WIDTH - leftBannerW;
            }
            bottomLeftAttributes.frame = CGRectMake(x, currentBottomOffset, leftBannerW, leftBannerH);
            [attributesList addObject:bottomLeftAttributes];
        } else if(i == 1) {
            x = leftBannerW;
            if (rightToLeft) {
                x = SCREEN_WIDTH - x - secondBannerW;
            }
            bottomLeftAttributes.frame = CGRectMake(x, currentBottomOffset, secondBannerW, secondRightTopBannerH);
            [attributesList addObject:bottomLeftAttributes];
            
            rightTopBottomOffset = CGRectGetMaxY(bottomLeftAttributes.frame);
        } else if(i == 2) {
            x = leftBannerW;
            if (rightToLeft) {
                x = SCREEN_WIDTH -x - secondBannerW;
            }
            bottomLeftAttributes.frame = CGRectMake(x, rightTopBottomOffset, secondBannerW, leftBannerH - secondRightTopBannerH);
            [attributesList addObject:bottomLeftAttributes];
        }
    }

    return [attributesList copy];
}


///四分管布局代码
+(NSArray <UICollectionViewLayoutAttributes *> *)fourBranchLayout:(MoreBranchLayout)laytou
                                                          section:(CGFloat)section
                                                     bottomOffset:(CGFloat)bottomOffset
                                                      rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    //多分管头部栏广告
    CGFloat contentW = SCREEN_WIDTH;
    UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    topAttributes.frame = CGRectMake(0, bottomOffset, contentW, floor(contentW * 52.0 / 375.0));
    [attributesList addObject:topAttributes];
    
    
    //左上角
    CGFloat topBottom = CGRectGetMaxY(topAttributes.frame);
    CGFloat width = contentW / 2.0;
    CGFloat height = floor(175 * DSCREEN_WIDTH_SCALE);
    
    CGFloat x = 0;
    if (rightToLeft) {
        x = SCREEN_WIDTH - x - width;
    }
    UICollectionViewLayoutAttributes *leftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:section]];
    leftAttributes.frame = CGRectMake(x, topBottom, width, height);
    [attributesList addObject:leftAttributes];
    
    CGFloat leftRight = CGRectGetMaxX(leftAttributes.frame);
    if (rightToLeft) {
        leftRight = SCREEN_WIDTH - CGRectGetMinX(leftAttributes.frame) - width;
    }
    
    //右上角
    UICollectionViewLayoutAttributes *rightTopAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:section]];
    rightTopAttributes.frame = CGRectMake(leftRight, topBottom, width, height);
    [attributesList addObject:rightTopAttributes];
    
    CGFloat topLeftBottom = CGRectGetMaxY(leftAttributes.frame);
    CGFloat rightBottomHeight = floor(width * 90 / 168.0);
    
    //左下角
    UICollectionViewLayoutAttributes *rightBottomLeftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:3 inSection:section]];
    rightBottomLeftAttributes.frame = CGRectMake(x, topLeftBottom, width, rightBottomHeight);
    [attributesList addObject:rightBottomLeftAttributes];
    
    //右下角
    UICollectionViewLayoutAttributes *rightBottomRightAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:4 inSection:section]];
    rightBottomRightAttributes.frame = CGRectMake(leftRight, topLeftBottom, width, rightBottomHeight);
    [attributesList addObject:rightBottomRightAttributes];
    
    
    return [attributesList copy];
}

+(NSArray <UICollectionViewLayoutAttributes *> *)newFourBranchLayout:(OSSVDiscoverBlocksModel *)blockModel
                                                          section:(CGFloat)section
                                                     bottomOffset:(CGFloat)bottomOffset
                                                      rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    //多分管头部栏广告
    CGFloat contentW = SCREEN_WIDTH;
    
    CGFloat currentBottomOffset = bottomOffset;
    NSInteger row = 0;
    if (!STLIsEmptyString(blockModel.banner.imageURL) && [blockModel.banner.width floatValue] > 0 && [blockModel.banner.height floatValue] > 0) {
        
        CGFloat height = STLFloatToLastOne(contentW * [blockModel.banner.height floatValue] / [blockModel.banner.width floatValue]);
        
        UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        topAttributes.frame = CGRectMake(0, bottomOffset, contentW, height);
        [attributesList addObject:topAttributes];
        currentBottomOffset = CGRectGetMaxY(topAttributes.frame);
        row++;
    }
    
    
    //左上角
    CGFloat width = contentW / 2.0;
    CGFloat height = STLFloatToLastOne(175 * DSCREEN_WIDTH_SCALE);
    
    CGFloat x = 0;
    if (rightToLeft) {
        x = SCREEN_WIDTH - x - width;
    }
    UICollectionViewLayoutAttributes *leftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    leftAttributes.frame = CGRectMake(x, currentBottomOffset, width, height);
    [attributesList addObject:leftAttributes];
    
    CGFloat leftRight = CGRectGetMaxX(leftAttributes.frame);
    if (rightToLeft) {
        leftRight = SCREEN_WIDTH - CGRectGetMinX(leftAttributes.frame) - width;
    }
    
    //右上角
    UICollectionViewLayoutAttributes *rightTopAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row+1 inSection:section]];
    rightTopAttributes.frame = CGRectMake(leftRight, currentBottomOffset, width, height);
    [attributesList addObject:rightTopAttributes];
    
    CGFloat topLeftBottom = CGRectGetMaxY(leftAttributes.frame);
    CGFloat rightBottomHeight = STLFloatToLastOne(width * 90 / 168.0);
    
    //左下角
    UICollectionViewLayoutAttributes *rightBottomLeftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row+2 inSection:section]];
    rightBottomLeftAttributes.frame = CGRectMake(x, topLeftBottom, width, rightBottomHeight);
    [attributesList addObject:rightBottomLeftAttributes];
    
    //右下角
    UICollectionViewLayoutAttributes *rightBottomRightAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row+3 inSection:section]];
    rightBottomRightAttributes.frame = CGRectMake(leftRight, topLeftBottom, width, rightBottomHeight);
    [attributesList addObject:rightBottomRightAttributes];
    
    
    return [attributesList copy];
}

///五分馆布局代码
+(NSArray <UICollectionViewLayoutAttributes *> *)fiveBranchLayout:(MoreBranchLayout)laytou
                                                          section:(CGFloat)section
                                                     bottomOffset:(CGFloat)bottomOffset
                                                      rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    topAttributes.frame = CGRectMake(0, bottomOffset, SCREEN_WIDTH, floor(TopHeight));
    [attributesList addObject:topAttributes];
    
    CGFloat topBottom = CGRectGetMaxY(topAttributes.frame);
    CGFloat firstWidth = STLFloatToLastOne(175 * DSCREEN_WIDTH_375_SCALE);
    CGFloat firstHeight = STLFloatToLastOne(firstWidth * 200.0 / 175.0);
    
    CGFloat x = 0;
    if (rightToLeft) {
        x = SCREEN_WIDTH - firstWidth;
    }
    
    UICollectionViewLayoutAttributes *leftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:section]];
    leftAttributes.frame = CGRectMake(x, topBottom, firstWidth, firstHeight);
    [attributesList addObject:leftAttributes];
    
    
    //处理精度问题
    CGFloat rightWidth = floor((SCREEN_WIDTH - firstWidth) / 2);
    CGFloat rightSecondWidth = SCREEN_WIDTH - firstWidth - rightWidth;
    
    CGFloat rightHeight = floor(firstHeight / 2.0);
    CGFloat rightRowHeight = firstHeight - rightHeight;
    
    CGFloat leftRight = CGRectGetMaxX(leftAttributes.frame);
    
    for (int i = 0; i < 4; i++) {
        UICollectionViewLayoutAttributes *rightAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i + 2 inSection:section]];
        CGFloat x = 0;
        if (rightToLeft) {
            x = SCREEN_WIDTH - firstWidth - rightSecondWidth * (i % 2) - rightWidth;
        }else{
            x = leftRight + rightWidth * (i % 2);
        }
        
        CGFloat rightContentW = i % 2 == 0 ? rightWidth : rightSecondWidth;
        CGFloat rightContentH = i < 2 ? rightHeight : rightRowHeight;
        rightAttributes.frame = CGRectMake(x, topBottom + (rightHeight * (i/2)), rightContentW, rightContentH);
        [attributesList addObject:rightAttributes];
    }
    
    return [attributesList copy];
}

///五分馆布局代码--new
+(NSArray <UICollectionViewLayoutAttributes *> *)newFiveBranchLayout:(OSSVDiscoverBlocksModel *)blockModel
                                                          section:(CGFloat)section
                                                     bottomOffset:(CGFloat)bottomOffset
                                                      rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    CGFloat currentBottomOffset = bottomOffset;
    NSInteger row = 0;
    if (!STLIsEmptyString(blockModel.banner.imageURL) && [blockModel.banner.width floatValue] > 0 && [blockModel.banner.height floatValue] > 0) {
        
        CGFloat height = STLFloatToLastOne(SCREEN_WIDTH * [blockModel.banner.height floatValue] / [blockModel.banner.width floatValue]);
        UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        topAttributes.frame = CGRectMake(0, bottomOffset, SCREEN_WIDTH, height);
        [attributesList addObject:topAttributes];
        
        currentBottomOffset = CGRectGetMaxY(topAttributes.frame);
        row++;
    }
    
    
    CGFloat firstWidth = STLFloatToLastOne(175 * DSCREEN_WIDTH_375_SCALE);
    CGFloat firstHeight = STLFloatToLastOne(firstWidth * 200.0 / 175.0);
    
    CGFloat x = 0;
    if (rightToLeft) {
        x = SCREEN_WIDTH - firstWidth;
    }
    
    
    UICollectionViewLayoutAttributes *leftAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    leftAttributes.frame = CGRectMake(x, currentBottomOffset, firstWidth, firstHeight);
    [attributesList addObject:leftAttributes];
    
    //处理精度问题
    CGFloat rightWidth = STLFloatToLastOne((SCREEN_WIDTH - firstWidth) / 2);
    CGFloat rightSecondWidth = SCREEN_WIDTH - firstWidth - rightWidth;

    CGFloat rightHeight = STLFloatToLastOne(firstHeight / 2.0);
    CGFloat rightRowHeight = firstHeight - rightHeight;
    
    CGFloat leftRight = CGRectGetMaxX(leftAttributes.frame);
    
    for (int i = 0; i < 4; i++) {
        UICollectionViewLayoutAttributes *rightAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i + row + 1 inSection:section]];
        CGFloat x = 0;
        if (rightToLeft) {
            x = SCREEN_WIDTH - firstWidth - rightSecondWidth * (i % 2) - rightWidth;
        }else{
            x = leftRight + rightWidth * (i % 2);
        }
        CGFloat rightContentW = i % 2 == 0 ? rightWidth : rightSecondWidth;
        CGFloat rightContentH = i < 2 ? rightHeight : rightRowHeight;
        rightAttributes.frame = CGRectMake(x, currentBottomOffset + (rightHeight * (i/2)), rightContentW, rightContentH);
        [attributesList addObject:rightAttributes];
    }
    
    return [attributesList copy];
}

///八分馆布局代码
+(NSArray <UICollectionViewLayoutAttributes *> *)eightBranchLayout:(MoreBranchLayout)laytou
                                                           section:(CGFloat)section
                                                      bottomOffset:(CGFloat)bottomOffset
                                                       rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    CGFloat contentW = SCREEN_WIDTH;
    
    UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    topAttributes.frame = CGRectMake(0, bottomOffset, contentW, floor(contentW * 72.0 / 750.0));
    [attributesList addObject:topAttributes];
    
    int columnRows = 2;
    
    CGFloat topBottom = CGRectGetMaxY(topAttributes.frame);
    CGFloat width = contentW / columnRows;
    CGFloat height = floor(width * 60.0 / 163.0);
    
    for (int i = 0; i < 8; i++) {
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i + 1 inSection:section]];
        CGFloat x = (i % columnRows) * width;
        if (rightToLeft) {
            x = SCREEN_WIDTH - x - width;
        }
        CGFloat row = i / columnRows;
        
        attributes.frame = CGRectMake(x, topBottom + row * height, width, height);

        [attributesList addObject:attributes];
    }
    
    
    return [attributesList copy];
}

///八分馆布局代码----New
+(NSArray <UICollectionViewLayoutAttributes *> *)newEightBranchLayout:(OSSVDiscoverBlocksModel *)blockModel
                                                           section:(CGFloat)section
                                                      bottomOffset:(CGFloat)bottomOffset
                                                       rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    CGFloat contentW = SCREEN_WIDTH;
    
    CGFloat currentBottomOffset = bottomOffset;
    NSInteger row = 0;
    if (!STLIsEmptyString(blockModel.banner.imageURL) && [blockModel.banner.width floatValue] > 0 && [blockModel.banner.height floatValue] > 0) {
        
        CGFloat height = STLFloatToLastOne(SCREEN_WIDTH * [blockModel.banner.height floatValue] / [blockModel.banner.width floatValue]);
        UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        topAttributes.frame = CGRectMake(0, bottomOffset, contentW, height);
        [attributesList addObject:topAttributes];
        
        currentBottomOffset = CGRectGetMaxY(topAttributes.frame);
        row++;
    }
    

    int columnRows = 2;
    CGFloat width = STLFloatToLastOne(contentW / columnRows);
    CGFloat height = STLFloatToLastOne(width * 60.0 / 163.0);
    
    for (int i = 0; i < 8; i++) {
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i + row inSection:section]];
        CGFloat x = (i % columnRows) * width;
        
        NSInteger last = i + 1;
        CGFloat currentW = width;
        if (last % columnRows == 0) {
            currentW = SCREEN_WIDTH - width;
        }
        
        if (rightToLeft) {
            x = SCREEN_WIDTH - x - currentW;
        }
        CGFloat row = i / columnRows;
        
        attributes.frame = CGRectMake(x, currentBottomOffset + row * height, width, height);

        [attributesList addObject:attributes];
    }
    
    
    return [attributesList copy];
}

///十六分馆布局代码
+(NSArray <UICollectionViewLayoutAttributes *> *)sixteenBranchLayout:(MoreBranchLayout)laytou
                                                             section:(CGFloat)section
                                                        bottomOffset:(CGFloat)bottomOffset
                                                         rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    topAttributes.frame = CGRectMake(0, bottomOffset, SCREEN_WIDTH, floor(TopHeight));
    [attributesList addObject:topAttributes];
    
    int columnRows = 4;
    
    CGFloat topBottom = CGRectGetMaxY(topAttributes.frame);
    CGFloat width = STLFloatToLastOne((SCREEN_WIDTH / columnRows));
    CGFloat scale = (86.0 / 93.0);  //由UI给的比例
    CGFloat height = floor(width * scale);
    
    CGFloat bottomAttOffset = 0;
    for (int i = 0; i < 8; i++) {
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i + 1 inSection:section]];
        CGFloat x = (i % columnRows) * width;
        if (rightToLeft) {
            x = SCREEN_WIDTH - x - width;
        }
        attributes.frame = CGRectMake(x,topBottom + (i / columnRows) * height, width, height);
        bottomAttOffset = CGRectGetMaxY(attributes.frame);
        [attributesList addObject:attributes];
    }
    
    UICollectionViewLayoutAttributes *bottomAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:9 inSection:section]];
    bottomAttributes.frame = CGRectMake(0, bottomAttOffset, SCREEN_WIDTH, STLFloatToLastOne(TopHeight));
    [attributesList addObject:bottomAttributes];
    
    return [attributesList copy];
}

///十六分馆布局代码
+(NSArray <UICollectionViewLayoutAttributes *> *)newSixteenBranchLayout:(OSSVDiscoverBlocksModel *)blockModel
                                                             section:(CGFloat)section
                                                        bottomOffset:(CGFloat)bottomOffset
                                                         rightToLeft:(BOOL)rightToLeft
{
    NSMutableArray *attributesList = [[NSMutableArray alloc] init];
    
    CGFloat currentBottomOffset = bottomOffset;
    NSInteger row = 0;
    if (!STLIsEmptyString(blockModel.banner.imageURL) && [blockModel.banner.width floatValue] > 0 && [blockModel.banner.height floatValue] > 0) {
        
        CGFloat height = STLFloatToLastOne(SCREEN_WIDTH * [blockModel.banner.height floatValue] / [blockModel.banner.width floatValue]);

        UICollectionViewLayoutAttributes *topAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        topAttributes.frame = CGRectMake(0, bottomOffset, SCREEN_WIDTH, height);
        [attributesList addObject:topAttributes];
        
        currentBottomOffset = CGRectGetMaxY(topAttributes.frame);
        row++;
    }
    
    if (blockModel.images.count > 0) {
        
        int columnRows = 4;
        
        CGFloat width = STLFloatToLastOne((SCREEN_WIDTH / columnRows));
        //CGFloat scale = (86.0 / 93.0);  //由UI给的比例
        //CGFloat height = (width * scale);
        CGFloat currentMoreHeight = 0;
        
        for (int i = 0; i < blockModel.images.count; i++) {
            
            if (i % columnRows == 0) {
                currentBottomOffset += currentMoreHeight;
                currentMoreHeight = 0;
                NSInteger currentStartCount = i;
                NSInteger latCount = blockModel.images.count - currentStartCount;
                NSInteger timesCount = latCount >= columnRows ? columnRows : latCount;
                
                for (NSInteger j=currentStartCount; j<(currentStartCount + timesCount); j++) {
                    
                    OSSVAdvsEventsModel *advModel = blockModel.images[j];
                    if ([advModel.width floatValue] > 0) {
                        CGFloat tempH = STLFloatToLastOne([advModel.height floatValue] * width / [advModel.width floatValue]);
                        if (tempH >= currentMoreHeight) {
                            currentMoreHeight = tempH;
                        }
                    }
                    
                }
            }
            
            
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i + row inSection:section]];
            
            
            CGFloat x = (i % columnRows) * width;

            NSInteger last = i + 1;
            CGFloat currentW = width;
            if (last % columnRows == 0) {
                currentW = SCREEN_WIDTH - 3 * width;
            }

            if (rightToLeft) {
                x = SCREEN_WIDTH - x - currentW;
            }
            attributes.frame = CGRectMake(x,currentBottomOffset, currentW, currentMoreHeight);
            [attributesList addObject:attributes];
        }
    }
    
    return [attributesList copy];
}

@end
