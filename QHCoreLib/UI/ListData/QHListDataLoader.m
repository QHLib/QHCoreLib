//
//  QHListDataLoader.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHListDataLoader.h"
#import "QHListDataLoader+internal.h"

#import "QHBase+internal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation QHListDataLoader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestType = QHListDataRequestTypeNotLoadYet;
        self.hasMore = NO;
    }
    return self;
}

#pragma mark -

- (BOOL)isLoading
{
    return [self p_isLoading];
}

- (void)load
{
    if (self.isLoading) {
        return;
    }

    self.requestType = QHListDataRequestTypeEmptyLoad;

    [self p_doLoadFirst];
}

- (void)dirtyLoad
{
    if (self.isLoading) {
        return;
    }

    self.requestType = QHListDataRequestTypeDirtyLoad;

    [self p_doLoadFirst];
}

- (void)reload
{
    if (self.isLoading) {
        return;
    }

    self.requestType = QHListDataRequestTypeReload;

    [self p_doLoadFirst];
}

- (void)loadNext
{
    if (self.isLoading) {
        return;
    }

    self.requestType = QHListDataRequestTypeNext;

    [self p_doLoadNext];
}

- (void)cancel
{
    [self p_doCancel];
}

#pragma mark - subclass implement

- (BOOL)p_isLoading
{
    @QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass implements");
    return NO;
}

- (void)p_doLoadFirst
{
    @QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass implements");
}

- (void)p_doLoadNext
{
    @QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass implements");
}

- (void)p_doCancel
{
    @QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass implements");
}

#pragma mark -

- (void)p_loadSucceed:(NSArray *)list
             userInfo:(NSDictionary * _Nullable)userInfo
{
    if ([self.delegate
         respondsToSelector:@selector(listDataLoaderSucceed:list:userInfo:)]) {

        [self.delegate listDataLoaderSucceed:self
                                        list:list
                                    userInfo:userInfo];
    }
}

- (void)p_loadFailed:(NSError * _Nullable)error
            userInfo:(NSDictionary * _Nullable)userInfo
{
    if ([self.delegate
         respondsToSelector:@selector(listDataLoaderFailed:error:userInfo:)]) {

        [self.delegate listDataLoaderFailed:self
                                      error:error
                                   userInfo:userInfo];
    }
}

@end

NS_ASSUME_NONNULL_END
