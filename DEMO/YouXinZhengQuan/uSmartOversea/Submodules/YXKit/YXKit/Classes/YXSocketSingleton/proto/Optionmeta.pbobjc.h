// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: optionmeta.proto

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

GPB_ENUM_FWD_DECLARE(OBJECT_MARKETMarketId);

NS_ASSUME_NONNULL_BEGIN

#pragma mark - OBJECT_SECUOptionmetaRoot

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
GPB_FINAL @interface OBJECT_SECUOptionmetaRoot : GPBRootObject
@end

#pragma mark - OBJECT_SECUOptionMeta

typedef GPB_ENUM(OBJECT_SECUOptionMeta_FieldNumber) {
  OBJECT_SECUOptionMeta_FieldNumber_Market = 1,
  OBJECT_SECUOptionMeta_FieldNumber_Underlying = 2,
  OBJECT_SECUOptionMeta_FieldNumber_CallNums = 3,
  OBJECT_SECUOptionMeta_FieldNumber_PutNums = 4,
  OBJECT_SECUOptionMeta_FieldNumber_Nums = 5,
};

GPB_FINAL @interface OBJECT_SECUOptionMeta : GPBMessage

/** 市场 */
@property(nonatomic, readwrite) enum OBJECT_MARKETMarketId market;

/** 正股代码 */
@property(nonatomic, readwrite, copy, null_resettable) NSString *underlying;

@property(nonatomic, readwrite) int32_t callNums;

@property(nonatomic, readwrite) int32_t putNums;

@property(nonatomic, readwrite) int32_t nums;

@end

/**
 * Fetches the raw value of a @c OBJECT_SECUOptionMeta's @c market property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t OBJECT_SECUOptionMeta_Market_RawValue(OBJECT_SECUOptionMeta *message);
/**
 * Sets the raw value of an @c OBJECT_SECUOptionMeta's @c market property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetOBJECT_SECUOptionMeta_Market_RawValue(OBJECT_SECUOptionMeta *message, int32_t value);

#pragma mark - OBJECT_SECUOptionBasicInfo

typedef GPB_ENUM(OBJECT_SECUOptionBasicInfo_FieldNumber) {
  OBJECT_SECUOptionBasicInfo_FieldNumber_Market = 1,
  OBJECT_SECUOptionBasicInfo_FieldNumber_Underlying = 2,
  OBJECT_SECUOptionBasicInfo_FieldNumber_Code = 3,
  OBJECT_SECUOptionBasicInfo_FieldNumber_LotSize = 4,
};

GPB_FINAL @interface OBJECT_SECUOptionBasicInfo : GPBMessage

/** 市场 */
@property(nonatomic, readwrite) enum OBJECT_MARKETMarketId market;

/** 正股代码 */
@property(nonatomic, readwrite, copy, null_resettable) NSString *underlying;

/** 期权代码 */
@property(nonatomic, readwrite, copy, null_resettable) NSString *code;

/** 每手股数 */
@property(nonatomic, readwrite) int64_t lotSize;

@end

/**
 * Fetches the raw value of a @c OBJECT_SECUOptionBasicInfo's @c market property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t OBJECT_SECUOptionBasicInfo_Market_RawValue(OBJECT_SECUOptionBasicInfo *message);
/**
 * Sets the raw value of an @c OBJECT_SECUOptionBasicInfo's @c market property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetOBJECT_SECUOptionBasicInfo_Market_RawValue(OBJECT_SECUOptionBasicInfo *message, int32_t value);

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
