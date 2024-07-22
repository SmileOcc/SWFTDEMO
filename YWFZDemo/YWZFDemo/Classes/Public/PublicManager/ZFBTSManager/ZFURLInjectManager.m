//
//  ZFURLInjectManager.m
//  ZZZZZ
//
//  Created by YW on 2019/6/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFURLInjectManager.h"
#import "ZFBTSDataSets.h"
#import "Constants.h"
#import "ZFBTSDataSetProtocol.h"
#import "YWLocalHostManager.h"

static NSString *ZFURLProtocolKey = @"ZFURLProtocolKey";
static NSString *ZFGeshopUrlKey = @"https://api.hqgeshop.com";

@interface ZFURLInjectManager ()
<
    NSURLSessionTaskDelegate,
    NSURLSessionDataDelegate
>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSMutableData *mutableData;
@end

@implementation ZFURLInjectManager

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    //不拦截老的请求
    return NO;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task
{
    NSString *urlString = task.currentRequest.URL.absoluteString;
    if ([ZFURLInjectManager judgeURLInject:urlString]) {
        //拦截包需要的请求
        if ([NSURLProtocol propertyForKey:ZFURLProtocolKey inRequest:task.currentRequest]) {
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (Class)judgeURLInject:(NSString *)urlString
{
    if ([ZFBTSDataSets sharedInstance].interceptProtocol[urlString]) {
        return [ZFBTSDataSets sharedInstance].interceptProtocol[urlString];
        
    } else if ([urlString containsString:@"APPHomePage.json"]) { //因主页获取S3的备份数据接口地址存在动态化,特殊判断处理
        return NSDictionary.class;
        
    }  else if ([urlString containsString:ZFGeshopUrlKey]) { //因主页获取Geshop接口地址存在动态化,特殊判断处理
        return NSDictionary.class;
    } else {
        return nil;
    }
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    //对比请求是否有缓存
    return [super requestIsCacheEquivalent:a toRequest:b];
}

-(void)startLoading
{
    NSMutableURLRequest *mutableRequest = [[self request] mutableCopy];
    //设置标识字段，防止重复拦截
    [NSURLProtocol setProperty:@YES forKey:ZFURLProtocolKey inRequest:mutableRequest];
    
    //重新发起请求
    self.task = [self.session dataTaskWithRequest:mutableRequest];
    [self.task resume];
}

- (void)stopLoading
{
    [self.task cancel];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        //拦截到数据以后，把相应的数据取出来
        //获取到请求到的BTS模型
        //Performance Improvement from #2672
        NSData *data = nil;
        if (self.mutableData) {
            data = [self.mutableData copy];
            //We no longer need the reference, so nil it out to gain back some memory.
            self.mutableData = nil;
        }
        NSString *urlString = task.currentRequest.URL.absoluteString;
        if ([ZFURLInjectManager judgeURLInject:urlString]) {
            NSError *error = nil;
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (!error) {
                if ([jsonData isKindOfClass:[NSDictionary class]]) {
                    [self handlerBTSData:jsonData task:task];
                }
            }
        }
        
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [self.mutableData appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

- (void)handlerBTSData:(NSDictionary *)result task:(NSURLSessionTask *)dataTask
{
    NSString *urlString = dataTask.currentRequest.URL.absoluteString;
    Class class = [ZFURLInjectManager judgeURLInject:urlString];
    id params = result[ZFResultKey];
    if (!params) {
        params = result[ZFDataKey];
    }
    id model = [class yy_modelWithJSON:params];
    //实现了ZFBTSDataSetProtocol协议的模型，直接通过方法取
    if ([model conformsToProtocol:@protocol(ZFBTSDataSetProtocol)]) {
        id <ZFBTSDataSetProtocol> protocol = model;
        NSArray <ZFBTSModel *>*btsModel = [protocol gainDataSetBTSModelList];
        if ([btsModel count]) {
            [[ZFBTSDataSets sharedInstance] addObjectFromeArray:btsModel];
        }
        return;
    }
    //如果是字典类型，递归寻找af_params
    if (class == NSDictionary.class) {
        if ([params isKindOfClass:[NSArray class]]) {
            NSArray *list = (NSArray *)params;
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self addBTSParams:obj];
            }];
        } else if ([params isKindOfClass:[NSDictionary class]]) {
            [self addBTSParams:params];
        }
    }
    //通过客户端BTS链接请求的BTS数据
    if ([urlString isEqualToString:[YWLocalHostManager appBtsListUrl]]
        || [urlString isEqualToString:[YWLocalHostManager appBtsSingleUrl]]) {
        
        id btsResult = result[ZFResultKey];
        if ([btsResult isKindOfClass:[NSDictionary class]]) {
            ZFBTSModel *btsModel = [ZFBTSModel yy_modelWithJSON:btsResult];
            if (btsModel && [btsModel isKindOfClass:[ZFBTSModel class]]) {
                [[ZFBTSDataSets sharedInstance] addObject:btsModel];
            }
        } else if ([btsResult isKindOfClass:[NSArray class]]) {
            NSArray *btsList = [NSArray yy_modelArrayWithClass:[ZFBTSModel class] json:btsResult];
            if ([btsList count]) {
                [[ZFBTSDataSets sharedInstance] addObjectFromeArray:btsList];
            }
        }
        
    } else if ([urlString containsString:ZFGeshopUrlKey]) {
        // 特殊处理Geshop实验参数
        id btsResult = result[@"af_params"];
        if ([btsResult isKindOfClass:[NSDictionary class]]) {
            ZFBTSModel *btsModel = [ZFBTSModel yy_modelWithJSON:btsResult];
            if (btsModel && [btsModel isKindOfClass:[ZFBTSModel class]]) {
                [[ZFBTSDataSets sharedInstance] addObject:btsModel];
            }
        }
    }
}

- (void)addBTSParams:(id)params
{
    NSArray *paramsList = [self findBTSParams:params];
    [paramsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *btsDic = (NSDictionary *)obj;
            ZFBTSModel *model = [ZFBTSModel yy_modelWithJSON:btsDic];
            [[ZFBTSDataSets sharedInstance] addObject:model];
        }
    }];
}

