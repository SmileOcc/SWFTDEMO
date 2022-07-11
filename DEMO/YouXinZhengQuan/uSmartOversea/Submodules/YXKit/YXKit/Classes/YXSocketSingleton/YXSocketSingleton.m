//
//  YXSocketSingleton.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/5.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSocketSingleton.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "YYWeakProxy.h"
#import "HLNetWorkReachability.h"
#import "YXTimerSingleton.h"
#import <YXKit/YXKit-Swift.h>

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif


#define kPkglenAndCommandLength  6 //包长和命令字长度
#define kDataHeaderLength 18     //通用消息头长度（除去扩展）
#define kShakeHandsReqLength  67 //握手请求长度（除去扩展）
#define kShakeHandsRspLength  29 //握手应答长度 (除去扩展)

#define kDefaultTimeOut 5 //默认超时时间
#define kMaxTimeOutCount 3 //默认最大轮训次数
#define kMaxReconnectCount NSIntegerMax //默认最大重试次数

/**
 读类型

 - YXSocketReadTagCommand: 命令字
 - YXSocketReqdTagShakeHands: 握手
 - YXSocketReadTagHeader: 报头
 - YXSocketReadTagBody: 主体
 */
typedef NS_ENUM(long, YXSocketReadTag){
    YXSocketReadTagCommand    = 1,
    YXSocketReadTagShakeHands = 2,
    YXSocketReadTagHeader     = 3,
    YXSocketReadTagBody       = 4,
};


/**
 写类型

 - YXSocketWriteTagShakeHands: 握手
 - YXSocketWriteTagAuth: 鉴权
 - YXSocketWriteTagSub: 订阅
 - YXSocketWriteTagUnSub: 取消订阅
 - YXSocketWriteTagUnAllSub: 取消全部订订阅
 */
typedef NS_ENUM(long, YXSocketWriteTag){
    YXSocketWriteTagShakeHands     =   1,
    YXSocketWriteTagPing           =   2,
    YXSocketWriteTagAuth           =   3,
    YXSocketWriteTagSub            =   4,
    YXSocketWriteTagUnSub          =   5,
    YXSocketWriteTagUnAllSub       =   6,
};


//@implementation YXSocketPushModel
//
//@end

@interface YXSubItem: NSObject

@property (nonatomic, strong) YYWeakProxy* weakProxy;
@property (nonatomic, strong) NSMutableArray<NSString *> *topicStringArray;
@property (nonatomic, assign) YXSocketSeqFlag seqFlag;
@property (nonatomic, assign) YXSocketWriteTag writeTag;
@property (nonatomic, assign) BOOL done;
// 记录YXSocketExtraQuote
@property (nonatomic, assign) YXSocketExtraQuote extraQuote;
@end

@implementation YXSubItem


@end

@interface YXSocketSingleton () <GCDAsyncSocketDelegate> {
    
    int32_t _dataLength;
    YXSocketCommandType _currentCommand;
    
    NSInteger _reconnectCount;
}

@property (nonatomic, strong) GCDAsyncSocket *singleSocket;
@property (nonatomic, strong) NSMutableData *socketData;

@property (nonatomic, strong) NSMutableDictionary *subPool;
@property (nonatomic, strong) NSMutableDictionary *unSubPool;

@property (nonatomic, assign) YXTimerFlag shakeHandsTimerFlag;
@property (nonatomic, assign) NSInteger shakeHandsimeOutCount;

@property (nonatomic, assign) YXTimerFlag authTimerFlag;

@property (nonatomic, assign) YXTimerFlag pingTimerFlag;
@property (nonatomic, assign) NSInteger pingTimeOutCount;

@property (nonatomic, assign, readwrite) BOOL connecting;
@property (nonatomic, assign) HLNetWorkStatus netWorkStatus;

@property (nonatomic, assign) NSInteger urlIndex;
@property (nonatomic, assign) BOOL didConnect;

@property (nonatomic, copy) ServiceNode serviceNodeBlock;
@property (nonatomic, copy) NSURL *currentUrl;

@property (nonatomic, assign) uint32_t seqBase;

@property (nonatomic, assign) BOOL isUUIDChanged;

@end

@implementation YXSocketSingleton

