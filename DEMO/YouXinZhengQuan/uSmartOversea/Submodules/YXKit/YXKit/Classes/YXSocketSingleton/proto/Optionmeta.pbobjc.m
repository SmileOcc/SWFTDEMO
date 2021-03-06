// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: optionmeta.proto

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

#import "Optionmeta.pbobjc.h"
#import "Market.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - OBJECT_SECUOptionmetaRoot

@implementation OBJECT_SECUOptionmetaRoot

// No extensions in the file and none of the imports (direct or indirect)
// defined extensions, so no need to generate +extensionRegistry.

@end

#pragma mark - OBJECT_SECUOptionmetaRoot_FileDescriptor

static GPBFileDescriptor *OBJECT_SECUOptionmetaRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"yx.quote.v2.object.secu"
                                                 objcPrefix:@"OBJECT_SECU"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - OBJECT_SECUOptionMeta

@implementation OBJECT_SECUOptionMeta

@dynamic market;
@dynamic underlying;
@dynamic callNums;
@dynamic putNums;
@dynamic nums;

typedef struct OBJECT_SECUOptionMeta__storage_ {
  uint32_t _has_storage_[1];
  OBJECT_MARKETMarketId market;
  int32_t callNums;
  int32_t putNums;
  int32_t nums;
  NSString *underlying;
} OBJECT_SECUOptionMeta__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "market",
        .dataTypeSpecific.enumDescFunc = OBJECT_MARKETMarketId_EnumDescriptor,
        .number = OBJECT_SECUOptionMeta_FieldNumber_Market,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(OBJECT_SECUOptionMeta__storage_, market),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "underlying",
        .dataTypeSpecific.clazz = Nil,
        .number = OBJECT_SECUOptionMeta_FieldNumber_Underlying,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(OBJECT_SECUOptionMeta__storage_, underlying),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "callNums",
        .dataTypeSpecific.clazz = Nil,
        .number = OBJECT_SECUOptionMeta_FieldNumber_CallNums,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(OBJECT_SECUOptionMeta__storage_, callNums),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "putNums",
        .dataTypeSpecific.clazz = Nil,
        .number = OBJECT_SECUOptionMeta_FieldNumber_PutNums,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(OBJECT_SECUOptionMeta__storage_, putNums),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "nums",
        .dataTypeSpecific.clazz = Nil,
        .number = OBJECT_SECUOptionMeta_FieldNumber_Nums,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(OBJECT_SECUOptionMeta__storage_, nums),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[OBJECT_SECUOptionMeta class]
                                     rootClass:[OBJECT_SECUOptionmetaRoot class]
                                          file:OBJECT_SECUOptionmetaRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(OBJECT_SECUOptionMeta__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\002\003\010\000\004\007\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t OBJECT_SECUOptionMeta_Market_RawValue(OBJECT_SECUOptionMeta *message) {
  GPBDescriptor *descriptor = [OBJECT_SECUOptionMeta descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:OBJECT_SECUOptionMeta_FieldNumber_Market];
  return GPBGetMessageRawEnumField(message, field);
}

void SetOBJECT_SECUOptionMeta_Market_RawValue(OBJECT_SECUOptionMeta *message, int32_t value) {
  GPBDescriptor *descriptor = [OBJECT_SECUOptionMeta descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:OBJECT_SECUOptionMeta_FieldNumber_Market];
  GPBSetMessageRawEnumField(message, field, value);
}

#pragma mark - OBJECT_SECUOptionBasicInfo

@implementation OBJECT_SECUOptionBasicInfo

@dynamic market;
@dynamic underlying;
@dynamic code;
@dynamic lotSize;

typedef struct OBJECT_SECUOptionBasicInfo__storage_ {
  uint32_t _has_storage_[1];
  OBJECT_MARKETMarketId market;
  NSString *underlying;
  NSString *code;
  int64_t lotSize;
} OBJECT_SECUOptionBasicInfo__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "market",
        .dataTypeSpecific.enumDescFunc = OBJECT_MARKETMarketId_EnumDescriptor,
        .number = OBJECT_SECUOptionBasicInfo_FieldNumber_Market,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(OBJECT_SECUOptionBasicInfo__storage_, market),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "underlying",
        .dataTypeSpecific.clazz = Nil,
        .number = OBJECT_SECUOptionBasicInfo_FieldNumber_Underlying,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(OBJECT_SECUOptionBasicInfo__storage_, underlying),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "code",
        .dataTypeSpecific.clazz = Nil,
        .number = OBJECT_SECUOptionBasicInfo_FieldNumber_Code,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(OBJECT_SECUOptionBasicInfo__storage_, code),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "lotSize",
        .dataTypeSpecific.clazz = Nil,
        .number = OBJECT_SECUOptionBasicInfo_FieldNumber_LotSize,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(OBJECT_SECUOptionBasicInfo__storage_, lotSize),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom | GPBFieldClearHasIvarOnZero),
        .dataType = GPBDataTypeInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[OBJECT_SECUOptionBasicInfo class]
                                     rootClass:[OBJECT_SECUOptionmetaRoot class]
                                          file:OBJECT_SECUOptionmetaRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(OBJECT_SECUOptionBasicInfo__storage_)
                                         flags:(GPBDescriptorInitializationFlags)(GPBDescriptorInitializationFlag_UsesClassRefs | GPBDescriptorInitializationFlag_Proto3OptionalKnown)];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\004\007\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t OBJECT_SECUOptionBasicInfo_Market_RawValue(OBJECT_SECUOptionBasicInfo *message) {
  GPBDescriptor *descriptor = [OBJECT_SECUOptionBasicInfo descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:OBJECT_SECUOptionBasicInfo_FieldNumber_Market];
  return GPBGetMessageRawEnumField(message, field);
}

void SetOBJECT_SECUOptionBasicInfo_Market_RawValue(OBJECT_SECUOptionBasicInfo *message, int32_t value) {
  GPBDescriptor *descriptor = [OBJECT_SECUOptionBasicInfo descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:OBJECT_SECUOptionBasicInfo_FieldNumber_Market];
  GPBSetMessageRawEnumField(message, field, value);
}


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
