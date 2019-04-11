//
//  QHMutex.h
//  QHCoreLib
//
//  Created by Tony Tang on 2019/4/11.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHMutex : NSObject <NSLocking>

- (BOOL)tryLock;

@end

NS_ASSUME_NONNULL_END
