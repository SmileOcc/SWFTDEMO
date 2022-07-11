//
//  YXSocketConfig.h
//  Pods
//
//  Created by 付迪宇 on 2019/8/23.
//

#ifndef YXSocketConfig_h
#define YXSocketConfig_h


#endif /* YXSocketConfig_h */

/**
 控制命令字
 
 - YXSocketCommandTypeShakeHands: 握手命令字
 - YXSocketCommandTypePing: PING命令
 - YXSocketCommandTypePong: PONG命令
 - YXSocketCommandTypeSub: 行情订阅
 - YXSocketCommandTypeUnSub: 行情取消订阅
 - YXSocketCommandTypePush: 行情推送数据
 - YXSocketCommandTypeAuth: 鉴权请求
 */
typedef NS_OPTIONS(uint16_t, YXSocketCommandType) {
    YXSocketCommandTypeShakeHands   =   htons(0xff),
    YXSocketCommandTypePing         =   htons(0xfe),
    YXSocketCommandTypePong         =   htons(0xfd),
    YXSocketCommandTypeSub          =   htons(0x1),
    YXSocketCommandTypeUnSub        =   htons(0x2),
    YXSocketCommandTypePush         =   htons(0x3),
    YXSocketCommandTypeMessage      =   htons(0x4),
    YXSocketCommandTypeAuth         =   htons(0x5),
};


/**
 子命令字

 - YXSocketSubCommandTypeOption: 期权订阅SubCommand
 - YXSocketSubCommandTypeArcabook: 美股arcabook订阅SubCommand
 - YXSocketSubCommandTypeCancel: 取消部分普通行情
 - YXSocketSubCommandTypeCancelAll: 取消全部普通行情
 - YXSocketSubCommandTypeOptionCancel: 取消部分期权普通行情
 - YXSocketSubCommandTypeOptionCancelAll: 取消全部期权普通行情
 - YXSocketSubCommandTypeArcabookCancel: 取消部美股arcabook行情
 - YXSocketSubCommandTypeArcabookCancelAll: 取消全部美股arcabook行情
 - YXSocketSubCommandTypeUsNation: 请阅全美行情
 - YXSocketSubCommandTypeUsNationCancelAll: 取消全部全美行情
 - YXSocketSubCommandTypeUsNationCancel: 取消部分全美行情
 */
typedef NS_OPTIONS(uint16_t, YXSocketSubCommandType) {
    YXSocketSubCommandTypeNone                =   0xffff,
    YXSocketSubCommandTypeOption              =   htons(0x22),
    YXSocketSubCommandTypeArcabook            =   htons(0x23),
    YXSocketSubCommandTypeCancel              =   0x0,
    YXSocketSubCommandTypeCancelAll           =   htons(0x1),
    YXSocketSubCommandTypeOptionCancel        =   htons(0x10),
    YXSocketSubCommandTypeOptionCancelAll     =   htons(0x11),
    YXSocketSubCommandTypeArcabookCancel      =   htons(0x20),
    YXSocketSubCommandTypeArcabookCancelAll   =   htons(0x21),
    YXSocketSubCommandTypeUsNation            =   htons(0x24),
    YXSocketSubCommandTypeUsNationCancelAll   =   htons(0x25),
    YXSocketSubCommandTypeUsNationCancel      =   htons(0x26),
};


/**
 推送命令字
 
 - YXSocketPushCommandTypeRtFull: 实时
 - YXSocketPushCommandTypeRtSample: 精简实时
 - YXSocketPushCommandTypeTick: 逐笔
 - YXSocketPushCommandTypeTs: 分时
 - YXSocketPushCommandTypeKLine: K线
 - YXSocketPushCommandTypeCap: 资金流向
 - YXSocketPushCommandTypeMsg: 消息中心消息
 */
typedef NS_OPTIONS(uint16_t, YXSocketPushCommandType) {
    YXSocketPushCommandTypeRtFull        =   htons(0x1),
    YXSocketPushCommandTypeRtSample      =   htons(0x2),
    YXSocketPushCommandTypeTick          =   htons(0x4),
    YXSocketPushCommandTypeTs            =   htons(0x8),
    YXSocketPushCommandTypeKLine         =   htons(0x10),
    YXSocketPushCommandTypeCap           =   htons(0x20),
    YXSocketPushCommandTypeMsg           =   htons(0x40),
};

/**
 结果应答
 
 - YXSocketResultTypeSuccess: 成功
 - YXSocketResultTypeTimeOut: 超时
 - YXSocketResultTypeReject: 请求太多，拒绝服务
 - YXSocketResultTypeNetworkError: 网络错误
 - YXSocketResultTypeSystemBusy: 系统繁忙
 - YXSocketResultTypeCommandError: 命令字错误
 - YXSocketResultTypeMaintenance: 系统正在维护
 - YXSocketResultTypeUnLogin: 未登录状态
 - YXSocketResultTypeParameterError: 参数错误
 - YXSocketResultTypeBan: 权限禁止
 - YXSocketResultTypeFlowControl: 流量控制
 - YXSocketResultTypeBlackListControl: 黑白名单控制
 - YXSocketResultTypeOther: 其他错误
 */
