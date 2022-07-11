// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: market.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30004
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30004 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum OBJECT_MARKETMarketId

/** 由于市场id会带给前端为小写，这里定义时也用小写字符，不然后续得专门转换 */
typedef GPB_ENUM(OBJECT_MARKETMarketId) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  OBJECT_MARKETMarketId_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  /** 未知 */
  OBJECT_MARKETMarketId_None = 0,

  /** 上海市场 */
  OBJECT_MARKETMarketId_Sh = 1,

  /** 深圳市场 */
  OBJECT_MARKETMarketId_Sz = 2,

  /** 香港市场 */
  OBJECT_MARKETMarketId_Hk = 3,

  /** 美国市场 */
  OBJECT_MARKETMarketId_Us = 4,

  /** 新加坡 */
  OBJECT_MARKETMarketId_Sg = 5,

  /** 港期货(目前是恒指的当月、下月期货行情) */
  OBJECT_MARKETMarketId_Hkfuture = 11,

  /** 美期权 */
  OBJECT_MARKETMarketId_Usoption = 12,

  /** 数字货币 */
  OBJECT_MARKETMarketId_Cryptos = 13,
};

GPBEnumDescriptor *OBJECT_MARKETMarketId_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL OBJECT_MARKETMarketId_IsValidValue(int32_t value);

#pragma mark - Enum OBJECT_MARKETExchange

/** 交易所 */
typedef GPB_ENUM(OBJECT_MARKETExchange) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  OBJECT_MARKETExchange_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  OBJECT_MARKETExchange_ExchangeNone = 0,

  /** 上海证券交易所 */
  OBJECT_MARKETExchange_Sse = 101,

  /** 深圳证券交易所 */
  OBJECT_MARKETExchange_Szse = 102,

  /** 三板交易市场 */
  OBJECT_MARKETExchange_Neeq = 111,

  /** 香港联合交易所 */
  OBJECT_MARKETExchange_Hkex = 201,

  /** 美国纳斯达克证券交易所, Nasdaq Stock Market */
  OBJECT_MARKETExchange_Nasdaq = 301,

  /** 纽约证券交易所, NEw York Stock Exchange */
  OBJECT_MARKETExchange_Nyse = 302,

  /** 增长板市场ARCA, NYSE Arca */
  OBJECT_MARKETExchange_Arca = 303,

  /** AMEX, NYSE American */
  OBJECT_MARKETExchange_Amex = 304,
  OBJECT_MARKETExchange_Bats = 305,
  OBJECT_MARKETExchange_Otc = 306,

  /** Investors’　Exchange（IEX） */
  OBJECT_MARKETExchange_Iex = 308,

  /** Financial Industry Regulatory Authority */
  OBJECT_MARKETExchange_Finra = 309,

  /** Cboe EDGX Exchange */
  OBJECT_MARKETExchange_Edgx = 310,

  /** Cboe BZX Exchange */
  OBJECT_MARKETExchange_Bzx = 311,

  /** Members Exchange */
  OBJECT_MARKETExchange_Memx = 312,

  /** Nasdaq BX */
  OBJECT_MARKETExchange_Bx = 313,

  /** Cboe EDGA Exchange */
  OBJECT_MARKETExchange_Edga = 314,

  /** Philadelphia Stock Exchange (PHLX) */
  OBJECT_MARKETExchange_Psx = 315,

  /** Cboe BYX Exchange */
  OBJECT_MARKETExchange_Byx = 316,

  /** NYSE National */
  OBJECT_MARKETExchange_Nsx = 317,

  /** MIAX Pearl */
  OBJECT_MARKETExchange_Miax = 318,

  /** NYSE Chicago */
  OBJECT_MARKETExchange_Chx = 319,

  /** 新加坡股票交易所 */
  OBJECT_MARKETExchange_Sgx = 401,

  /**
   *
   * us option exchange
   **/
  OBJECT_MARKETExchange_Aoe = 1000,

  /**  Philadelphia Options Exchange */
  OBJECT_MARKETExchange_Pho = 1001,

  /**  NYSE Arca Options */
  OBJECT_MARKETExchange_Pao = 1002,

  /**  Chicago Board Options Exchange */
  OBJECT_MARKETExchange_Wcb = 1003,

  /**  International Securities Exchange */
  OBJECT_MARKETExchange_Iso = 1004,

  /**  Boston Options Exchange */
  OBJECT_MARKETExchange_Box = 1005,

  /**  Options Price Reporting Authority BBO */
  OBJECT_MARKETExchange_Opq = 1006,

  /**  NASDAQ Options Market, LLC */
  OBJECT_MARKETExchange_Nox = 1007,

  /**  Cboe C2 Options Exchange */
  OBJECT_MARKETExchange_C2E = 1008,

  /**  Cboe BZX Options Exchange */
  OBJECT_MARKETExchange_Btx = 1009,

  /**  Miami Options Exchange */
  OBJECT_MARKETExchange_Mia = 1010,

  /**  NASDAQ OMX BX Options Exchange */
  OBJECT_MARKETExchange_Nbz = 1011,

  /**  Nasdaq Gemini */
  OBJECT_MARKETExchange_Isz = 1012,

  /**  Nasdaq Mercury */
  OBJECT_MARKETExchange_Isj = 1013,

  /**  Cboe EDGX Options Exchange */
  OBJECT_MARKETExchange_Bex = 1014,

  /**  MIAX Pearl Options Exchange */
  OBJECT_MARKETExchange_Mpo = 1015,

  /**  MIAX EMERALD OPTIONS EXCHANGE */
  OBJECT_MARKETExchange_Mix = 1016,

  /**
   *
   * The following faked exchange definition should only
   * be used by parser
   **/
  OBJECT_MARKETExchange_Otcpk = 2000,

  /** for 0#BULLETIN.PK */
  OBJECT_MARKETExchange_Otcbb = 2001,
  OBJECT_MARKETExchange_Alletf = 2002,

  /** for 0#OPRA-A ~ 0#OPRA-Z */
  OBJECT_MARKETExchange_Cboe = 2003,

  /** for nyse arcabook level 2 */
  OBJECT_MARKETExchange_Arcabook = 2004,

  /** for nyse openbook level 2 */
  OBJECT_MARKETExchange_Openbook = 2005,

  /** for nasdaq total view level2 */
  OBJECT_MARKETExchange_Totolview = 2006,

  /** for ice source id identification */
  OBJECT_MARKETExchange_Dji = 3000,

  /** Nasdaq Global Indices (GIDS) */
  OBJECT_MARKETExchange_Comp = 3001,

  /** Chicago Mercantile Exchange Standard and Poor's Indices (CME Sourced) */
  OBJECT_MARKETExchange_Sp500 = 3002,

  /** 币安交易所 */
  OBJECT_MARKETExchange_Bn = 4000,
};