- (NSMutableArray *)findBTSParams:(NSDictionary *)params
{
    if (![params isKindOfClass:[NSDictionary class]]) {
        return [@[] mutableCopy];
    }
    NSArray *allkeys = params.allKeys;
    NSMutableArray *paramsList = [[NSMutableArray alloc] init];
    NSArray *btsParamsKeys = [[ZFBTSDataSets sharedInstance] BTSinjectAllkeys];
    int i = 0;
//    int j = 0;
    for (i = 0; i < allkeys.count; i++) {
        NSString *key = allkeys[i];
        id value = params[key];
        if ([btsParamsKeys containsObject:key]) {
            [paramsList addObject:params[key]];
        }
        if ([value isKindOfClass:[NSDictionary class]]) {
            [paramsList addObjectsFromArray:[self findBTSParams:value]];
        }
//        因为接口都是在一级数据中返回了bts数据，所以不需要去消耗性能遍历子数组里的bts参数
//        如果后期有需要遍历子数组查找bts数据，可打开注释
//        2019年09月11日15:56:24
//        else if ([value isKindOfClass:[NSArray class]]) {
//            NSArray *list = value;
//            for (j = 0; j < list.count; j++) {
//                id listValue = list[j];
//                if ([listValue isKindOfClass:[NSDictionary class]]) {
//                    [paramsList addObjectsFromArray:[self findBTSParams:listValue]];
//                }
//            }
//        }
        else {
            continue;
        }
    }
    return paramsList;
}

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return _session;
}

- (NSMutableData *)mutableData
{
    if (!_mutableData) {
        _mutableData = [[NSMutableData alloc] init];
    }
    return _mutableData;
}

@end
