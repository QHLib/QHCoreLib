//
//  QHClockEntry.h
//  QQHouse
//
//  Created by changtang on 15/12/2.
//
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface QHClockEntry : NSObject

- (void)start;
- (void)end;

- (int)elapsedTimeInMiliseconds;
- (int)spentTimeInMiliseconds;

@end

NS_ASSUME_NONNULL_END
