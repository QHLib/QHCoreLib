//
//  QHPathUtil.m
//  QHCoreLib
//
//  Created by changtang on 2018/1/4.
//  Copyright © 2018年 TCTONY. All rights reserved.
//

#import "QHPathUtil.h"

NS_ASSUME_NONNULL_BEGIN

@implementation QHPathUtil

+ (NSString *)mainBundleDirPath
{
    static NSString *dir = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dir = [[NSBundle mainBundle] bundlePath];
    });
    return dir;
}

+ (NSString *)filePathInMainBundle:(NSString *)fileName
{
    return [[self mainBundleDirPath] stringByAppendingPathComponent:fileName];
}

#pragma mark -

+ (BOOL)createDirIfNotExists:(NSString *)dir
{
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir] == NO
        || isDir == NO) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:dir
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:nil];
    }
    return YES;
}

#pragma mark -

+ (NSString *)documentDirPath
{
    static NSString *dir = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        dir = [paths firstObject];
    });

    [self createDirIfNotExists:dir];

    return dir;
}

+ (NSString *)dirPathInDocument:(NSString *)dirName
              createIfNotExists:(BOOL)create
{
    NSString *dir = [[self documentDirPath] stringByAppendingPathComponent:dirName];

    if (create) {
        [self createDirIfNotExists:dir];
    }

    return dir;
}

+ (NSString *)filePathInDocument:(NSString *)fileName
{
    return [[self documentDirPath] stringByAppendingPathComponent:fileName];
}

#pragma mark -

+ (NSString *)libraryDirPath
{
    static NSString *dir = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        dir = [paths firstObject];
    });

    [self createDirIfNotExists:dir];

    return dir;
}

+ (NSString *)dirPathInLibrary:(NSString *)dirName
              createIfNotExists:(BOOL)create
{
    NSString *dir = [[self libraryDirPath] stringByAppendingPathComponent:dirName];

    if (create) {
        [self createDirIfNotExists:dir];
    }

    return dir;
}

+ (NSString *)filePathInLibrary:(NSString *)fileName
{
    return [[self libraryDirPath] stringByAppendingPathComponent:fileName];
}

#pragma mark -

+ (NSString *)cacheDirPath
{
    static NSString *dir = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        dir = [paths firstObject];
    });

    [self createDirIfNotExists:dir];

    return dir;
}

+ (NSString *)dirPathInCache:(NSString *)dirName
           createIfNotExists:(BOOL)create
{
    NSString *dir = [[self cacheDirPath] stringByAppendingPathComponent:dirName];

    if (create) {
        [self createDirIfNotExists:dir];
    }

    return dir;
}

+ (NSString *)filePathInCache:(NSString *)fileName
{
    return [[self cacheDirPath] stringByAppendingPathComponent:fileName];
}

#pragma mark -

+ (NSString *)tempDirPath
{
    static NSString *dir = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dir = NSTemporaryDirectory();
    });

    [self createDirIfNotExists:dir];

    return dir;
}

+ (NSString *)dirPathInTemp:(NSString *)dirName createIfNotExists:(BOOL)create
{
    NSString *dir = [[self tempDirPath] stringByAppendingPathComponent:dirName];

    if (create) {
        [self createDirIfNotExists:dir];
    }

    return dir;
}

+ (NSString *)filePathInTemp:(NSString *)fileName
{
    return [[self tempDirPath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)uniqueTempFilePath
{
    NSUUID *uuid = [NSUUID UUID];
    return [self filePathInTemp:uuid.UUIDString];
}

@end

NS_ASSUME_NONNULL_END