+ (instancetype)shareInstance {
    static YXSocketSingleton *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.didConnect = NO;
        self.urlIndex = 0;
        self.isUUIDChanged = NO;
        self.seqBase = arc4random_uniform(100000000);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetWorkChangeNotification:) name:kNetWorkReachabilityChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUuid:(uint64_t)uuid {
    if (_uuid != uuid) {
        _isUUIDChanged = YES;
    }
    _uuid = uuid;
}

- (void)handleNetWorkChangeNotification:(NSNotification *)ntf{
    HLNetWorkReachability *reachability = (HLNetWorkReachability *)ntf.object;
    HLNetWorkStatus netWorkStatus = [reachability currentReachabilityStatus];
    
    if (self.didConnect == NO) {
        _netWorkStatus = netWorkStatus;
        return;
    }
    if (netWorkStatus == HLNetWorkStatusNotReachable) {
        _netWorkStatus = netWorkStatus;
        self.connecting = NO;
        self.needReconnect = NO;
        [self cutOffSocket];
    } else if (_netWorkStatus == HLNetWorkStatusNotReachable && netWorkStatus != _netWorkStatus) {
        _netWorkStatus = netWorkStatus;
        [self cutOffSocket];
        [self socketConnectHost];
    } else {
        _netWorkStatus = netWorkStatus;
        if (_reconnectCount >= 5) {
            [self cutOffSocket];
            [self socketConnectHost];
        }
    }
}

- (void)socketConnectHost {

    if (_netWorkStatus == HLNetWorkStatusNotReachable) {
        return;
    }
    
    if (!_singleSocket) {
        self.singleSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    _currentCommand = 0;
    _socketData = nil;
    _dataLength = 0;
    
    if (![self.singleSocket isConnected]) {
        self.connecting = YES;
        NSError *error = nil;

        NSURL *url = self.currentUrl;
        if (!url) {
            url = self.urls[self.urlIndex];
        }
        
        [self.singleSocket connectToHost:url.host onPort:url.port.intValue error:&error];
        
#ifdef DEBUG
        NSLog(@"socketConnectHost error %@",error);
#endif
    }
}

- (void)cutOffSocket {
    
    [self invalid];
    [self pauseAllSub];
    
    if(![self.singleSocket isDisconnected]) {
        [self.singleSocket disconnect];
    }
    
    _reconnectCount = 0;
    
    _currentCommand = 0;
    _socketData = nil;
    _dataLength = 0;
    
    [self.singleSocket disconnect];
    
    _singleSocket.delegate = nil;
    _singleSocket = nil;
    _connecting = NO;
}

- (BOOL)isConnected {
    return _singleSocket.isConnected;
}

#pragma mark - getter
- (NSMutableData *)socketData {
    if (_socketData == nil) {
        _socketData = [[NSMutableData alloc] init];
    }
    return _socketData;
}

- (NSMutableDictionary *)subPool {
    if (_subPool == nil) {
        _subPool = [[NSMutableDictionary alloc] init];
    }
    return _subPool;
}

- (NSMutableDictionary *)unSubPool {
    if (_unSubPool == nil) {
        _unSubPool = [[NSMutableDictionary alloc] init];
    }
    return _unSubPool;
}

#pragma mark - invalid
- (void)invalid {
    [self invalidPing];
    [self invalidAllUnSub];
    [self invalidShakeHands];
    [self invalidAuth];
}

- (void)invalidPing {
    if (self.pingTimerFlag > 0 ) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.pingTimerFlag];
        self.pingTimerFlag = 0;
    }
}

- (void)invalidShakeHands {
    if (self.shakeHandsTimerFlag > 0 ) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.shakeHandsTimerFlag];
        self.shakeHandsTimerFlag = 0;
    }
}

- (void)invalidAuth {
    if (self.authTimerFlag > 0 ) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.authTimerFlag];
        self.authTimerFlag = 0;
    }
}

- (void)invalidAllUnSub {
    @synchronized (self.unSubPool) {
        [self.unSubPool enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self invalidUnSubWithFlag:[key unsignedIntValue]];
        }];
    }
}

#pragma mark - Socket Methods

