//
//  UIDevice(Identifier).m
//  Yoshop
//
//  Created by YW on 16/7/15.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "UIDevice+Identifier.h"

@interface UIDevice(Private)
@end

@implementation UIDevice (IdentifierAddition)

#pragma mark -
#pragma mark Public Methods

- (NSString *) uniqueDeviceIdentifier{
    
    static NSString *identifier = nil;
    
	if (identifier == nil)
	{
        if( [UIDevice instancesRespondToSelector:@selector(identifierForVendor)]) {
            
            identifier = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] copy];
            
        } else {
            
            identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"identifierForVendor"];
            if(!identifier) {
                CFUUIDRef uuid = CFUUIDCreate(NULL);
                identifier = (__bridge NSString *)CFUUIDCreateString(NULL, uuid);
                CFRelease(uuid);
                
                [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:@"identifierForVendor"];
            }
        }
    }
    
    return identifier;
}

@end
