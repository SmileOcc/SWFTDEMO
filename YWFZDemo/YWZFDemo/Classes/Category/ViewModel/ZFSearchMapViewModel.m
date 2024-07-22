//
//  ZFSearchMapViewModel.m
//  ZZZZZ
//
//  Created by YW on 8/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchMapViewModel.h"
#import "ZFSearchImageModel.h"
#import "ZFSearchMetaModel.h"
#import "ZFSearchMapModel.h"
#import "ZFGoodsModel.h"
#import "YWLocalHostManager.h"
#import "NSArray+SafeAccess.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "ZFBTSManager.h"
#import "AFNetworking.h"
#import "NSStringUtils.h"

@interface ZFSearchMapViewModel()
@property (nonatomic, strong) NSMutableArray<ZFSearchMapModel *>   *categoryArray;
@property (nonatomic, strong) NSMutableArray<ZFGoodsModel *>       *goodsArray;
@end

@implementation ZFSearchMapViewModel

/**
 * 分类页面以图搜图入口
 */
- (NSURLSessionDataTask *)requestSearchSDKWithImage:(UIImage *)sourceImage
                                  searchImagePolicy:(NSString *)searchImagePolicy
                                         completion:(void (^)(BOOL isSuccess))completion
{
    if (![searchImagePolicy isEqualToString:kZFBts_A]) { //内部识图
        return [self requestSearchZZZZZDiscriminatImage:sourceImage
                                      searchImagePolicy:searchImagePolicy
                                             completion:completion];
    }
    
    NSData *imageData = [self compressImage:sourceImage];
    if (![imageData isKindOfClass:[NSData class]]) {
        if (completion) {
            completion(NO);
        }
        return nil;
    }
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.taget = self.controller;
    model.type = ZFNetworkRequestTypeUpload; //码隆搜图走原生AF请求
    model.fileDataArr = @[imageData];
    model.forbidEncrypt = YES;
    model.url = [NSString stringWithFormat:@"%@/file",[YWLocalHostManager searchMapURL]];
    model.parmaters = @{@"page" : @"0",
                        @"count": @"200",
                        @"version" : ZFToString(ZFSYSTEM_VERSION) };
    
    NSURLSessionDataTask *dataTask = [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        HideLoadingFromView(nil);
        BOOL isSuccess = NO;
        
        if ([responseObject[@"code"] integerValue] == 200) {
            NSDictionary *dataDict = responseObject[@"data"];
            if (ZFJudgeNSDictionary(dataDict)) {
                
                NSArray<ZFSearchImageModel *> *sourceArray = [NSArray yy_modelArrayWithClass:[ZFSearchImageModel class] json:dataDict[@"results"]];
                if (sourceArray.count > 0) {
                    [self queryCategoryArrayWithSourceArray:sourceArray isMaNongSearch:YES];
                    isSuccess = YES;
                }
            }
        }
        if (completion) {
            completion(isSuccess);
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        if (completion) {
            completion(NO);
        }
    }];
    return dataTask;
}

/**
 * bts走ZZZZZ内部以图识图
 */