- (void)pingWithServer {
    [self invalidPing];
    self.pingTimeOutCount = -1;
    
    @weakify(self)
    self.pingTimerFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self)
        self.pingTimeOutCount++;
        if (self.pingTimeOutCount > kMaxTimeOutCount) {
            self.needReconnect = YES;
            [self cutOffSocket];
            [self socketConnectHost];
            
            return;
        }
        
        YXSocketSeqFlag seqFlag = flag + self.seqBase;
        
        AcHeader header;
        header.Pkglen = htonl(kDataHeaderLength);
        header.Command = YXSocketCommandTypePing;
        header.subCommand = YXSocketSubCommandTypeNone;
        header.SeqNum = htonl(seqFlag);
        header.Flag = 0;
        header.TlvLen = 0;
        header.result = 0;
        
        NSData *writeData = [[NSData alloc] initWithBytes:&header length:sizeof(header)];
        [self.singleSocket writeData:writeData withTimeout:kDefaultTimeOut tag:YXSocketWriteTagPing];
    } timeInterval:kDefaultTimeOut repeatTimes:NSIntegerMax atOnce:YES];
}

- (void)shakeHandsWithServer {
    [self invalidShakeHands];
    self.shakeHandsimeOutCount = -1;
    
    @weakify(self)
    self.shakeHandsTimerFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self)
        self.shakeHandsimeOutCount++;
        if (self.shakeHandsimeOutCount > kMaxTimeOutCount) {
            self.needReconnect = YES;
            [self cutOffSocket];
            [self socketConnectHost];
            return;
        }
        
        ShakeHandsReq req;
        req.Pkglen = htonl(kShakeHandsReqLength);
        req.Command = YXSocketCommandTypeShakeHands;
        req.Version = 0;
        req.AccessType = YXSocketAccessTypeTCP;
        req.Userid = htonll(self.uuid);
        req.CVer = htonll(YXConstant.appVersionValue);
        req.SystemVer = htonl(YXConstant.systemVersionValue);
        req.DeviceType = YXSocketDeviceTypeIOS;
        req.AppType = self.appType;
        req.LangType = self.langType;
        memcpy(req.DeviceID, [self.deviceId UTF8String], 32);
        req.TlvNum = 0;
        
        NSData *writeData = [[NSData alloc] initWithBytes:&req length:sizeof(req)];
        [self.singleSocket writeData:writeData withTimeout:kDefaultTimeOut tag:YXSocketWriteTagShakeHands];
        
    } timeInterval:kDefaultTimeOut repeatTimes:NSIntegerMax atOnce:YES];
}

- (void)authWithServer {
    [self invalidAuth];
    
    if (self.accessToken != nil) {
        self.authTimerFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
            API_CLIENTAcAuthReq *authReq = [[API_CLIENTAcAuthReq alloc] init];
            authReq.accessToken = self.accessToken;
            NSData *reqData = [authReq data];
            
            YXSocketSeqFlag seqFlag = flag + self.seqBase;
            
            AcHeader header;
            header.Pkglen = htonl(kDataHeaderLength + (uint32_t)reqData.length);
            header.Command = YXSocketCommandTypeAuth;
            header.subCommand = YXSocketSubCommandTypeNone;
            header.SeqNum = htonl(seqFlag);
            header.Flag = 0;
            header.TlvLen = 0;
            header.result = 0;
            
            NSMutableData *writeData = [[NSMutableData alloc] initWithBytes:&header length:sizeof(header)];
            [writeData appendData:reqData];
            [self.singleSocket writeData:writeData withTimeout:kDefaultTimeOut tag:YXSocketWriteTagAuth];
            
        } timeInterval:kDefaultTimeOut repeatTimes:NSIntegerMax atOnce:YES];
    }
}

