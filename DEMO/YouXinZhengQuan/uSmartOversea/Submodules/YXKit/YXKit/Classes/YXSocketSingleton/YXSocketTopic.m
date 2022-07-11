//
//  YXTopicModel.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/7.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSocketTopic.h"

#define kYXSocketAllPushType @[@"rt", @"ts", @"tk", @"kl", @"cap", @"tspre", @"tsafter", @"tkpre", @"tkafter", @"arcaob", @"ob", @"bq", @"sgxob"]
#define kYXSocketAllKLineType @[@"m1", @"m5", @"m10", @"m15", @"m30", @"m60", @"d", @"w", @"mn1", @"mn3", @"nm6", @"y"]
#define kYXSocketAllCapFlowType @[@"d", @"5d"]
#define kYXSocketAllQuoteScene @[@"full", @"mobile_brf1", @"desktop_brf1", @"CUSTOM_FLAG"]
#define kYXSocketAllKLineDirection @[@"fw", @"bw", @"none"]
#define kYXSocketAllMarket @[@"sh", @"sz", @"hk", @"us", @"usoption", @"cryptos", @"sg"]
#define kYXSocketAllDepthType @[@"", @"merge", @"chart"]

NSString *const kFutu = @"futu";
NSString *const kUsNation = @"uscomp";

@interface YXSocketTopic ()

@property (nonatomic, copy, readwrite) NSString *firstQ;

@property (nonatomic, copy, readwrite) NSString *version;

@property (nonatomic, assign, readwrite) YXSocketPushType pushType;

@property (nonatomic, assign, readwrite) OBJECT_MARKETMarketId marketID;

@property (nonatomic, copy, readwrite) NSString *symbol;

@property (nonatomic, assign, readwrite) OBJECT_QUOTEQuoteScene scene;

@property (nonatomic, assign, readwrite) OBJECT_QUOTEKLineType kLineType;

@property (nonatomic, assign, readwrite) OBJECT_QUOTEKLineDirection direction;

@property (nonatomic, assign, readwrite) OBJECT_QUOTECapFlowType capFlowType;

@end

@implementation YXSocketTopic

- (instancetype)init
{
    self = [super init];
    if (self) {
        _firstQ = @"q";
        _version = @"v2";
    }
    return self;
}

+ (instancetype)topicRtWithMarket:(NSString *)market symbol:(NSString *)symbol scene:(OBJECT_QUOTEQuoteScene)scene {
    return [self topicRtWithMarket:market symbol:symbol scene:scene extraQuote:YXSocketExtraQuoteNone];
}

+ (instancetype)topicRtWithMarket:(NSString *)market symbol:(NSString *)symbol scene:(OBJECT_QUOTEQuoteScene)scene extraQuote: (YXSocketExtraQuote)extraQuote {
    YXSocketTopic *topic = [[YXSocketTopic alloc] init];
    topic.pushType = YXSocketPushTypeRt;
    topic.marketID = [self maketIDWithString:market];
    topic.symbol = symbol;
    topic.scene = scene;
    topic.extraQuote = extraQuote;
    if (scene == OBJECT_QUOTEQuoteScene_QsFull) {
        // 全量行情,用v3,
        topic.version = @"v3";
    }
    
    return topic;
}

+ (instancetype)topicTsWithMarket:(NSString *)market symbol:(NSString *)symbol {
    return [self topicTsWithMarket:market symbol:symbol status:YXSocketMarketStatusIntraday extraQuote:YXSocketExtraQuoteNone];
}

+ (instancetype)topicTsWithMarket:(NSString *)market symbol:(NSString *)symbol status:(YXSocketMarketStatus)status {
    return [self topicTsWithMarket:market symbol:symbol status:status extraQuote:YXSocketExtraQuoteNone];
}

+ (instancetype)topicTsWithMarket:(NSString *)market symbol:(NSString *)symbol status:(YXSocketMarketStatus)status extraQuote: (YXSocketExtraQuote)extraQuote {
    YXSocketTopic *topic = [[YXSocketTopic alloc] init];
    topic.marketID = [self maketIDWithString:market];
    topic.symbol = symbol;
    topic.extraQuote = extraQuote;
    switch (status) {
        case YXSocketMarketStatusPre:
            topic.pushType = YXSocketPushTypeTsPre;
            break;
        case YXSocketMarketStatusAfter:
            topic.pushType = YXSocketPushTypeTsAfter;
            break;
        default:
            topic.pushType = YXSocketPushTypeTs;
            break;
    }
    return topic;
}

