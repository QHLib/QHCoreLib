//
//  QHClockChecker.h
//  QHCoreLib
//
//  Created by changtang on 2019/4/22.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// not thread safe

#define QHProfilerStart(_module, _event)            [QHClockChecker start:_event inModule:_module]
#define QHProfilerCheck(_module, _event, _point)    [QHClockChecker check:_point onEvent:_event inModule:_module]
#define QHProfilerEnd(_module, _event)              [QHClockChecker end:_event inModule:_module]


@class QHClockEntry;

@interface QHClockCheckItem : NSObject

@property (nonatomic, strong, readonly) QHClockEntry *clock;

@property (nonatomic, copy) NSString *module;
@property (nonatomic, copy) NSString *event;
@property (nonatomic, copy) NSString *point; // start, _point, end

@property (nonatomic, assign) int interval; // in ms, from last check point
@property (nonatomic, assign) int total; // in ms

@end

typedef void(^QHProfilerCollector)(QHClockCheckItem *item);

@interface QHClockChecker : NSObject

+ (void)setCollector:(QHProfilerCollector)collector;

+ (void)start:(NSString *)event inModule:(NSString *)module;

+ (void)check:(NSString *)point onEvent:(NSString *)event inModule:(NSString *)module;

+ (void)end:(NSString *)event inModule:(NSString *)module;

@end

NS_ASSUME_NONNULL_END
