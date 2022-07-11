//
//  OSSVProductListCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVProductListCellModel.h"
#import "OSSVCartWareHouseModel.h"

@implementation OSSVProductListCellModel
@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.productList = [[NSMutableArray alloc] init];
        self.showSeparatorStyle = NO;
    }
    return self;
}

#pragma mark - protocol

+(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

#pragma mark - setter and getter

-(void)setDataSourceModel:(NSObject *)dataSourceModel{
    _dataSourceModel = dataSourceModel;
    
    if ([_dataSourceModel isKindOfClass:[OSSVCartWareHouseModel class]]) {
        OSSVCartWareHouseModel *wareHouseModel = (OSSVCartWareHouseModel *)_dataSourceModel;
        if ([wareHouseModel.goodsList count]) {
            [wareHouseModel.goodsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OSSVCartGoodsModel *goodsModel = obj;
                [self.productList addObject:goodsModel];
            }];
        }
    }
}

@end
