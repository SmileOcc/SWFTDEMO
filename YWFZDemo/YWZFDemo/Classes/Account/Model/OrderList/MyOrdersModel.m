//
//  MyOrdersModel.m
//  Yoshop
//
//  Created by YW on 16/6/7.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "MyOrdersModel.h"

@interface MyOrdersModel ()

@property (nonatomic, assign, readwrite) NSInteger totalCount;
@property (nonatomic, assign, readwrite) NSInteger leaveCount;
@end

@implementation MyOrdersModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hacker_point = [ZFHackerPointOrderModel new];
        self.totalCount = 1;
        self.leaveCount = 0;
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{
             @"shipping_fee" : @"ship_price"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"goods" : [MyOrderGoodListModel class],
             @"hacker_point" : [ZFHackerPointOrderModel class]
             };
}

-(void)setGoods:(NSArray<MyOrderGoodListModel *> *)goods
{
    _goods = goods;
    
    __block NSInteger leaveCount = 0;
    __block NSInteger count = 0;
    [_goods enumerateObjectsUsingBlock:^(MyOrderGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        count += [obj.goods_number integerValue];
        if (idx < 3) {
            leaveCount += [obj.goods_number integerValue];
        }
    }];
    leaveCount = count - leaveCount;
    
    self.totalCount = count;
    self.leaveCount = leaveCount;
}


- (NSArray<ZFBaseOrderGoodsModel *> *)baseGoodsList
{
    return self.goods;
}

@end
