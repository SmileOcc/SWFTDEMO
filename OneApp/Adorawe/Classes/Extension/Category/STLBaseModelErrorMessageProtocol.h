//
//  STLBaseModelErrorMessageProtocol.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STLBaseModelErrorMessageProtocol <NSObject>

-(void)modalErrorMessage:(UIViewController *)viewController baseModel:(NSObject *)model;

@end
