//
//  QHPathUtil.h
//  QHCoreLib
//
//  Created by changtang on 2018/1/4.
//  Copyright © 2018年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHPathUtil : NSObject

+ (NSString *)mainBundleDirPath;

+ (NSString *)filePathInMainBundle:(NSString *)fileName;

#pragma mark -

+ (BOOL)createDirIfNotExists:(NSString *)dirPath;

#pragma mark -

+ (NSString *)documentDirPath;

+ (NSString *)dirPathInDocument:(NSString *)dirName
              createIfNotExists:(BOOL)create;

+ (NSString *)filePathInDocument:(NSString *)fileName;

#pragma mark -

+ (NSString *)cacheDirPath;

+ (NSString *)dirPathInCache:(NSString *)dirName
           createIfNotExists:(BOOL)create;

+ (NSString *)filePathInCache:(NSString *)fileName;

#pragma mark -

+ (NSString *)tempDirPath;

+ (NSString *)dirPathInTemp:(NSString *)dirName
          createIfNotExists:(BOOL)create;

+ (NSString *)filePathInTemp:(NSString *)fileName;

+ (NSString *)uniqueTempFilePath;

@end

NS_ASSUME_NONNULL_END