- (void)transactSubItem:(YXSubItem *)subItem {
    if (self.connecting) {
        return;
    }
    NSData *reqData = nil;
    AcHeader header;
    
    switch (subItem.writeTag) {
        case YXSocketWriteTagSub:
        {
            API_CLIENTSub *subReq = [[API_CLIENTSub alloc] init];
            subReq.topicArray = subItem.topicStringArray;
            reqData = [subReq data];
            
            header.Command = YXSocketCommandTypeSub;
            NSString *topicString = subItem.topicStringArray.firstObject;
            YXSocketTopic *topic = [YXSocketTopic topicWithString:topicString];
            subItem.extraQuote = topic.extraQuote;
            if (topic.marketID == OBJECT_MARKETMarketId_Usoption) {
                header.subCommand = YXSocketSubCommandTypeOption;
            } else if (topic.pushType == API_CLIENTPushType_Ob || topic.pushType == API_CLIENTPushType_Obchart) {
                header.subCommand = YXSocketSubCommandTypeArcabook;
            } else if (topic.extraQuote == YXSocketExtraQuoteUsNation) {
                header.subCommand = YXSocketSubCommandTypeUsNation;
            } else {
                header.subCommand = YXSocketSubCommandTypeNone;
            }
        }
            break;
        case YXSocketWriteTagUnSub:
        {
            API_CLIENTUnSub *unSubReq = [[API_CLIENTUnSub alloc] init];
            // 写数据前,将topic客户端自己定义的后缀去掉, .usNation
            unSubReq.topicArray = subItem.topicStringArray;
            reqData = [unSubReq data];
            
            header.Command = YXSocketCommandTypeUnSub;
            NSString *topicString = subItem.topicStringArray.firstObject;
            YXSocketTopic *topic = [YXSocketTopic topicWithString:topicString];
            subItem.extraQuote = topic.extraQuote;
            if (topic.marketID == OBJECT_MARKETMarketId_Usoption) {
                header.subCommand = YXSocketSubCommandTypeOptionCancel;
            } else if (topic.pushType == API_CLIENTPushType_Ob || topic.pushType == API_CLIENTPushType_Obchart) {
                header.subCommand = YXSocketSubCommandTypeArcabookCancel;
            } else if (topic.extraQuote == YXSocketExtraQuoteUsNation) {
                header.subCommand = YXSocketSubCommandTypeUsNationCancel;
            } else {
                header.subCommand = YXSocketSubCommandTypeCancel;
            }
        }
            break;
        case YXSocketWriteTagUnAllSub:
        {
            API_CLIENTUnSub *unSubReq = [[API_CLIENTUnSub alloc] init];
            unSubReq.topicArray = [NSMutableArray array];
            reqData = [unSubReq data];
            
            header.Command = YXSocketCommandTypeUnSub;
            header.subCommand = YXSocketSubCommandTypeCancelAll;
        }
            break;
        default:
            break;
    }
    
    YXSocketSeqFlag seqFlag = subItem.seqFlag + self.seqBase;
    
    header.SeqNum = htonl(seqFlag);
    header.Flag = 0;
    header.TlvLen = 0;
    header.result = 0;
    header.Pkglen = htonl(kDataHeaderLength + (uint32_t)reqData.length);
    
    NSMutableData *writeData = [[NSMutableData alloc] initWithBytes:&header length:sizeof(header)];
    [writeData appendData:reqData];
    [self.singleSocket writeData:writeData withTimeout:kDefaultTimeOut tag:subItem.writeTag];
}

//- (NSArray <NSString *>*)removeTopicsExtra: (NSArray <NSString *>*)topicStringArray {
//    NSMutableArray *arrM = [NSMutableArray array];
//    // 写进去socket的时候,去掉全美行情的字符串
//    NSString *usNation = @".usNation";
//    for (NSString *topicStr in topicStringArray) {
//        if ([topicStr hasSuffix:usNation]) {
//            [arrM addObject:[topicStr substringToIndex:topicStr.length - usNation.length]];
//        } else {
//            [arrM addObject:topicStr];
//        }
//    }
//    return [arrM copy];
//
//}

- (YXSocketSeqFlag)subWithServer:(NSArray<YXSocketTopic *> * _Nonnull)topics target:(id<YXSocketReceiveDataProtocol> _Nonnull)target {
    if ([topics count] < 1) {
        return 0;
    }
    
    NSArray<NSString *> *array = [YXSocketTopic stringArrayWithTopics:topics];
    
    @synchronized (self.unSubPool) {
        [self.unSubPool enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            YXSubItem *subItem = (YXSubItem *)obj;
            [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([subItem.topicStringArray containsObject:obj]) {
                    [subItem.topicStringArray removeObject:obj];
                }
            }];
            if ([subItem.topicStringArray count] < 1) {
                [self invalidUnSubWithFlag:[key unsignedIntValue]];
            }
        }];
    }

