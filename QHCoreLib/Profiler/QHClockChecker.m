//
//  QHClockChecker.m
//  QHCoreLib
//
//  Created by changtang on 2019/4/22.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import "QHClockChecker.h"
#import "QHClockEntry.h"
#import "QHBase+internal.h"


@implementation QHClockCheckItem {
@public
    QHClockEntry *m_clock;
}

- (QHClockEntry *)clock {
    return m_clock;
}

- (instancetype)copy {
    QHClockCheckItem *copy = [[QHClockCheckItem alloc] init];
    copy->m_clock = m_clock;
    copy.module = self.module;
    copy.event = self.event;
    copy.point = self.point;
    copy.interval = self.interval;
    copy.total = self.total;
    return copy;
}

@end


static QHProfilerCollector sCollector = nil;

static NSMutableDictionary<NSString *, QHClockCheckItem *> *sItems = nil;

@implementation QHClockChecker

+ (void)setCollector:(QHProfilerCollector)collector {
    sCollector = collector;
}

+ (void)yieldItem:(QHClockCheckItem *)item {
    if (!sCollector) {
        sCollector = ^(QHClockCheckItem *item) {
            QHCoreLibInfo(@"QHProfiler check: %@-%@-%@, since last check: %dms, total: %dms",
                          item.module, item.event, item.point, item.interval, item.total);
        };
    }

    if (sCollector) {
        sCollector(item);
    }
}

#define ItemKey $(@"%@-%@", module, event)

+ (void)start:(NSString *)event inModule:(NSString *)module {
    if (!QH_IS_VALID_STRING(event) || !QH_IS_VALID_STRING(module)) {
        QHCoreLibWarn(@"invalid profile target: module %@ event %@", event, module);
        return;
    }

    if (!sItems) {
        sItems = [NSMutableDictionary dictionary];
    }

    QHClockCheckItem *item = sItems[ItemKey];
    QHAssertReturnVoidOnFailure(item == nil, @"start %@ twice might be something wrong", ItemKey);

    item = [[QHClockCheckItem alloc] init];
    item.module = module;
    item.event = event;
    item.point = @"start";
    item.interval = 0;
    item.total = 0;
    item->m_clock = [[QHClockEntry alloc] init];
    [item->m_clock start];

    sItems[ItemKey] = item;
}

+ (void)check:(NSString *)point onEvent:(NSString *)event inModule:(NSString *)module {
    if (!QH_IS_VALID_STRING(point) || !QH_IS_VALID_STRING(event) || !QH_IS_VALID_STRING(module)) {
        QHCoreLibWarn(@"invalid profile target: module %@ event %@ point %@", module, event, point);
        return;
    }

    QHClockCheckItem *item = sItems[ItemKey];
    QHAssertReturnVoidOnFailure(item != nil, @"check %@ without starting might be something wrong", ItemKey);

    item.point = point;
    int elapsed = [item->m_clock elapsedTimeInMiliseconds];
    item.interval = elapsed - item.total;
    item.total = elapsed;

    [self yieldItem:[item copy]];
}

+ (void)end:(NSString *)event inModule:(NSString *)module {
    if (!QH_IS_VALID_STRING(event) || !QH_IS_VALID_STRING(module)) {
        QHCoreLibWarn(@"invalid profile target: module %@ event %@", event, module);
        return;
    }

    QHClockCheckItem *item = sItems[ItemKey];
    QHAssertReturnVoidOnFailure(item != nil, @"end %@ without starting might be something wrong", ItemKey);

    item.point = @"end";
    int elapsed = [item->m_clock elapsedTimeInMiliseconds];
    item.interval = elapsed - item.total;
    item.total = elapsed;

    [sItems removeObjectForKey:ItemKey];

    [self yieldItem:item];
}

#undef ItemKey

@end
