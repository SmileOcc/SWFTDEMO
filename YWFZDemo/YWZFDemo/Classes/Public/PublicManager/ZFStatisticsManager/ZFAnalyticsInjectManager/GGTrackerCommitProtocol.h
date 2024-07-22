//
//  GGTrackerCommitProtocol.h
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GGTrackerCommitProtocol <NSObject>

@required
- (void)ctrlClicked:(NSString*)controlName
             onPage:(NSString*)pageName
               args:(NSDictionary*)args;

- (void)module:(NSString*)moduleName
  showedOnPage:(NSString*)pageName
      duration:(NSUInteger)duration
          args:(NSDictionary *)args;

@optional
- (NSString *)currentPageName;

@end

NS_ASSUME_NONNULL_END