#if defined(PRD) || defined(PRD_HK)

#else
    //遍历topics，如果同时有期权和正常股票的订阅，则断言终止程序
    BOOL containNormal = NO;
    BOOL containOption = NO;
    for (YXSocketTopic *topic in topics) {
        if (topic.marketID == OBJECT_MARKETMarketId_Usoption) {
            containOption = YES;
        } else {
            containNormal = YES;
        }

        if (containNormal && containOption) {
            break;
        }
    }
    if (containNormal && containOption) {
        NSAssert(NO, @"期权和正常股票混用同时订阅了，期权需要分开单独请求订阅");
    }

#endif

    
    YXSubItem *subItem = [[YXSubItem alloc] init];
    subItem.writeTag = YXSocketWriteTagSub;
    subItem.weakProxy = [YYWeakProxy proxyWithTarget:target];
    subItem.topicStringArray = [array mutableCopy];
    subItem.done = NO;
    
    @weakify(self)
    @weakify(subItem)
    __block YXSocketSeqFlag seqFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self)
        @strongify(subItem)
        
        if (subItem.weakProxy.target == nil) {
            [self invalidSubWithFlag:seqFlag];
            return;
        }
        
        if ([self.singleSocket isDisconnected]) {
            return;
        }
        
        subItem.seqFlag = flag;
        [self transactSubItem:subItem];
    } timeInterval:kDefaultTimeOut repeatTimes:NSIntegerMax atOnce:YES];
    
    @synchronized (self.subPool) {
        [self.subPool setObject:subItem forKey:@(seqFlag)];
    }
    return seqFlag;
}

- (YXSocketSeqFlag)unSubWithFlag:(YXSocketSeqFlag)flag {
    YXSubItem *subItem = [self.subPool objectForKey:@(flag)];
    if (subItem == nil || !subItem.done) {
        [self invalidSubWithFlag:flag];
        return 0;
    }
    [self invalidSubWithFlag:flag];
    return [self unSubWithSubItem:subItem];
}

- (YXSocketSeqFlag)unSubWithSubItem:(YXSubItem *)subItem{
    NSMutableArray *array = [subItem.topicStringArray mutableCopy];
    
    @synchronized (self.subPool) {
        [self.subPool enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            YXSubItem *subItem = (YXSubItem *)obj;
            [subItem.topicStringArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([array containsObject:obj]) {
                    [array removeObject:obj];
                }
            }];
        }];
    }
    
    if ([array count] < 1) {
        return 0;
    }
    
    YXSubItem *unSubItem = [[YXSubItem alloc] init];
    unSubItem.writeTag = YXSocketWriteTagUnSub;
    unSubItem.topicStringArray = array;
    
    @weakify(self)
    @weakify(unSubItem)
    YXSocketSeqFlag seqFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self)
        @strongify(unSubItem)
        unSubItem.seqFlag = flag;
        
        [self transactSubItem:unSubItem];
    } timeInterval:kDefaultTimeOut repeatTimes:NSIntegerMax atOnce:YES];
    
    @synchronized (self.unSubPool) {
        [self.unSubPool setObject:unSubItem forKey:@(seqFlag)];
    }
    
    return seqFlag;
}

- (void)invalidSubWithFlag:(YXSocketSeqFlag)flag {
    @synchronized (self.subPool) {
        [self.subPool removeObjectForKey:@(flag)];
    }
    
    [[YXTimerSingleton shareInstance] invalidOperationWithFlag:flag];
}

- (void)doneSubWithFlag:(YXSocketSeqFlag)flag {
    @synchronized (self.subPool) {
        [self.subPool enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            YXSubItem *subItem = (YXSubItem *)obj;
            if (subItem.seqFlag == flag) {
                subItem.done = YES;
                [[YXTimerSingleton shareInstance] invalidOperationWithFlag:[key unsignedIntValue]];
                *stop = YES;
            }
        }];
    }
}

- (void)invalidUnSubWithFlag:(YXSocketSeqFlag)flag {
    @synchronized (self.unSubPool) {
        [self.unSubPool removeObjectForKey:@(flag)];
    }
    
    [[YXTimerSingleton shareInstance] invalidOperationWithFlag:flag];
}

