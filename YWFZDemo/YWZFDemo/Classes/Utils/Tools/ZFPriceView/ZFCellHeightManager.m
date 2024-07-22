//
//  ZFCellHeightManager.m
//  ZZZZZ
//
//  Created by YW on 27/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCellHeightManager.h"
#import "ZFGoodsTagModel.h"
#import "ZFCellHeightModel.h"
#import "ZFFrameDefiner.h"
#import "AccountManager.h"
#import "NSString+Extended.h"

@interface ZFCellHeightManager ()
@property (strong, nonatomic, readonly) NSCache *cache;
@end

@implementation ZFCellHeightManager

+ (instancetype)shareManager {
    static ZFCellHeightManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager defaultConfigure];
    });
    return manager;
}

- (void)defaultConfigure {
    NSCache *cache = [NSCache new];
    cache.name = @"ZFGoodsCellHeight.cache";
    cache.countLimit = 500;
    _cache = cache;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: cache=%@",
            [self class], self.cache];
}

- (void)clearCaches {
    [self.cache removeAllObjects];
}

- (void)saveModel:(ZFCellHeightModel *)model withModelHash:(NSUInteger)hash {
    NSAssert(model.cellHeight >= 0, @"cell height must greater than or equal to 0");
    [self.cache setObject:model forKey:@(hash)];
}

- (CGFloat)queryHeightWithModelHash:(NSUInteger)hash {
    ZFCellHeightModel *model = [self.cache objectForKey:@(hash)];
    CGFloat cellHeigh = model.cellHeight;
    if (cellHeigh) {
        return cellHeigh;
    } else {
        return -1;
    }
}

- (BOOL)isNewLineWithModelHash:(NSUInteger)hash  {
    ZFCellHeightModel *model = [self.cache objectForKey:@(hash)];
    return model.isNewLine;
}

- (CGFloat)calculateCellHeightWithTagsArrayModel:(ZFGoodsModel *)goodsModel
{
    CGFloat cellMargin              = 12.0f + 12.0f + 12.0f;
    CGFloat cellWidth               = (KScreenWidth - cellMargin) / 2;
    CGFloat cellHeight              = 0.0f;
    
    CGFloat imageHeight             = cellWidth / KImage_SCALE;
    CGFloat imageTagMargin          = 12.0f;
    
    CGFloat priceTagMargin          = 8.0f;
    CGFloat priceHeight             = 19.0f;
    
    BOOL wrap = [goodsModel handleRRPPrice];
    BOOL showMark = [goodsModel showMarketPrice];
    if (wrap && showMark) {
        priceHeight = 40.f;
    }
    
    CGFloat bottomMargin            = 24.0f;
    CGFloat labelInsetMargin        = 8.0f;
    
    CGFloat tagVerticalMargin       = 2.0f;
    CGFloat tagHorizontalMargin     = 4.0f;
    CGFloat tagHeight               = 16.0f;
    CGFloat tagWidth                = 0.0f;
    
    ZFCellHeightModel *heigthModel = [[ZFCellHeightModel alloc] init];
    
    NSArray *tagsArray = goodsModel.tagsArray;
    
    // 1.判断是否要显示tag
    if (tagsArray.count > 0) {
        
        cellHeight = imageHeight + imageTagMargin + priceTagMargin + priceHeight + bottomMargin;
        
        if (self.isRecomendCell) {
            cellHeight += tagHeight;
            heigthModel.isNewLine = NO;
        }else{
            // 判断宽度
            for (ZFGoodsTagModel *tagModel in tagsArray) {
                tagWidth += [self calculateTitleSizeWithString:tagModel.tagTitle].width + labelInsetMargin;
                tagWidth += (tagsArray.count - 1) * tagHorizontalMargin;
            }
            if (tagWidth > cellWidth) { // 换行 2行tag
                cellHeight += (tagHeight * 2) + tagVerticalMargin;
                heigthModel.isNewLine = YES;
            }else { // 1 行tag
                cellHeight += tagHeight;
                heigthModel.isNewLine = NO;
            }
        }
        heigthModel.cellHeight = ceil(cellHeight);
        [self saveModel:heigthModel withModelHash:goodsModel.goods_id.hash];
        return ceil(cellHeight);
    }
    
    // 2.不显示tag
    cellHeight = imageHeight + imageTagMargin + priceHeight + bottomMargin;
    heigthModel.isNewLine = NO;
    heigthModel.cellHeight = ceil(cellHeight);
    [self saveModel:heigthModel withModelHash:goodsModel.goods_id.hash];
    return ceil(cellHeight);
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string {
    CGFloat fontSize = 10.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 20)  options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}


@end