+ (instancetype)topicTkWithMarket:(NSString *)market symbol:(NSString *)symbol {
    return [self topicTkWithMarket:market symbol:symbol status:YXSocketMarketStatusIntraday extraQuote:YXSocketExtraQuoteNone];
}

+ (instancetype)topicTkWithMarket:(NSString *)market symbol:(NSString *)symbol status:(YXSocketMarketStatus)status {
    return [self topicTkWithMarket:market symbol:symbol status:status extraQuote:YXSocketExtraQuoteNone];
}
+ (instancetype)topicTkWithMarket:(NSString *)market symbol:(NSString *)symbol status:(YXSocketMarketStatus)status extraQuote: (YXSocketExtraQuote)extraQuote {
    YXSocketTopic *topic = [[YXSocketTopic alloc] init];
    topic.pushType = YXSocketPushTypeTk;
    topic.marketID = [self maketIDWithString:market];
    topic.symbol = symbol;
    topic.extraQuote = extraQuote;
    switch (status) {
        case YXSocketMarketStatusPre:
            topic.pushType = YXSocketPushTypeTkPre;
            break;
        case YXSocketMarketStatusAfter:
            topic.pushType = YXSocketPushTypeTkAtfer;
            break;
        default:
            topic.pushType = YXSocketPushTypeTk;
            break;
    }
    
    return topic;
}

+ (instancetype)topicKlWithMarket:(NSString *)market symbol:(NSString *)symbol type:(OBJECT_QUOTEKLineType)kLineType direction:(OBJECT_QUOTEKLineDirection)direction {
    return [self topicKlWithMarket:market symbol:symbol type:kLineType direction:direction extraQuote:YXSocketExtraQuoteNone];
}

+ (instancetype)topicKlWithMarket:(NSString *)market symbol:(NSString *)symbol type:(OBJECT_QUOTEKLineType)kLineType direction:(OBJECT_QUOTEKLineDirection)direction extraQuote: (YXSocketExtraQuote)extraQuote {
    YXSocketTopic *topic = [[YXSocketTopic alloc] init];
    topic.pushType = YXSocketPushTypeKl;
    topic.marketID = [self maketIDWithString:market];
    topic.symbol = symbol;
    topic.kLineType = kLineType;
    topic.direction = direction;
    topic.extraQuote = extraQuote;
    return topic;
}

+ (instancetype)topicCapWithMarket:(NSString *)market symbol:(NSString *)symbol type:(OBJECT_QUOTECapFlowType)capFlowType {
    YXSocketTopic *topic = [[YXSocketTopic alloc] init];
    topic.pushType = YXSocketPushTypeCap;
    topic.marketID = [self maketIDWithString:market];
    topic.symbol = symbol;
    topic.capFlowType = capFlowType;
    return topic;
}

+ (instancetype)topicDepthWithMarket:(NSString *)market symbol:(NSString *)symbol type:(YXSocketDepthType)type {
    YXSocketTopic *topic = [[YXSocketTopic alloc] init];
            
    topic.marketID = [self maketIDWithString:market];
    topic.symbol = symbol;
    topic.depthType = type;
    
    if (topic.marketID == OBJECT_MARKETMarketId_Sg) {
        topic.pushType = YXSocketPushTypeSgArca;
        if (type == YXSocketDepthTypeChart) {
            topic.pushType = YXSocketPushTypeSgArcaChart;
        }
    } else {
        topic.pushType = YXSocketPushTypeArca;
        if (type == YXSocketDepthTypeChart) {
            topic.pushType = YXSocketPushTypeArcaChart;
        }
    }

    
    
    return topic;
}

+ (instancetype)topicPosWithMarket:(NSString *)market symbol:(NSString *)symbol extraQuote: (YXSocketExtraQuote)extraQuote {
    YXSocketTopic *topic = [[YXSocketTopic alloc] init];
    topic.pushType = YXSocketPushTypePos;
    topic.marketID = [self maketIDWithString:market];
    topic.symbol = symbol;
    topic.scene = OBJECT_QUOTEQuoteScene_QsFull;
    topic.version = @"v3";
    topic.extraQuote = extraQuote;
    return topic;
}

+ (instancetype)topicBrokerWithMarket:(NSString *)market symbol:(NSString *)symbol extraQuote: (YXSocketExtraQuote)extraQuote {
    YXSocketTopic *topic = [[YXSocketTopic alloc] init];
    topic.pushType = YXSocketPushTypeBroker;
    topic.marketID = [self maketIDWithString:market];
    topic.symbol = symbol;
    topic.scene = OBJECT_QUOTEQuoteScene_QsFull;
    topic.extraQuote = extraQuote;
    topic.version = @"v3";
    return topic;
}