- (void)doneUnSubWithFlag:(YXSocketSeqFlag)flag {
    @synchronized (self.unSubPool) {
        [self.unSubPool enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            YXSubItem *subItem = (YXSubItem *)obj;
            if (subItem.seqFlag == flag) {
                [self invalidUnSubWithFlag:[key unsignedIntValue]];
                *stop = YES;
            }
        }];
    }
}

- (void)resumeAllSub {
    
    @synchronized (self.subPool) {
        [self.subPool enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            [[YXTimerSingleton shareInstance] resumeOperationWithFlag:[key unsignedIntValue]];
        }];
    }
}

- (void)pauseAllSub {
    @synchronized (self.subPool) {
        [self.subPool enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [[YXTimerSingleton shareInstance] pauseOperationWithFlag:[key unsignedIntValue]];
        }];
    }
}


#pragma mark - Get Server Node method

- (void)getServerNode:(ServiceNode)serviceNode {
    self.serviceNodeBlock = serviceNode;
    
    if (self.serviceNodeBlock) {
        @weakify(self)
        self.serviceNodeBlock(^(NSURL * _Nonnull url) {
            @strongify(self)
            
            self.didConnect = YES;
            if (self->_netWorkStatus == HLNetWorkStatusNotReachable) {
                return;
            }
            self.connecting = YES;
            
            self.currentUrl = url;
            self.needReconnect = YES;
            [self cutOffSocket];
            [self socketConnectHost];
        });
    } else {
        self.didConnect = YES;
        if (_netWorkStatus == HLNetWorkStatusNotReachable) {
            return;
        }
        self.connecting = YES;
        
        self.needReconnect = YES;
        [self cutOffSocket];
        [self socketConnectHost];
    }
}

//- (void)getServerNode:(YXServerNodeRequestModel *)model completion:(void (^ _Nonnull)(void))completion {
//    YXServerNodeRequestModel *serverNodeRequestModel = model;
//    if (!serverNodeRequestModel) {
//        serverNodeRequestModel = [[YXServerNodeRequestModel alloc] init];
//    }
//    __weak typeof(self) weakSelf = self;
//    _serverNodeRequest = [[YXRequest alloc] initWithRequestModel:serverNodeRequestModel];
//    [_serverNodeRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
//        BOOL getNodeSuccess = NO;
//        if (responseModel.code == YXResponseStatusCodeSuccess && responseModel.data[@"masterAddr"]) {
//            [[MMKV defaultMMKV] setObject:responseModel.data[@"masterAddr"] forKey:@"masterAddr"];
//            getNodeSuccess = YES;
//        }
//
//        if (getNodeSuccess == NO && [serverNodeRequestModel changeServerHeader]) {
//            [weakSelf getServerNode:serverNodeRequestModel completion:^{
//                completion();
//            }];
//        } else {
//            completion();
//        }
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//        if ([serverNodeRequestModel changeServerHeader]) {
//            [weakSelf getServerNode:serverNodeRequestModel completion:^{
//                completion();
//            }];
//        } else {
//            completion();
//        }
//    }];
//
//}


//- (YXSocketSeqFlag)unAllSubWithServer {
//
//    YXSocketWriteTag tag = YXSocketWriteTagUnAllSub;
//
//    API_CLIENTSub *unAllSubReq = [[API_CLIENTSub alloc] init];
//    unAllSubReq.topicArray = [[NSMutableArray alloc] init];
//    NSData *reqData = [unAllSubReq data];
//
//    AcHeader header;
//    header.Pkglen = htonl(kDataHeaderLength + (uint32_t)reqData.length);
//    header.Command = YXSocketCommandTypeUnSub;
//    header.subCommand = YXSocketSubCommandTypeCancelAll;
//    header.SeqNum = htonl(seqFlag);
//    header.Flag = 0;
//    header.TlvLen = 0;
//    header.result = 0;
//
//    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&header length:sizeof(header)];
//    [sendData appendData:reqData];
//    [self write:sendData flag:seqFlag tag:tag];
//
//    return seqFlag;
//}


#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    _needReconnect = NO;
    
    [self shakeHandsWithServer];
    
    [sock readDataToLength:kPkglenAndCommandLength withTimeout:-1 tag:YXSocketReadTagCommand];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    NSLog(@"");
