// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: cryptos.proto

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

@class OBJECT_QUOTECryptosInfo;
@class OBJECT_QUOTECryptosOrderBook;
@class OBJECT_QUOTECryptosOrderBookItem;
@class OBJECT_QUOTECryptosRealtime;
@class OBJECT_QUOTEMarketStatusInfo;
@class OBJECT_SECUFullID;
@class OBJECT_SECUSecurityName;
GPB_ENUM_FWD_DECLARE(OBJECT_QUOTETradingStatus);
GPB_ENUM_FWD_DECLARE(OBJECT_SECUSecuType1);
GPB_ENUM_FWD_DECLARE(OBJECT_SECUSecuType2);
GPB_ENUM_FWD_DECLARE(OBJECT_SECUSecuType3);

NS_ASSUME_NONNULL_BEGIN

#pragma mark - OBJECT_QUOTECryptosRoot

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
GPB_FINAL @interface OBJECT_QUOTECryptosRoot : GPBRootObject
@end

#pragma mark - OBJECT_QUOTECryptosKline

typedef GPB_ENUM(OBJECT_QUOTECryptosKline_FieldNumber) {
  OBJECT_QUOTECryptosKline_FieldNumber_LatestTime = 1,
  OBJECT_QUOTECryptosKline_FieldNumber_Open = 3,
  OBJECT_QUOTECryptosKline_FieldNumber_High = 4,
  OBJECT_QUOTECryptosKline_FieldNumber_Low = 5,
  OBJECT_QUOTECryptosKline_FieldNumber_Close = 6,
  OBJECT_QUOTECryptosKline_FieldNumber_Amount = 7,
  OBJECT_QUOTECryptosKline_FieldNumber_Volume = 8,
  OBJECT_QUOTECryptosKline_FieldNumber_PreClose = 9,
  OBJECT_QUOTECryptosKline_FieldNumber_Netchng = 10,
  OBJECT_QUOTECryptosKline_FieldNumber_Pctchng = 11,
};

/**
 * K???, ?????????K???????????? 1d
 **/
GPB_FINAL @interface OBJECT_QUOTECryptosKline : GPBMessage

/** ???????????? */
@property(nonatomic, readwrite) uint64_t latestTime;

/** ?????????????????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *open;

/** ???????????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *high;

/** ???????????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *low;

/** ???????????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *close;

/** ??????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *amount;

/** ??????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *volume;

/** ?????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *preClose;

/** ????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *netchng;

/** ????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *pctchng;

@end

#pragma mark - OBJECT_QUOTECryptosInfo

typedef GPB_ENUM(OBJECT_QUOTECryptosInfo_FieldNumber) {
  OBJECT_QUOTECryptosInfo_FieldNumber_BaseAsset = 1,
  OBJECT_QUOTECryptosInfo_FieldNumber_QuoteAsset = 2,
  OBJECT_QUOTECryptosInfo_FieldNumber_BasePrecision = 3,
  OBJECT_QUOTECryptosInfo_FieldNumber_QuotePrecision = 4,
  OBJECT_QUOTECryptosInfo_FieldNumber_Name = 5,
  OBJECT_QUOTECryptosInfo_FieldNumber_Type1 = 6,
  OBJECT_QUOTECryptosInfo_FieldNumber_Type2 = 7,
  OBJECT_QUOTECryptosInfo_FieldNumber_Type3 = 8,
  OBJECT_QUOTECryptosInfo_FieldNumber_SecuNamesArray = 9,
  OBJECT_QUOTECryptosInfo_FieldNumber_IconURL = 10,
  OBJECT_QUOTECryptosInfo_FieldNumber_DisplayedSymbol = 11,
};

GPB_FINAL @interface OBJECT_QUOTECryptosInfo : GPBMessage

/** ????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *baseAsset;

/** ??????????????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *quoteAsset;

/** ????????????????????????????????? */
@property(nonatomic, readwrite) int32_t basePrecision;

/** ??????????????????????????????????????????????????? */
@property(nonatomic, readwrite) int32_t quotePrecision;

/** ?????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *name;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<OBJECT_SECUSecurityName*> *secuNamesArray;
/** The number of items in @c secuNamesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger secuNamesArray_Count;

/** ???????????? */
@property(nonatomic, readwrite) enum OBJECT_SECUSecuType1 type1;

/** ???????????? */
@property(nonatomic, readwrite) enum OBJECT_SECUSecuType2 type2;

/** ???????????? */
@property(nonatomic, readwrite) enum OBJECT_SECUSecuType3 type3;

