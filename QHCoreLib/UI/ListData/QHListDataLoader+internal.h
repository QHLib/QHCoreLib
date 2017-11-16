//
//  QHListDataLoader+internal.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <QHCoreLib/QHListDataLoader.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHListDataLoader ()

@property (nonatomic, assign, readwrite) QHListDataRequestType requestType;

@property (nonatomic, assign, readwrite) BOOL hasMore;

// subclasses should implements
- (BOOL)p_isLoading;

- (void)p_doLoadFirst;          // called by load, dirtyLoad, reload
- (void)p_doLoadNext;           // called by loadNext

- (void)p_doCancel;

// subclasses callback
- (void)p_loadSucceed:(NSArray *)list
             userInfo:(NSDictionary * _Nullable)userInfo;

- (void)p_loadFailed:(NSError * _Nullable)error
            userInfo:(NSDictionary * _Nullable)userInfo;

@end

NS_ASSUME_NONNULL_END
