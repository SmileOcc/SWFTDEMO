//
//  YXSocketUtility.m
//  YouXinZhengQuan
//
//  Created by rrd on 2018/8/3.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXSocketUtility.h"
#import "GCDAsyncSocket.h"



@interface YXSocketUtility ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation YXSocketUtility


+ (instancetype)shareSocketUtility {
    static YXSocketUtility *socketUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socketUtility = [[YXSocketUtility alloc] init];
    });
    
    return socketUtility;
}

- (instancetype)init {
    if (self = [super init]) {
        

        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
    }
    return self;
}


- (BOOL)connect {
    
    NSError *error ;
    
    BOOL success = [_socket connectToHost:@"10.20.8.125" onPort:6789 error:&error];
    
    NSLog(@"++++++++++++++长链接建立状态 %d,%@",success,error);
    
    return success;
}

- (void)disConnect {
    [_socket disconnect];
}

- (void)sendMessage:(NSString *)message {
    NSData *data  = [message dataUsingEncoding:NSUTF8StringEncoding];
    //第二个参数，请求超时时间
    [_socket writeData:data withTimeout:-1 tag:110];
}

 //监听最新的消息
- (void)pullTheMsg
{
    //监听读数据的代理  -1永远监听，不超时，但是只收一次消息，
    //所以每次接受到消息还得调用一次
    [_socket readDataWithTimeout:-1 tag:110];
    
}



#pragma mark - GCDAsyncSocketDelegate
//连接成功调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功,host:%@,port:%d",host,port);
    
    [self pullTheMsg];
    
    //心跳写在这...
}


//断开连接的时候调用
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    NSLog(@"断开连接,host:%@,port:%d",sock.localHost,sock.localPort);
    
    //断线重连写在这...
    
}

//写成功的回调
- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag
{
    //    NSLog(@"写的回调,tag:%ld",tag);
}

//收到消息的回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到消息：%@",msg);
    
    [self pullTheMsg];
}

//分段去获取消息的回调
//- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
//{
//
//    NSLog(@"读的回调,length:%ld,tag:%ld",partialLength,tag);
//
//}

//为上一次设置的读取数据代理续时 (如果设置超时为-1，则永远不会调用到)
//-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
//{
//    NSLog(@"来延时，tag:%ld,elapsed:%f,length:%ld",tag,elapsed,length);
//    return 10;
//}

@end