/** ???????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *iconURL;

/** ????????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *displayedSymbol;

@end

/**
 * Fetches the raw value of a @c OBJECT_QUOTECryptosInfo's @c type1 property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t OBJECT_QUOTECryptosInfo_Type1_RawValue(OBJECT_QUOTECryptosInfo *message);
/**
 * Sets the raw value of an @c OBJECT_QUOTECryptosInfo's @c type1 property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetOBJECT_QUOTECryptosInfo_Type1_RawValue(OBJECT_QUOTECryptosInfo *message, int32_t value);

/**
 * Fetches the raw value of a @c OBJECT_QUOTECryptosInfo's @c type2 property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t OBJECT_QUOTECryptosInfo_Type2_RawValue(OBJECT_QUOTECryptosInfo *message);
/**
 * Sets the raw value of an @c OBJECT_QUOTECryptosInfo's @c type2 property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetOBJECT_QUOTECryptosInfo_Type2_RawValue(OBJECT_QUOTECryptosInfo *message, int32_t value);

/**
 * Fetches the raw value of a @c OBJECT_QUOTECryptosInfo's @c type3 property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t OBJECT_QUOTECryptosInfo_Type3_RawValue(OBJECT_QUOTECryptosInfo *message);
/**
 * Sets the raw value of an @c OBJECT_QUOTECryptosInfo's @c type3 property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetOBJECT_QUOTECryptosInfo_Type3_RawValue(OBJECT_QUOTECryptosInfo *message, int32_t value);

#pragma mark - OBJECT_QUOTECryptosQuote

typedef GPB_ENUM(OBJECT_QUOTECryptosQuote_FieldNumber) {
  OBJECT_QUOTECryptosQuote_FieldNumber_Id_p = 1,
  OBJECT_QUOTECryptosQuote_FieldNumber_Realtime = 3,
  OBJECT_QUOTECryptosQuote_FieldNumber_OrderBook = 4,
  OBJECT_QUOTECryptosQuote_FieldNumber_MsInfo = 14,
  OBJECT_QUOTECryptosQuote_FieldNumber_Info = 16,
};

GPB_FINAL @interface OBJECT_QUOTECryptosQuote : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) OBJECT_SECUFullID *id_p;
/** Test to see if @c id_p has been set. */
@property(nonatomic, readwrite) BOOL hasId_p;

/** ???????????? */
@property(nonatomic, readwrite, strong, null_resettable) OBJECT_QUOTEMarketStatusInfo *msInfo;
/** Test to see if @c msInfo has been set. */
@property(nonatomic, readwrite) BOOL hasMsInfo;

/** ???????????? */
@property(nonatomic, readwrite, strong, null_resettable) OBJECT_QUOTECryptosInfo *info;
/** Test to see if @c info has been set. */
@property(nonatomic, readwrite) BOOL hasInfo;

/** ???????????? */
@property(nonatomic, readwrite, strong, null_resettable) OBJECT_QUOTECryptosRealtime *realtime;
/** Test to see if @c realtime has been set. */
@property(nonatomic, readwrite) BOOL hasRealtime;

/** ????????? */
@property(nonatomic, readwrite, strong, null_resettable) OBJECT_QUOTECryptosOrderBook *orderBook;
/** Test to see if @c orderBook has been set. */
@property(nonatomic, readwrite) BOOL hasOrderBook;

@end

#pragma mark - OBJECT_QUOTECryptosRealtime

typedef GPB_ENUM(OBJECT_QUOTECryptosRealtime_FieldNumber) {
  OBJECT_QUOTECryptosRealtime_FieldNumber_LatestTime = 1,
  OBJECT_QUOTECryptosRealtime_FieldNumber_High = 2,
  OBJECT_QUOTECryptosRealtime_FieldNumber_Low = 3,
  OBJECT_QUOTECryptosRealtime_FieldNumber_Now = 4,
  OBJECT_QUOTECryptosRealtime_FieldNumber_PreClose = 5,
  OBJECT_QUOTECryptosRealtime_FieldNumber_Open = 6,
  OBJECT_QUOTECryptosRealtime_FieldNumber_Avg = 7,
  OBJECT_QUOTECryptosRealtime_FieldNumber_Netchng = 8,
  OBJECT_QUOTECryptosRealtime_FieldNumber_Pctchng = 9,
  OBJECT_QUOTECryptosRealtime_FieldNumber_Amount = 10,
  OBJECT_QUOTECryptosRealtime_FieldNumber_Volume = 11,
  OBJECT_QUOTECryptosRealtime_FieldNumber_High52W = 12,
  OBJECT_QUOTECryptosRealtime_FieldNumber_Low52W = 13,
  OBJECT_QUOTECryptosRealtime_FieldNumber_TrdStatus = 15,
};

/**
 * 24????????????
 **/
GPB_FINAL @interface OBJECT_QUOTECryptosRealtime : GPBMessage

/** ???????????? */
@property(nonatomic, readwrite) uint64_t latestTime;