#ifdef DEBUG
    NSLog(@"Write Finished ---- %ld", tag);
#endif
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    switch (tag) {
        case YXSocketReadTagCommand:
        {
            [self.socketData appendData:data];
            
            Byte *byte = (Byte *)[data bytes];
            _dataLength = (uint32_t)(((byte[0] & 0xff) << 24) | (byte[1] & 0xff) << 16 | (byte[2] & 0xff) << 8 | (byte[3] & 0xff));
            //16M
            _currentCommand = (uint16_t)(((byte[5] & 0xff) << 8) | (byte[4] & 0xff));

            _dataLength -= data.length;
            if (_currentCommand == YXSocketCommandTypeShakeHands) {
                [sock readDataToLength:_dataLength withTimeout:-1 tag:YXSocketReadTagShakeHands];
            } else{
                [sock readDataToLength:kDataHeaderLength - data.length withTimeout:-1 tag:YXSocketReadTagHeader];
            }
        }
            break;
        case YXSocketReadTagShakeHands:
        {
            [self.socketData appendData:data];
            
            ShakeHandsRsp rsp;
            [self.socketData getBytes:&rsp length:sizeof(rsp)];
            
            if (rsp.Result == YXSocketResultTypeSuccess) {
                [self invalidShakeHands];
                
                self.connecting = NO;
                if (self.isUUIDChanged == NO) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kYXSocketReconnectNotification object:nil];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kYXSocketConnectNotification object:nil];
                    self.isUUIDChanged = NO;
                }
                
                [self pingWithServer];
                [self authWithServer];
                
                [self resumeAllSub];
            }
            
            _socketData = nil;
            _dataLength = 0;
            _currentCommand = 0;
            [sock readDataToLength:kPkglenAndCommandLength withTimeout:-1 tag:YXSocketReadTagCommand];
        }
            break;
        case YXSocketReadTagHeader:
        {
            [self.socketData appendData:data];
            
            AcHeader header;
            [self.socketData getBytes:&header length:sizeof(header)];
            _socketData = nil;
            
            if (header.result == YXSocketResultTypeSuccess) {
                switch (_currentCommand) {
                    case YXSocketCommandTypePong:
                        self.pingTimeOutCount = 0;
                        break;
                    case YXSocketCommandTypeAuth:
                        [self invalidAuth];
                        break;
                    case YXSocketCommandTypeSub:
                        [self doneSubWithFlag:ntohl(header.SeqNum) - self.seqBase];
                        break;
                    case YXSocketCommandTypeUnSub:
                        [self doneUnSubWithFlag:ntohl(header.SeqNum) - self.seqBase];
                        break;
                    case YXSocketCommandTypeMessage:
                        break;
                    default:
                        break;
                }
            }

            _dataLength -= data.length;
            if (_dataLength > 0) {
                [sock readDataToLength:_dataLength withTimeout:-1 tag:YXSocketReadTagBody];
            } else {
                _currentCommand = 0;
                [sock readDataToLength:kPkglenAndCommandLength withTimeout:-1 tag:YXSocketReadTagCommand];
            }
        }
            break;
        case YXSocketReadTagBody:
        {
            [self.socketData appendData:data];
            
            if (data.length < _dataLength) {
                _dataLength -= data.length;
                [sock readDataToLength:_dataLength withTimeout:-1 tag:YXSocketReadTagBody];
            } else {
                BOOL needCutOff = NO;
                switch (_currentCommand) {
//                    case YXSocketCommandTypePing:
//                    {
//
//                    }
//                        break;
//                    case YXSocketCommandTypePong:
//                    {
//
//                    }
//                        break;
                    case YXSocketCommandTypeSub:
                    {
                        API_CLIENTSubRsp *rsp = [API_CLIENTSubRsp parseFromData:self.socketData error:nil];
                        if (rsp != nil) {
                            
                        } else {
                            needCutOff = YES;
                        }
                    }
                        break;
                    case YXSocketCommandTypeUnSub:
                    {
                        API_CLIENTUnSubRsp *rsp = [API_CLIENTUnSubRsp parseFromData:self.socketData error:nil];
                        if (rsp != nil) {
                            
                        } else {
                            needCutOff = YES;
                        }
                    }
                        break;
                    case YXSocketCommandTypeMessage:
                    {
                        NSError *error;
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.socketData options:kNilOptions error:&error];
                        if ([dict isKindOfClass:[NSDictionary class]] && error == nil) {

                            int msgType = [dict[@"msgType"] intValue];
                            
                            if (msgType == 17) {
                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[dict[@"content"] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
                                NSArray *apiType = json[@"apiType"];
                                NSNumber *subAccount = json[@"subAccount"];
                                if (apiType.count > 0) {
                                    if (subAccount) {
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kYXSocketTodayOrderChangeNotification object:subAccount];
                                        
                                        // 处理下碎股
                                        if ([subAccount isEqualToNumber:@(24)]) {
                                            [[NSNotificationCenter defaultCenter] postNotificationName:kYXSocketTradeAccountChangeNotification object:apiType];
                                        }
                                    } else {
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kYXSocketTradeAccountChangeNotification object:apiType];
                                    }
                                }
                                
                            } else if (msgType == 15) {

                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[dict[@"content"] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
                                NSString *oldToken = json[@"sessionId"];
                                NSString *message = json[@"message"];
                                if ([oldToken isEqualToString:self.accessToken]) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kYXSocketQuoteLevelChangeNotification object:message];
                                }

                            } else if (msgType == 10) {

                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[dict[@"content"] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
                                NSString *oldToken = json[@"sessionId"];
                                NSString *message = json[@"message"];
                                if ([oldToken isEqualToString:self.accessToken]) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kYXSocketLogoutNotification object:message];
                                }
                            } else if (msgType == 5) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kYXSocketSmartNotification object:nil];
                            }
                            
                            if (self.messageBlock) {
                                self.messageBlock(dict);
                            }
                        }
                    }
                        break;
                    case YXSocketCommandTypePush:
                    {
                        API_CLIENTPush *rsp = [API_CLIENTPush parseFromData:self.socketData error:nil];
                        if (rsp != nil) {
                            NSString *topicString = rsp.topic;
                            
                            @synchronized (self.subPool) {
                                [self.subPool enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                    YXSubItem *subItem = (YXSubItem *)obj;
                                    if ([subItem.topicStringArray containsObject:topicString]) {
                                        id target = subItem.weakProxy.target;
                                        if (target && [target respondsToSelector:@selector(socketDidReceiveClientPush:)]) {
                                            [target socketDidReceiveClientPush:rsp];
                                        }
                                    }
                                }];
                            }
                        } else {
                            needCutOff = YES;
                        }
                    }
                        break;
                    case YXSocketCommandTypeAuth:
                    {
                        API_CLIENTAcAuthRsp *rsp = [API_CLIENTAcAuthRsp parseFromData:self.socketData error:nil];
                        if (rsp != nil) {

                        } else {
                            needCutOff = YES;
                        }
                    }
                        break;
                    default:
                        needCutOff = YES;
                        break;
                }
                
                _socketData = nil;
                _dataLength = 0;
                _currentCommand = 0;
                if (!needCutOff) {
                    [sock readDataToLength:kPkglenAndCommandLength withTimeout:-1 tag:YXSocketReadTagCommand];
                } else {
                    [self cutOffSocket];
                    [self socketConnectHost];
                }
                break;
            }
        }
            break;
        default:
            break;
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
#ifdef DEBUG
    NSLog(@"socket disconnect error %@",err);
#endif
    
    [self invalid];
    [self pauseAllSub];
    
    if(![self.singleSocket isDisconnected]) {
        [self.singleSocket disconnect];
    }
    
    if (++self.urlIndex >= [self.urls count]) {
        self.urlIndex = 0;
    }
    if (_reconnectCount < kMaxReconnectCount && _netWorkStatus != HLNetWorkStatusNotReachable) {
        if (err || _needReconnect) {
            double delayInSeconds = 0.5;
            if (_reconnectCount > 10) {
                [self getServerNode:self.serviceNodeBlock];
                return;
            }else if (_reconnectCount >= 6) {
                delayInSeconds = 5;
            } else if (_reconnectCount > 0) {
                delayInSeconds = 1;
            }
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self socketConnectHost];
                    self->_reconnectCount++;
                });
            });
        }
    }
}


@end