GPBEnumDescriptor *OBJECT_MARKETExchange_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL OBJECT_MARKETExchange_IsValidValue(int32_t value);

#pragma mark - Enum OBJECT_MARKETListedSector

/** 上市板块 */
typedef GPB_ENUM(OBJECT_MARKETListedSector) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  OBJECT_MARKETListedSector_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  OBJECT_MARKETListedSector_LsNone = 0,

  /** 主板，港股主板(MAIN) */
  OBJECT_MARKETListedSector_LsMain = 1,

  /** 中小企业板 Small and Medium Enterprise Board */
  OBJECT_MARKETListedSector_LsSmeb = 2,

  /** 创业板 Growth Enterprises Market Board，港股创业板(GEM) */
  OBJECT_MARKETListedSector_LsGemb = 3,

  /** 新三板 National Equities Exchange and Quotations */
  OBJECT_MARKETListedSector_LsStb = 4,

  /** 凯利板块 */
  OBJECT_MARKETListedSector_LsCatalist = 5,

  /** 科创板 */
  OBJECT_MARKETListedSector_LsStar = 12,

  /** 港股 */
  OBJECT_MARKETListedSector_LsNasd = 21,

  /** 港股(ETS)，OMD-C 10号消息 */
  OBJECT_MARKETListedSector_LsEts = 22,
};

GPBEnumDescriptor *OBJECT_MARKETListedSector_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL OBJECT_MARKETListedSector_IsValidValue(int32_t value);

#pragma mark - Enum OBJECT_MARKETMarketStatus