/** 24h?????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *high;

/** 24h?????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *low;

/** 24h?????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *now;

/** 24h???????????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *preClose;

/** 24h???????????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *open;

/** ???????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *avg;

/** 24h ??????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *netchng;

/** 24 ????????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *pctchng;

/** 24h????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *amount;

/** 24????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *volume;

/** 52?????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *high52W;

/** 52????????????????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *low52W;

/** ?????????????????? */
@property(nonatomic, readwrite) enum OBJECT_QUOTETradingStatus trdStatus;

@end

/**
 * Fetches the raw value of a @c OBJECT_QUOTECryptosRealtime's @c trdStatus property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t OBJECT_QUOTECryptosRealtime_TrdStatus_RawValue(OBJECT_QUOTECryptosRealtime *message);
/**
 * Sets the raw value of an @c OBJECT_QUOTECryptosRealtime's @c trdStatus property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetOBJECT_QUOTECryptosRealtime_TrdStatus_RawValue(OBJECT_QUOTECryptosRealtime *message, int32_t value);

#pragma mark - OBJECT_QUOTECryptosTick

typedef GPB_ENUM(OBJECT_QUOTECryptosTick_FieldNumber) {
  OBJECT_QUOTECryptosTick_FieldNumber_LatestTime = 1,
  OBJECT_QUOTECryptosTick_FieldNumber_Price = 2,
  OBJECT_QUOTECryptosTick_FieldNumber_Volume = 3,
  OBJECT_QUOTECryptosTick_FieldNumber_Direction = 4,
  OBJECT_QUOTECryptosTick_FieldNumber_Id_p = 5,
};

/**
 * ????????????
 **/
GPB_FINAL @interface OBJECT_QUOTECryptosTick : GPBMessage

/** ???????????? */
@property(nonatomic, readwrite) uint64_t latestTime;

/** ???????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *price;

/** ????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *volume;

/** ???????????? 0??? ???????????? 1??????????????????2??????????????? */
@property(nonatomic, readwrite) int32_t direction;

/** ??????ID */
@property(nonatomic, readwrite) int64_t id_p;

@end

#pragma mark - OBJECT_QUOTECryptosOrderBook

typedef GPB_ENUM(OBJECT_QUOTECryptosOrderBook_FieldNumber) {
  OBJECT_QUOTECryptosOrderBook_FieldNumber_ItemsArray = 1,
  OBJECT_QUOTECryptosOrderBook_FieldNumber_LatestTime = 2,
};

/**
 * ?????????
 **/
GPB_FINAL @interface OBJECT_QUOTECryptosOrderBook : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<OBJECT_QUOTECryptosOrderBookItem*> *itemsArray;
/** The number of items in @c itemsArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger itemsArray_Count;

/** ???????????? */
@property(nonatomic, readwrite) uint64_t latestTime;

@end

#pragma mark - OBJECT_QUOTECryptosOrderBookItem

typedef GPB_ENUM(OBJECT_QUOTECryptosOrderBookItem_FieldNumber) {
  OBJECT_QUOTECryptosOrderBookItem_FieldNumber_BidPrice = 2,
  OBJECT_QUOTECryptosOrderBookItem_FieldNumber_BidVolume = 3,
  OBJECT_QUOTECryptosOrderBookItem_FieldNumber_AskPrice = 4,
  OBJECT_QUOTECryptosOrderBookItem_FieldNumber_AskVolume = 5,
};

/**
 * ???????????????
 **/
GPB_FINAL @interface OBJECT_QUOTECryptosOrderBookItem : GPBMessage

/** ?????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *bidPrice;

/** ????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *bidVolume;

/** ?????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *askPrice;

/** ????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *askVolume;

@end

#pragma mark - OBJECT_QUOTECryptosTimeline

typedef GPB_ENUM(OBJECT_QUOTECryptosTimeline_FieldNumber) {
  OBJECT_QUOTECryptosTimeline_FieldNumber_LatestTime = 1,
  OBJECT_QUOTECryptosTimeline_FieldNumber_Price = 3,
  OBJECT_QUOTECryptosTimeline_FieldNumber_Avg = 4,
  OBJECT_QUOTECryptosTimeline_FieldNumber_Volume = 5,
  OBJECT_QUOTECryptosTimeline_FieldNumber_Amount = 6,
  OBJECT_QUOTECryptosTimeline_FieldNumber_Netchng = 7,
  OBJECT_QUOTECryptosTimeline_FieldNumber_Pctchng = 8,
};

/**
 * ??????????????????
 **/
GPB_FINAL @interface OBJECT_QUOTECryptosTimeline : GPBMessage

/** ?????????????????????YYYYMMDDHHMM(???????????????) */
@property(nonatomic, readwrite) uint64_t latestTime;

/** ????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *price;

/** ???????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *avg;

/** ????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *volume;

/** ???????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *amount;

/** ????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *netchng;

/** ????????? */
@property(nonatomic, readwrite, copy, null_resettable) NSString *pctchng;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