+ (instancetype)topicWithString:(NSString *)topicString {
    
    YXSocketTopic *topic = [[YXSocketTopic alloc] init];
    
    // 从尾部判断
    YXSocketExtraQuote extraType = [topic getExtraTypeWithStr:topicString];
    topic.extraQuote = extraType;
    if (topic.getExtraQuoteStr.length > 0) {
        topicString = [topicString substringToIndex:topicString.length - topic.getExtraQuoteStr.length - 1];
    }
    
    NSArray<NSString *> *strings = [topicString componentsSeparatedByString:@"."];
    NSInteger count = strings.count;
    if (count < 5) {
        return nil;
    }
    
    topic.pushType = [self pushTypeWithString:strings[1]];
    topic.version = strings[2];
    topic.marketID = [self maketIDWithString:strings[3]];
    NSUInteger loc = strings[0].length + strings[1].length + strings[2].length + strings[3].length + 1 * 4;
    NSString *tempString = [topicString substringFromIndex:loc];
    switch (topic.pushType) {
        case YXSocketPushTypeRt:
        case YXSocketPushTypePos:
        case YXSocketPushTypeBroker:
        {
            NSString *sceneStr = strings[count - 1];
            topic.scene = [self sceneWithString: sceneStr];
            loc = tempString.length - sceneStr.length - 1;
            topic.symbol = [tempString substringToIndex:loc];
        }
            break;
        case YXSocketPushTypeTs:
        case YXSocketPushTypeTsPre:
        case YXSocketPushTypeTsAfter:
            topic.symbol = tempString;
            break;
        case YXSocketPushTypeTk:
        case YXSocketPushTypeTkPre:
        case YXSocketPushTypeTkAtfer:
            topic.symbol = tempString;
            break;
        case YXSocketPushTypeKl:
        {
            topic.direction = [self kLineDirectionWithString:strings[count - 1]];
            topic.kLineType = [self kLineTypeWithString:strings[count - 2]];
            loc = tempString.length - strings[count - 1].length - strings[count - 2].length - 1 * 2;
            topic.symbol = [tempString substringToIndex:loc];
        }
            break;
        case YXSocketPushTypeCap:
        {
            topic.capFlowType = [self capFlowTypeWithString:strings[count - 1]];
            loc = tempString.length - strings[count - 1].length - 1;
            topic.symbol = [tempString substringToIndex:loc];
        }
            break;
        case YXSocketPushTypeSgArca:
        case YXSocketPushTypeArca:
        {
            YXSocketDepthType depthType = [YXSocketTopic depthTypeWithString: strings[count - 1]];
            topic.depthType = depthType;
            if (depthType == YXSocketDepthTypeMerge || depthType == YXSocketDepthTypeChart) {
                loc = tempString.length - strings[count - 1].length - 1;
                topic.symbol = [tempString substringToIndex:loc];
            } else {
                topic.symbol = tempString;
            }
            
            if (depthType == YXSocketDepthTypeChart) {
                if (topic.marketID == OBJECT_MARKETMarketId_Sg) {
                    topic.pushType = YXSocketPushTypeSgArcaChart;
                } else {
                    topic.pushType = YXSocketPushTypeArcaChart;
                }
            }
        }
            break;
        default:
            break;
    }
    return topic;
}

- (NSString *)topicDescription {
    NSMutableArray *strings = [[NSMutableArray alloc] initWithObjects:_firstQ,
                         [YXSocketTopic stringWithPushType:self.pushType],
                               _version,
                         [YXSocketTopic stringWithMarketID:self.marketID],
                               self.symbol, nil];
    switch (self.pushType) {
        case YXSocketPushTypeRt:
        case YXSocketPushTypePos:
        case YXSocketPushTypeBroker:
            [strings addObject:[YXSocketTopic stringWithScene:self.scene]];
            break;
        case YXSocketPushTypeKl:
            [strings addObject:[YXSocketTopic stringWithKLineType:self.kLineType]];
            [strings addObject:[YXSocketTopic stringWithDirection:self.direction]];
            break;
        case YXSocketPushTypeCap:
            [strings addObject:[YXSocketTopic stringWithCapFlowType:self.capFlowType]];
            break;
        case YXSocketPushTypeSgArca:
        case YXSocketPushTypeSgArcaChart:
        case YXSocketPushTypeArca:
        case YXSocketPushTypeArcaChart:
        {
            NSString *depthStr = [YXSocketTopic stringWithDepthType: self.depthType];
            if (depthStr.length > 0) {
                [strings addObject: depthStr];
            }
        }
            break;
        default:
            break;
    }
    
    if (self.getExtraQuoteStr.length > 0) {
        [strings addObject: self.getExtraQuoteStr];
    }
    
    return [strings componentsJoinedByString:@"."];
}