/** 市场状态 */
typedef GPB_ENUM(OBJECT_MARKETMarketStatus) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  OBJECT_MARKETMarketStatus_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  /** 未知 */
  OBJECT_MARKETMarketStatus_MsUnknown = 0,

  /** 启动、开市前 */
  OBJECT_MARKETMarketStatus_MsStart = 1,

  /** 开盘集合竞价  9:15-9:25 */
  OBJECT_MARKETMarketStatus_MsOpenCall = 2,

  /** 暂停     9:25-9:30，港股 09:28 - 09:30 */
  OBJECT_MARKETMarketStatus_MsBlocking = 3,

  /** 连续竞价  9:30-11:30,13:00-15:00，深交所14:57-15:00除外 */
  OBJECT_MARKETMarketStatus_MsTrading = 4,

  /** 午间休市  11:30-13:00 */
  OBJECT_MARKETMarketStatus_MsBreak = 5,

  /** 收盘集合竞价 深交所14:57-15:00 */
  OBJECT_MARKETMarketStatus_MsCloseCall = 6,

  /** 已收盘    15:00-7b:00 */
  OBJECT_MARKETMarketStatus_MsClose = 7,

  /**
   * 港股特有状态
   * 以下三个状态为港股开盘集合竞价时段
   **/
  OBJECT_MARKETMarketStatus_MsOcOrderInput = 20,

  /** 对盘前 09:15 - 09:20 */
  OBJECT_MARKETMarketStatus_MsOcPreOrderMatch = 21,

  /** 对盘 09:20 - 09:28 */
  OBJECT_MARKETMarketStatus_MsOcOrderMatch = 22,

  /** 以下四个状态为港股收盘集合竞价 */
  OBJECT_MARKETMarketStatus_MsCcRefPriceFixing = 23,

  /** 输入买卖盘 */
  OBJECT_MARKETMarketStatus_MsCcOrderInput = 24,

  /** 不可取消 */
  OBJECT_MARKETMarketStatus_MsCcNoCancel = 25,

  /** 随机收市 */
  OBJECT_MARKETMarketStatus_MsCcRandomClosing = 26,

  /** 对盘 */
  OBJECT_MARKETMarketStatus_MsCcOrderMatch = 27,

  /** 以下为美股所有 */
  OBJECT_MARKETMarketStatus_MsPreHours = 31,

  /** 盘后 */
  OBJECT_MARKETMarketStatus_MsAfterHours = 32,

  /** 夜市开盘 */
  OBJECT_MARKETMarketStatus_MsNightOpen = 41,

  /** 夜市收盘 */
  OBJECT_MARKETMarketStatus_MsNightEnd = 42,

  /** 期指日市开盘 */
  OBJECT_MARKETMarketStatus_MsFutureDayOpen = 51,

  /** 期指日市休市 */
  OBJECT_MARKETMarketStatus_MsFutureDayBreak = 52,

  /** 期指日市收盘 */
  OBJECT_MARKETMarketStatus_MsFutureDayClose = 53,

  /** 期指日市等待开盘 */
  OBJECT_MARKETMarketStatus_MsFutureDayWaitForopen = 54,

  /** 暗盘未开盘 */
  OBJECT_MARKETMarketStatus_MsGreyPreOpen = 55,

  /** 暗盘交易中 */
  OBJECT_MARKETMarketStatus_MsGreyOpen = 56,

  /** 暗盘已收盘 */
  OBJECT_MARKETMarketStatus_MsGreyAfterOpen = 57,

  /** A股科创版，创业板 */
  OBJECT_MARKETMarketStatus_MsKcMatchingPeriod = 61,

  /** 固定价格交易 */
  OBJECT_MARKETMarketStatus_MsKcFixedPriceTrading = 62,
};

GPBEnumDescriptor *OBJECT_MARKETMarketStatus_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL OBJECT_MARKETMarketStatus_IsValidValue(int32_t value);

#pragma mark - Enum OBJECT_MARKETLanguage

typedef GPB_ENUM(OBJECT_MARKETLanguage) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  OBJECT_MARKETLanguage_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  /** 无效值 */
  OBJECT_MARKETLanguage_LangNone = 0,

  /** 中文简体 */
  OBJECT_MARKETLanguage_LangZhs = 1,

  /** 中文繁体 */
  OBJECT_MARKETLanguage_LangZht = 2,

  /** 英文 */
  OBJECT_MARKETLanguage_LangEng = 3,
};

GPBEnumDescriptor *OBJECT_MARKETLanguage_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL OBJECT_MARKETLanguage_IsValidValue(int32_t value);

#pragma mark - OBJECT_MARKETMarketRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
GPB_FINAL @interface OBJECT_MARKETMarketRoot : GPBRootObject
@end

#pragma mark - OBJECT_MARKETStatus

typedef GPB_ENUM(OBJECT_MARKETStatus_FieldNumber) {
  OBJECT_MARKETStatus_FieldNumber_MktTime = 1,
  OBJECT_MARKETStatus_FieldNumber_Market = 2,
  OBJECT_MARKETStatus_FieldNumber_Status = 3,
};

GPB_FINAL @interface OBJECT_MARKETStatus : GPBMessage

@property(nonatomic, readwrite) uint64_t mktTime;

@property(nonatomic, readwrite) OBJECT_MARKETMarketId market;

@property(nonatomic, readwrite) OBJECT_MARKETMarketStatus status;

@end

/**
 * Fetches the raw value of a @c OBJECT_MARKETStatus's @c market property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t OBJECT_MARKETStatus_Market_RawValue(OBJECT_MARKETStatus *message);
/**
 * Sets the raw value of an @c OBJECT_MARKETStatus's @c market property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetOBJECT_MARKETStatus_Market_RawValue(OBJECT_MARKETStatus *message, int32_t value);

/**
 * Fetches the raw value of a @c OBJECT_MARKETStatus's @c status property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t OBJECT_MARKETStatus_Status_RawValue(OBJECT_MARKETStatus *message);
/**
 * Sets the raw value of an @c OBJECT_MARKETStatus's @c status property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetOBJECT_MARKETStatus_Status_RawValue(OBJECT_MARKETStatus *message, int32_t value);

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)