- (NSURLSessionDataTask *)requestSearchZZZZZDiscriminatImage:(UIImage *)sourceImage
                                           searchImagePolicy:(NSString *)searchImagePolicy
                                                  completion:(void (^)(BOOL isSuccess))completion
{
    NSData *imageData = [self compressImage:sourceImage];
    if (![imageData isKindOfClass:[NSData class]]) {
        if (completion) {
            completion(NO);
        }
        return nil;
    }
    
    NSString *tmpFileName = [NSString stringWithFormat:@"%@.png",[NSStringUtils getCurrentMSimestamp]];
    NSString *token = [NSStringUtils ZFNSStringMD5:[NSString stringWithFormat:@"%@%@",kSearchImageEncryptKey, tmpFileName]];
    
    NSString *domain = [searchImagePolicy isEqualToString:kZFBts_C] ? @"2" : @"1";
    NSString *searchUrl = [NSString stringWithFormat:@"%@?token=%@&domain=%@",[YWLocalHostManager zfSearchImageURL] ,token ,domain];
    YWLog(@"分类内部识图接口参数===%@", searchUrl);
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    [sessionManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    return [sessionManager POST:searchUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData){
        [formData appendPartWithFileData:imageData name:@"data" fileName:tmpFileName mimeType:@"image/png"];
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject){
        YWLog(@"ZZZZZ内部以图识图: 成功======%@",responseObject);
        
        HideLoadingFromView(nil);
        if (!ZFJudgeNSDictionary(responseObject)) {
            if (completion) {
                completion(NO);
            }
            return ;
        }
        
        BOOL isSuccess = NO;
        if ([responseObject[@"status"] integerValue] == 0) {
            NSArray *resultArray= responseObject[@"result"];
            if (ZFJudgeNSArray(resultArray)) {
                
                NSArray<ZFSearchMetaModel *> *sourceArray = [NSArray yy_modelArrayWithClass:[ZFSearchMetaModel class] json:resultArray];
                if (sourceArray.count > 0) {
                    [self queryCategoryArrayWithSourceArray:sourceArray isMaNongSearch:NO];
                    isSuccess = YES;
                }
            }
        }
        if (completion) {
            completion(isSuccess);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        YWLog(@"ZZZZZ内部以图识图: 失败======%@",error);
        HideLoadingFromView(nil);
        if (completion) {
            completion(NO);
        }
    }];
}

/**
 * 根据sku查询商品信息
 */
- (void)requestSearchResultData:(NSString *)goodsID
                     completion:(void (^)(NSArray *currentPageArray))completion
{
    ZFBTSModel *productPhotoBtsModel = [ZFBTSManager getBtsModel:kZFBtsProductPhoto defaultPolicy:kZFBts_A];
    NSMutableArray *bts_test = [NSMutableArray array];
    [bts_test addObject:[productPhotoBtsModel getBtsParams]];
    
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.url = API(Port_categorySearch);
    model.parmaters = @{
                        @"goods_sn" : ZFToString(goodsID),
                        @"bts_test" : bts_test
                        };
    model.taget = self.controller;
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        HideLoadingFromView(nil);
        NSArray<ZFGoodsModel *> *resultArray = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:responseObject[ZFResultKey][@"goods_list"]];
        [self.goodsArray removeAllObjects];
        [self.goodsArray addObjectsFromArray:resultArray];
        if (completion) {
            completion(resultArray);
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - Private method
- (void)queryCategoryArrayWithSourceArray:(NSArray *)sourceArray isMaNongSearch:(BOOL)isMaNongSearch
{
    NSMutableArray<ZFSearchMetaModel *> *metaDataArray = [NSMutableArray arrayWithCapacity:sourceArray.count];
    if (isMaNongSearch) {
        [sourceArray enumerateObjectsUsingBlock:^(ZFSearchImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [metaDataArray addObject:obj.metaModel];
        }];
    } else {
        [metaDataArray addObjectsFromArray:sourceArray];
    }
    
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    NSMutableArray *allGoodsIDArray = [NSMutableArray array];
    [metaDataArray enumerateObjectsUsingBlock:^(ZFSearchMetaModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ZFSearchMetaModel class]] &&
            !ZFIsEmptyString(obj.cat_name) && !ZFIsEmptyString(obj.goods_sn)) {
            @autoreleasepool {
                if ([map valueForKey:obj.cat_name]) {
                    NSMutableArray *subLevelArray = map[obj.cat_name];
                    [subLevelArray addObject:obj.goods_sn];
                    [map setValue:subLevelArray forKey:obj.cat_name];
                }else{
                    NSMutableArray *subLevelArray = [NSMutableArray array];
                    [subLevelArray addObject:obj.goods_sn];
                    [map setValue:subLevelArray forKey:obj.cat_name];
                }
            }
            [allGoodsIDArray addObject:obj.goods_sn];
        }
    }];
    
    [self.categoryArray removeAllObjects];
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:map.count];
    [map enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        ZFSearchMapModel *mapModel = [[ZFSearchMapModel alloc] init];
        mapModel.catName = key;
        mapModel.catArray = obj;
        [tempArray addObject:mapModel];
    }];
    [self.categoryArray addObjectsFromArray:tempArray];
    
    NSArray *sortResultArr = [self.categoryArray sortedArrayUsingComparator:^NSComparisonResult(ZFSearchMapModel *obj1, ZFSearchMapModel *obj2) {
        NSNumber *number1 = [NSNumber numberWithUnsignedLong:obj1.catArray.count];
        NSNumber *number2 = [NSNumber numberWithUnsignedLong:obj2.catArray.count];
        NSComparisonResult result = [number1 compare:number2];
        return  result == NSOrderedAscending;
    }];

    [self.categoryArray removeAllObjects];
    [self.categoryArray addObjectsFromArray:sortResultArr];
    
    ZFSearchMapModel *allModel = [[ZFSearchMapModel alloc] init];
    allModel.catName = @"All";
    allModel.catArray = allGoodsIDArray;
    [self.categoryArray insertObject:allModel atIndex:0];
}