+ (NSArray<NSString *> *)stringArrayWithTopics:(NSArray<YXSocketTopic *> *)topics {
    NSMutableSet *topicSet = [[NSMutableSet alloc] init];
    
    for (YXSocketTopic *socketTopic in topics) {
        [topicSet addObject:socketTopic.topicDescription];
    }
    return [topicSet allObjects];
}

- (NSString *)market {
    return [YXSocketTopic stringWithMarketID:self.marketID];
}

#pragma mark - Topic To PB
+ (YXSocketPushType)pushTypeWithString:(NSString *)string {
    NSArray *strings = kYXSocketAllPushType;
    NSInteger index = [strings indexOfObject:string];
    
    YXSocketPushType pushType = YXSocketPushTypeNone;
    switch (index) {
        case 0:
            pushType = YXSocketPushTypeRt;
            break;
        case 1:
            pushType = YXSocketPushTypeTs;
            break;
        case 2:
            pushType = YXSocketPushTypeTk;
            break;
        case 3:
            pushType = YXSocketPushTypeKl;
            break;
        case 4:
            pushType = YXSocketPushTypeCap;
            break;
        case 5:
            pushType = YXSocketPushTypeTsPre;
            break;
        case 6:
            pushType = YXSocketPushTypeTsAfter;
            break;
        case 7:
            pushType = YXSocketPushTypeTkPre;
            break;
        case 8:
            pushType = YXSocketPushTypeTkAtfer;
            break;
        case 9:
            pushType = YXSocketPushTypeArca;
            break;
        case 10:
            pushType = YXSocketPushTypePos;
            break;
        case 11:
            pushType = YXSocketPushTypeBroker;
            break;
        case 12:
            pushType = YXSocketPushTypeSgArca;
            break;
        default:
            break;
    }
    return pushType;
}

+ (OBJECT_MARKETMarketId)maketIDWithString:(NSString *)string {
    NSInteger index = [kYXSocketAllMarket indexOfObject:string];
    
    OBJECT_MARKETMarketId maketID = OBJECT_MARKETMarketId_None;
    switch (index) {
        case 0:
            maketID = OBJECT_MARKETMarketId_Sh;
            break;
        case 1:
            maketID = OBJECT_MARKETMarketId_Sz;
            break;
        case 2:
            maketID = OBJECT_MARKETMarketId_Hk;
            break;
        case 3:
            maketID = OBJECT_MARKETMarketId_Us;
            break;
        case 4:
            maketID = OBJECT_MARKETMarketId_Usoption;
            break;
        case 5:
            maketID = OBJECT_MARKETMarketId_Cryptos;
            break;
        case 6:
            maketID = OBJECT_MARKETMarketId_Sg;
            break;
        default:
            break;
    }
    return maketID;
}

+ (OBJECT_QUOTEKLineType)kLineTypeWithString:(NSString *)string {
    NSInteger index = [kYXSocketAllKLineType indexOfObject:string];
    
    OBJECT_QUOTEKLineType kLineType = OBJECT_QUOTEKLineType_KtNone;
    switch (index) {
        case 0:
            kLineType = OBJECT_QUOTEKLineType_KtMin1;
            break;
        case 1:
            kLineType = OBJECT_QUOTEKLineType_KtMin5;
            break;
        case 2:
            kLineType = OBJECT_QUOTEKLineType_KtMin10;
            break;
        case 3:
            kLineType = OBJECT_QUOTEKLineType_KtMin15;
            break;
        case 4:
            kLineType = OBJECT_QUOTEKLineType_KtMin30;
            break;
        case 5:
            kLineType = OBJECT_QUOTEKLineType_KtMin60;
            break;
        case 6:
            kLineType = OBJECT_QUOTEKLineType_KtDay;
            break;
        case 7:
            kLineType = OBJECT_QUOTEKLineType_KtWeek;
            break;
        case 8:
            kLineType = OBJECT_QUOTEKLineType_KtMonth;
            break;
        case 9:
            kLineType = OBJECT_QUOTEKLineType_KtMnt3;
            break;
        case 10:
            kLineType = OBJECT_QUOTEKLineType_KtMnt6;
            break;
        case 11:
            kLineType = OBJECT_QUOTEKLineType_KtMnt12;
            break;
        default:
            break;
    }
    return kLineType;
}

