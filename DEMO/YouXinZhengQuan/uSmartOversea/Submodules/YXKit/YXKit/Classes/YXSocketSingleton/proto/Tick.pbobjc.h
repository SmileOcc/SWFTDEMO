// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: tick.proto

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

@class OBJECT_QUOTETickData;
@class OBJECT_SECUFullID;
GPB_ENUM_FWD_DECLARE(OBJECT_MARKETExchange);

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum OBJECT_QUOTETickDirection

/** Tick买卖方向 */
typedef GPB_ENUM(OBJECT_QUOTETickDirection) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  OBJECT_QUOTETickDirection_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  OBJECT_QUOTETickDirection_TdBoth = 0,
  OBJECT_QUOTETickDirection_TdBid = 1,
  OBJECT_QUOTETickDirection_TdAsk = 2,
};

GPBEnumDescriptor *OBJECT_QUOTETickDirection_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL OBJECT_QUOTETickDirection_IsValidValue(int32_t value);

#pragma mark - OBJECT_QUOTETickRoot

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
GPB_FINAL @interface OBJECT_QUOTETickRoot : GPBRootObject
@end

#pragma mark - OBJECT_QUOTETick

typedef GPB_ENUM(OBJECT_QUOTETick_FieldNumber) {
  OBJECT_QUOTETick_FieldNumber_Id_p = 1,
  OBJECT_QUOTETick_FieldNumber_PriceBase = 2,
  OBJECT_QUOTETick_FieldNumber_Data_p = 3,
};

GPB_FINAL @interface OBJECT_QUOTETick : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) OBJECT_SECUFullID *id_p;
/** Test to see if @c id_p has been set. */
@property(nonatomic, readwrite) BOOL hasId_p;

/** 价格小数计算基数，10的幂次表示 */
@property(nonatomic, readwrite) uint32_t priceBase;

@property(nonatomic, readwrite, strong, null_resettable) OBJECT_QUOTETickData *data_p;
/** Test to see if @c data_p has been set. */
@property(nonatomic, readwrite) BOOL hasData_p;

@end

#pragma mark - OBJECT_QUOTETickData

typedef GPB_ENUM(OBJECT_QUOTETickData_FieldNumber) {
  OBJECT_QUOTETickData_FieldNumber_Id_p = 1,
  OBJECT_QUOTETickData_FieldNumber_Time = 2,
  OBJECT_QUOTETickData_FieldNumber_Price = 3,
  OBJECT_QUOTETickData_FieldNumber_Volume = 4,
  OBJECT_QUOTETickData_FieldNumber_Direction = 5,
  OBJECT_QUOTETickData_FieldNumber_Tick = 6,
  OBJECT_QUOTETickData_FieldNumber_BidOrderNo = 8,
  OBJECT_QUOTETickData_FieldNumber_BidOrderSize = 9,
  OBJECT_QUOTETickData_FieldNumber_AskOrderNo = 10,
  OBJECT_QUOTETickData_FieldNumber_AskOrderSize = 11,
  OBJECT_QUOTETickData_FieldNumber_TrdType = 12,
  OBJECT_QUOTETickData_FieldNumber_Exchange = 13,
};

/**
 * 分笔行情数据
 **/
GPB_FINAL @interface OBJECT_QUOTETickData : GPBMessage

/** 对于客户端请求，用于区分同一时间内不同的分笔数据，同一时间内递增 */
@property(nonatomic, readwrite) uint64_t id_p;

/** 时间, 表示格式93015(时分秒) */
@property(nonatomic, readwrite) uint64_t time;

/** 现价 */
@property(nonatomic, readwrite) int64_t price;

/** 现量 */
@property(nonatomic, readwrite) uint64_t volume;

/** 方向 */
@property(nonatomic, readwrite) OBJECT_QUOTETickDirection direction;

/** 成交笔数 */
@property(nonatomic, readwrite) uint32_t tick;

@property(nonatomic, readwrite) int64_t bidOrderNo;

@property(nonatomic, readwrite) uint64_t bidOrderSize;

@property(nonatomic, readwrite) int64_t askOrderNo;

@property(nonatomic, readwrite) uint64_t askOrderSize;

/** tick交易类型，港股、美股有,参考港交所50号消息TrdType字段，数值与类型之间的对应关系为：0:<space> 4:P 22:M 100:Y 101:X 102:D 103:U */
@property(nonatomic, readwrite) uint32_t trdType;

@property(nonatomic, readwrite) enum OBJECT_MARKETExchange exchange;

@end

/**
 * Fetches the raw value of a @c OBJECT_QUOTETickData's @c direction property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t OBJECT_QUOTETickData_Direction_RawValue(OBJECT_QUOTETickData *message);
/**
 * Sets the raw value of an @c OBJECT_QUOTETickData's @c direction property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetOBJECT_QUOTETickData_Direction_RawValue(OBJECT_QUOTETickData *message, int32_t value);

/**
 * Fetches the raw value of a @c OBJECT_QUOTETickData's @c exchange property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t OBJECT_QUOTETickData_Exchange_RawValue(OBJECT_QUOTETickData *message);
/**
 * Sets the raw value of an @c OBJECT_QUOTETickData's @c exchange property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetOBJECT_QUOTETickData_Exchange_RawValue(OBJECT_QUOTETickData *message, int32_t value);

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)