//
//  OSSVCustThemePrGoodsListCacheModel.m
// OSSVCustThemePrGoodsListCacheModel
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCustThemePrGoodsListCacheModel.h"
#import "OSSVCustomThemesChannelsGoodsAip.h"
#import "OSSVHomeCThemeModel.h"
#import "OSSVProGoodsCCellModel.h"

@interface OSSVCustThemePrGoodsListCacheModel ()
@property (nonatomic, strong) NSMutableArray <OSSVBasesRequests *>*operations;
@end

@implementation OSSVCustThemePrGoodsListCacheModel

-(void)dealloc
{
    for (int i = 9; i < [self.operations count]; i++) {
        OSSVBasesRequests *request = self.operations[i];
        [request stop];
    }
    [self.operations removeAllObjects];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageIndex = 0;
        self.operations = [[NSMutableArray alloc] init];
    }
    return self;
}
#pragma mark --- 分页调用接口， 新的专题页商品请求不用这个方法了
-(void)pageOnThePullRequestCustomeId:(NSString *)customeId complation:(void(^)(NSInteger index, NSArray *result))complation
{
    OSSVCustomThemesChannelsGoodsAip *api = [[OSSVCustomThemesChannelsGoodsAip alloc] initWithCustomeId:customeId sort:self.sort page:self.pageIndex + 1];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        //拿到数据，拼接，然后保存到customProductListCache缓存
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
            NSArray *goodsList = [NSArray yy_modelArrayWithClass:[STLHomeCGoodsModel class] json:requestJSON[kResult][@"goodsList"]];
            NSInteger count = [goodsList count];
            if (count) {
                NSMutableArray *resultList = [[NSMutableArray alloc] init];
                for (int i = 0; i < [goodsList count]; i++) {
                    OSSVProGoodsCCellModel *proCellModel = [[OSSVProGoodsCCellModel alloc] init];
                    proCellModel.dataSource = goodsList[i];
                    [self.cacheList addObject:proCellModel];
                    [resultList addObject:proCellModel];
                }
                self.pageIndex += 1;
                self.footStatus = FooterRefrestStatus_Show;
                if (complation) {
                    complation(self.index, resultList);
                }
                return;
            }else{
                self.footStatus = FooterRefrestStatus_NoMore;
            }
        }
        if (complation) {
            complation(self.index, @[]);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (complation) {
            complation(self.index, @[]);
        }
    }];
    [self.operations addObject:api];
}


@end
