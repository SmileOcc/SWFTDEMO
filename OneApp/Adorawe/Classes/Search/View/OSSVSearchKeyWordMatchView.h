//
//  OSSVSearchKeyWordMatchView.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SearchMatchKeyboardHandler)(NSString *keyWord);

typedef void(^SearchMatchCopyHandler)(NSString *keyWord);

@interface OSSVSearchKeyWordMatchView : UIView

@property (nonatomic, copy) NSString  *searchKey;
@property (nonatomic, strong) NSArray *keywords;

@property (nonatomic, copy) SearchMatchCopyHandler copyHandler;

@property (nonatomic, copy) SearchMatchKeyboardHandler keyWordHandler;

@end

NS_ASSUME_NONNULL_END
