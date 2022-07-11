// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: errcode.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import <stdatomic.h>

#import "Errcode.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - COMMONErrcodeRoot

@implementation COMMONErrcodeRoot

// No extensions in the file and no imports, so no need to generate
// +extensionRegistry.

@end

#pragma mark - Enum COMMONERR

GPBEnumDescriptor *COMMONERR_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Ok\000ParamNotExist\000ParamType\000ParamValInval"
        "id\000ParseConfig\000Sys\000RequestHeader\000DbSelec"
        "t\000JsonMarshal\000JsonUnmarshal\000RedisOper\000Se"
        "rviceDiscovery\000RequestNewsdetail\000";
    static const int32_t values[] = {
        COMMONERR_Ok,
        COMMONERR_ParamNotExist,
        COMMONERR_ParamType,
        COMMONERR_ParamValInvalid,
        COMMONERR_ParseConfig,
        COMMONERR_Sys,
        COMMONERR_RequestHeader,
        COMMONERR_DbSelect,
        COMMONERR_JsonMarshal,
        COMMONERR_JsonUnmarshal,
        COMMONERR_RedisOper,
        COMMONERR_ServiceDiscovery,
        COMMONERR_RequestNewsdetail,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(COMMONERR)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:COMMONERR_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL COMMONERR_IsValidValue(int32_t value__) {
  switch (value__) {
    case COMMONERR_Ok:
    case COMMONERR_ParamNotExist:
    case COMMONERR_ParamType:
    case COMMONERR_ParamValInvalid:
    case COMMONERR_ParseConfig:
    case COMMONERR_Sys:
    case COMMONERR_RequestHeader:
    case COMMONERR_DbSelect:
    case COMMONERR_JsonMarshal:
    case COMMONERR_JsonUnmarshal:
    case COMMONERR_RedisOper:
    case COMMONERR_ServiceDiscovery:
    case COMMONERR_RequestNewsdetail:
      return YES;
    default:
      return NO;
  }
}


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