typedef NS_OPTIONS(uint16_t, YXSocketResultType) {
    YXSocketResultTypeSuccess           =   htons(0x0),
    YXSocketResultTypeTimeOut           =   htons(0x1),
    YXSocketResultTypeReject            =   htons(0x2),
    YXSocketResultTypeNetworkError      =   htons(0x3),
    YXSocketResultTypeSystemBusy        =   htons(0x4),
    YXSocketResultTypeCommandError      =   htons(0x5),
    YXSocketResultTypeMaintenance       =   htons(0x6),
    YXSocketResultTypeUnLogin           =   htons(0x7),
    YXSocketResultTypeParameterError    =   htons(0x8),
    YXSocketResultTypeBan               =   htons(0x9),
    YXSocketResultTypeFlowControl       =   htons(0x10),
    YXSocketResultTypeBlackListControl  =   htons(0x11),
    YXSocketResultTypeOther             =   htons(0x12),
};


/**
 设备类型
 */
typedef NS_OPTIONS(uint8_t, YXSocketDeviceType) {
    YXSocketDeviceTypeAndroid           =   0x01,
    YXSocketDeviceTypeIOS               =   0x02,
    YXSocketDeviceTypeOther             =   0x03,
};

/**
 App类型
 */
typedef NS_OPTIONS(uint8_t, YXSocketAppType) {
    YXSocketAppTypeCN                   =   0x01,
    YXSocketAppTypeHK                   =   0x02,
    YXSocketAppTypeZTMASTER             =   0x04,
    YXSocketAppTypePRO                  =   0x05,
    YXSocketAppTypeOVERSEA              =   0x09,
    YXSocketAppTypeOVERSEA_SG           =   0x0c,
};

/**
 语言类型
 */
typedef NS_OPTIONS(uint8_t, YXSocketLangType) {
    YXSocketLangTypeZHSIMPLE             =   0x01,
    YXSocketLangTypeZH                   =   0x02,
    YXSocketLangTypeEN                   =   0x03,
    YXSocketLangTypeML                   =   0x04,
    YXSocketLangTypeTH                   =   0x05
};

/**
 接入类型
 
 - YXSocketAccessTypeWS: WebSocket + JSON
 - YXSocketAccessTypeTCP: TCP + PB
 */
typedef NS_OPTIONS(uint8_t, YXSocketAccessType) {
    YXSocketAccessTypeTCP               =   0x01,
    YXSocketAccessTypeWS                =   0x02,
};

//typedef NS_OPTIONS(uint8_t, YXSocketUserType) {
//    YXSocketUserTypeUser                =   0x01,
//    YXSocketUserTypeVisitor             =   0x02,
//};

#pragma pack(1)
/**
 握手请求
 
 TLV类型
 type ExtTlv struct {
 Type uint8 //具体类型
 Len uint16 //数据长度
 Value []byte //大端网络序存储
 }
 */
typedef struct shakeHandsReq {
    uint32_t Pkglen;        //包长，61字节 + tlv数组部分长度
    uint16_t Command;       //控制命令字，YXSocketCommandTypeShakeHands
    uint32_t Version;       //协议版本号，默认0
    uint8_t AccessType;     //接入类型，见YXSocketAccessType
    uint64_t Userid;        //用户UUID
    uint64_t CVer;          //客户端版本
    uint32_t SystemVer;     //系统版本
    uint8_t DeviceType;     //设备类型，见YXSocketDeviceType
    uint8_t AppType;        //app类型，见YXSocketAppType
    uint8_t LangType;       //app类型，见YXSocketLangType
    Byte DeviceID[32];      //设备UUID，唯一
    uint8_t TlvNum;         //tlv字段个数，用于扩展，默认0
}ShakeHandsReq;

/**
 握手应答
 */
typedef struct shakeHandsRsp {
    uint32_t Pkglen;        //包长，25字节 + tlv数组部分长度
    uint16_t Command;       //控制命令字，YXSocketCommandTypeShakeHands
    uint32_t Version;       //协议版本号，默认0
    uint64_t Userid;        //用户UUID
    uint32_t SVer;          //服务器版本
    uint16_t Result;        //应答结果，见YXSocketResultType
    uint8_t TlvNum;         //tlv字段个数，用于扩展，默认0
}ShakeHandsRsp;


/**
 通用消息头
 
 扩展字段
 TlvNum    uint8      tlv字段个数，用于扩展
 TlvArry   Tlv数组     tlv数组、用于扩展
 */
typedef struct acHeader {
    uint32_t Pkglen;        //包长
    uint16_t Command;       //控制命令字，见YXSocketCommandType
    uint16_t subCommand;    //子命令字，见YXSocketSubCommandType
    uint32_t SeqNum;        //序列号，自增
    uint16_t Flag;          //压缩标志，加密标志，默认0
    uint16_t TlvLen;        //Tlv 长度、0:没有TLV相关字段
    uint16_t result;        //应答结果，见YXSocketResultType
}AcHeader;

#pragma pack()
