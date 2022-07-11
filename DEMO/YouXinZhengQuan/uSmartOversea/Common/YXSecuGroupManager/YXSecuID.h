#import <Foundation/Foundation.h>
#import "YXSecuIDProtocol.h"

//#define kYXMarketHK @"hk"
//#define kYXMarketUS @"us"
//#define kYXMarketChinaSH @"sh"
//#define kYXMarketChinaSZ @"sz"
//#define kYXMarketChinaHS @"hs"
//#define kYXMarketChina @"cn"
//#define kYXMarketUsOption @"usoption"
//#define kYXAllMarket @[kYXMarketHK, kYXMarketUS, kYXMarketChinaSH, kYXMarketChinaSZ, kYXMarketUsOption]

typedef NS_ENUM(NSUInteger, YXMarketType) {
    YXMarketTypeNone,
    YXMarketTypeHongKong,
    YXMarketTypeUnitedStates,
    YXMarketTypeChina,
    YXMarketTypeSingapore
};

typedef NS_ENUM(NSUInteger, YXSecuType) {
    YXSecuTypeStock,
    YXSecuTypeOption
};

NS_ASSUME_NONNULL_BEGIN

@interface YXSecuID : NSObject<YXSecuIDProtocol>

@property (nonatomic, assign) NSUInteger sort; // 在全部里的位置index

+ (instancetype)secuIdWithMarket:(NSString *)market symbol:(NSString *)symbol;
+ (instancetype)secuIdWithString:(NSString *)string;

- (YXMarketType)marketType;
- (YXSecuType)secuType;
- (NSString *)marketIcon;
- (NSString *)description;
- (NSString *)ID;

@end

NS_ASSUME_NONNULL_END