- (NSArray *)queryPageArray:(NSInteger)index {
    NSMutableArray *pageArrays = [NSMutableArray array];
    ZFSearchMapModel *mapModel = [self.categoryArray objectWithIndex:index];
    NSUInteger itemsRemaining = mapModel.catArray.count;
    NSInteger pageSize = 20;
    int j = 0;
    while(itemsRemaining) {
        NSRange range = NSMakeRange(j, MIN(pageSize, itemsRemaining));
        NSArray *subLogArr = [mapModel.catArray subarrayWithRange:range];
        [pageArrays addObject:subLogArr];
        itemsRemaining -= range.length;
        j += range.length;
    }
    
    return pageArrays;
}

- (NSInteger)queryCategoryArrayCount:(NSInteger)index {
    ZFSearchMapModel *mapModel = [self.categoryArray objectWithIndex:index];
    return mapModel.catArray.count;
}

- (NSArray <NSString *> *)tabMenuTitles {
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:self.categoryArray.count];
    for (ZFSearchMapModel *mapModel in self.categoryArray) {
        [values addObject:[NSString stringWithFormat:@"%@", mapModel.catName]];
    }
    return values;
}

#pragma mark - Public method
- (void)reloadCollectionState:(NSDictionary *)info completion:(void (^)(NSIndexPath *index))completion {
    // 1.先获取所有的goods_id
    NSMutableArray *goodsIDArray = [NSMutableArray arrayWithCapacity:self.goodsArray.count];
    [self.goodsArray enumerateObjectsUsingBlock:^(ZFGoodsModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [goodsIDArray addObject:obj.goods_id];
    }];
    [goodsIDArray copy];
    
    // 2.判断当前首页推荐商品是否有这个 goods_id
    // 3.利用集合判断是否包含这个元素,比数组速度快,底层调用哈希判断
    NSString *goods_id = ZFToString(info[@"goods_id"]);
    NSSet *set = [NSSet setWithArray:goodsIDArray];
    if (![set containsObject:goods_id]) {
        return;
    }
    
    // 4.获取当前商品所在的下标
    NSUInteger index = [goodsIDArray indexOfObject:goods_id];
    
    // 5.改变收藏状态
    ZFGoodsModel *model = self.goodsArray[index];
    model.is_collect = info[@"is_collect"];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    if (completion) {
        completion(indexPath);
    }
}

#pragma mark - Image compress

- (NSData *)compressImage:(UIImage *)sourceImage {
    if (sourceImage.size.width != 640) {
        sourceImage = [self scaleImage:sourceImage toScale:640/sourceImage.size.width];
    }
    return [self compressImageWithOriginImage:sourceImage];
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (NSData *)compressImageWithOriginImage:(UIImage *)originImg {
    NSData* imageData;
    float i = 1.0;
    do {
        imageData = UIImageJPEGRepresentation(originImg, i);
        i -= 0.1;
    } while (imageData.length > 1*1024*1024);//压缩的图片不能大于1M
    
    return imageData;
}

#pragma mark - Getter
- (NSMutableArray<ZFSearchMapModel *> *)categoryArray{
    if (!_categoryArray) {
        _categoryArray = [NSMutableArray array];
    }
    return _categoryArray;
}

- (NSMutableArray<ZFGoodsModel *> *)goodsArray{
    if (!_goodsArray) {
        _goodsArray = [NSMutableArray array];
    }
    return _goodsArray;
}

@end
