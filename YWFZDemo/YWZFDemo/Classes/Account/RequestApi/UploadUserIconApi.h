//
//  UploadIconApi.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/10.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "SYBaseRequest.h"

@interface UploadUserIconApi : SYBaseRequest

-(instancetype)initWithImageData:(NSString *)imageData;

@end
