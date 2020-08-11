//
//  QHAsyncTaskEngine.m
//  QHCoreLib
//
//  Created by changtang on 2019/11/18.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import "QHAsyncTaskEngine.h"
#import <UIKit/UIKit.h>

static uint32_t nextTaskId = 0;
static NSMutableDictionary *taskMap = nil;

@implementation QHAsyncTaskEngine

+ (void)initialize {
    taskMap = [NSMutableDictionary dictionary];
}

+ (QHAsyncTaskId)runTask:(QHAsyncTask *)task
                 success:(void (^)(QHAsyncTask * _Nonnull, id _Nonnull))success
                    fail:(void (^)(QHAsyncTask * _Nonnull, NSError * _Nonnull))fail {
    QHAssertMainThread();
    QHAssertParam(task);

    uint32_t taskId = nextTaskId++;
    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nonnull result) {
        if (success) {
            success(task, result);
        }
        [taskMap removeObjectForKey:@(taskId)];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        if (fail) {
            fail(task, error);
        }
        [taskMap removeObjectForKey:@(taskId)];
    }];
    [taskMap setObject:task forKey:@(taskId)];

    return @(taskId);
}

+ (QHAsyncTaskId)runTypedTask:(id)task
                      success:(void (^)(id _Nonnull, id _Nonnull))success
                         fail:(void (^)(id _Nonnull, NSError * _Nonnull))fail {
    return [self runTask:task success:success fail:fail];
}

+ (void)cancelTask:(QHAsyncTaskId)taskId {
    QHAssertMainThread();
    QHAssertParam(taskId);

    [taskMap[taskId] cancel];
    [taskMap removeObjectForKey:taskId];
}

+ (void)cancelAll {
    QHAssertMainThread();

    [taskMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    [taskMap removeAllObjects];
}

@end