+ (OBJECT_QUOTECapFlowType)capFlowTypeWithString:(NSString *)string {
    NSInteger index = [kYXSocketAllCapFlowType indexOfObject:string];
    
    OBJECT_QUOTECapFlowType capFlowType = OBJECT_QUOTECapFlowType_OneDay;
    switch (index) {
        case 0:
            capFlowType = OBJECT_QUOTECapFlowType_OneDay;
            break;
        case 1:
            capFlowType = OBJECT_QUOTECapFlowType_FiveDay;
            break;
        default:
            break;
    }
    return capFlowType;
}

+ (OBJECT_QUOTEKLineDirection)kLineDirectionWithString:(NSString *)string {
    NSInteger index = [kYXSocketAllKLineDirection indexOfObject:string];
    
    OBJECT_QUOTEKLineDirection direction = OBJECT_QUOTEKLineDirection_KdNone;
    switch (index) {
        case 0:
            direction = OBJECT_QUOTEKLineDirection_KdForward;
            break;
        case 1:
            direction = OBJECT_QUOTEKLineDirection_KdBackward;
            break;
        case 2:
            direction = OBJECT_QUOTEKLineDirection_KdNone;
            break;
        default:
            break;
    }
    return direction;
}

+ (OBJECT_QUOTEQuoteScene)sceneWithString:(NSString *)string {
    NSInteger index = [kYXSocketAllQuoteScene indexOfObject:string];
    
    OBJECT_QUOTEQuoteScene scene = OBJECT_QUOTEQuoteScene_QsFull;
    switch (index) {
        case 0:
            scene = OBJECT_QUOTEQuoteScene_QsFull;
            break;
        case 1:
            scene = OBJECT_QUOTEQuoteScene_QsMobileBrief1;
            break;
        case 2:
            scene = OBJECT_QUOTEQuoteScene_QsDesktopBrief1;
            break;
        case 3:
            scene = OBJECT_QUOTEQuoteScene_QsCustom;
            break;
        default:
            break;
    }
    return scene;
}

+ (YXSocketDepthType)depthTypeWithString:(NSString *)string {
    
    if (string.length == 0) {
        return YXSocketDepthTypeNone;
    }
    NSInteger index = [kYXSocketAllDepthType indexOfObject:string];
    
    YXSocketDepthType depthType = YXSocketDepthTypeNone;
    switch (index) {
        case 1:
            depthType = YXSocketDepthTypeMerge;
            break;
        case 2:
            depthType = YXSocketDepthTypeChart;
            break;
        default:
            break;
    }
    return depthType;
}

- (NSString *)getExtraQuoteStr {
    if (self.extraQuote == YXSocketExtraQuoteUsNation) {
        return kUsNation;
    } else if (self.extraQuote == YXSocketExtraQuoteFutu) {
        return kFutu;
    }
    return @"";
}

- (YXSocketExtraQuote)getExtraTypeWithStr: (NSString *)str {
    if ([str hasSuffix:kUsNation]) {
        return YXSocketExtraQuoteUsNation;
    } else if ([str hasSuffix:kFutu]) {
        return YXSocketExtraQuoteFutu;
    }
    return YXSocketExtraQuoteNone;
}

#pragma mark - PB To Topic
+ (NSString *)stringWithPushType:(YXSocketPushType)pushType {
    NSString *string = @"";
    switch (pushType) {
        case YXSocketPushTypeRt:
            string = @"rt";
            break;
        case YXSocketPushTypeTs:
            string = @"ts";
            break;
        case YXSocketPushTypeTk:
            string = @"tk";
            break;
        case YXSocketPushTypeKl:
            string = @"kl";
            break;
        case YXSocketPushTypeCap:
            string = @"cap";
            break;
        case YXSocketPushTypeTsPre:
            string = @"tspre";
            break;
        case YXSocketPushTypeTsAfter:
            string = @"tsafter";
            break;
        case YXSocketPushTypeTkPre:
            string = @"tkpre";
            break;
        case YXSocketPushTypeTkAtfer:
            string = @"tkafter";
            break;
        case YXSocketPushTypeArca:
            string = @"arcaob";
            break;
        case YXSocketPushTypeArcaChart:
            string = @"arcaob";
            break;
        case YXSocketPushTypePos:
            string = @"ob";
            break;
        case YXSocketPushTypeBroker:
            string = @"bq";
            break;
        case YXSocketPushTypeSgArca:
            string = @"sgxob";
            break;
        case YXSocketPushTypeSgArcaChart:
            string = @"sgxob";
            break;
        default:
            break;
    }
    return string;
}

