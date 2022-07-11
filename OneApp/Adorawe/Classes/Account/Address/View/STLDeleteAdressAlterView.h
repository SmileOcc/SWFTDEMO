//
//  OSSVDeleteeAdresseAlterView.h
// XStarlinkProject
//
//  Created by Kevin on 2021/2/20.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol STLDeleteAdressAlterViewDelegate <NSObject>

@optional
- (void)makeSureAction;
@end

@interface OSSVDeleteeAdresseAlterView : UIView

@property (nonatomic, weak) id<STLDeleteAdressAlterViewDelegate>delegate;

-(void)showView;
-(void)hiddenView;

@end

NS_ASSUME_NONNULL_END