+ (NSString *)stringWithMarketID:(OBJECT_MARKETMarketId)marketID {
    NSString *string = @"";
    switch (marketID) {
        case OBJECT_MARKETMarketId_Sh:
            string = @"sh";
            break;
        case OBJECT_MARKETMarketId_Sz:
            string = @"sz";
            break;
        case OBJECT_MARKETMarketId_Hk:
            string = @"hk";
            break;
        case OBJECT_MARKETMarketId_Us:
            string = @"us";
            break;
        case OBJECT_MARKETMarketId_Usoption:
            string = @"usoption";
            break;
        case OBJECT_MARKETMarketId_Cryptos:
            string = @"cryptos";
            break;
        case OBJECT_MARKETMarketId_Sg:
            string = @"sg";
            break;
        default:
            break;
    }
    return string;
}

+ (NSString *)stringWithKLineType:(OBJECT_QUOTEKLineType)kLineType {
    NSString *string = @"";
    switch (kLineType) {
        case OBJECT_QUOTEKLineType_KtMin1:
            string = @"m1";
            break;
        case OBJECT_QUOTEKLineType_KtMin5:
            string = @"m5";
            break;
        case OBJECT_QUOTEKLineType_KtMin10:
            string = @"m10";
            break;
        case OBJECT_QUOTEKLineType_KtMin15:
            string = @"m15";
            break;
        case OBJECT_QUOTEKLineType_KtMin30:
            string = @"m30";
            break;
        case OBJECT_QUOTEKLineType_KtMin60:
            string = @"m60";
            break;
        case OBJECT_QUOTEKLineType_KtDay:
            string = @"d";
            break;
        case OBJECT_QUOTEKLineType_KtWeek:
            string = @"w";
            break;
        case OBJECT_QUOTEKLineType_KtMonth:
            string = @"mn1";
            break;
        case OBJECT_QUOTEKLineType_KtMnt3:
            string = @"mn3";
            break;
        case OBJECT_QUOTEKLineType_KtMnt6:
            string = @"mn6";
            break;
        case OBJECT_QUOTEKLineType_KtMnt12:
            string = @"y";
            break;
        default:
            break;
    }
    return string;
}

+ (NSString *)stringWithCapFlowType:(OBJECT_QUOTECapFlowType)capFlowType {
    NSString *string = @"";
    switch (capFlowType) {
        case OBJECT_QUOTECapFlowType_OneDay:
            string = @"d";
            break;
        case OBJECT_QUOTECapFlowType_FiveDay:
            string = @"5d";
            break;
        default:
            break;
    }
    return string;
}

+ (NSString *)stringWithDirection:(OBJECT_QUOTEKLineDirection)direction {
    NSString *string = @"";
    switch (direction) {
        case OBJECT_QUOTEKLineDirection_KdForward:
            string = @"fw";
            break;
        case OBJECT_QUOTEKLineDirection_KdBackward:
            string = @"bw";
            break;
        case OBJECT_QUOTEKLineDirection_KdNone:
            string = @"none";
            break;
        default:
            break;
    }
    return string;
}

+ (NSString *)stringWithScene:(OBJECT_QUOTEQuoteScene)scene{
    NSString *string = @"";
    switch (scene) {
        case OBJECT_QUOTEQuoteScene_QsFull:
            string = @"full";
            break;
        case OBJECT_QUOTEQuoteScene_QsMobileBrief1:
            string = @"mobile_brf1";
            break;
        case OBJECT_QUOTEQuoteScene_QsDesktopBrief1:
            string = @"desktop_brf1";
            break;
        case OBJECT_QUOTEQuoteScene_QsCustom:
            string = @"CUSTOM_FLAG";
            break;
        default:
            break;
    }
    return string;
}

+ (NSString *)stringWithDepthType:(YXSocketDepthType)depthType {
    NSString *string = @"";
    switch (depthType) {
        case YXSocketDepthTypeMerge:
            string = @"merge";
            break;
        case YXSocketDepthTypeChart:
            string = @"chart";
            break;
        default:
            break;
    }
    return string;
}

@end
