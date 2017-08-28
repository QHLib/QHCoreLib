//
//  MustOverride.m
//
//  Version 1.1
//
//  Created by Nick Lockwood on 22/02/2015.
//  Copyright (c) 2015 Nick Lockwood
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/MustOverride
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "QHMustOverride.h"

#import "QHInternal.h"

#if QH_DEBUG

#import <dlfcn.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>

@interface QHClassGraphNode : NSObject

@property (nonatomic, strong) NSString *className;

@property (nonatomic, strong) NSString *superClassName;

@property (nonatomic, strong) NSMutableSet<NSString *> *subClassNames;

@property (nonatomic, strong) NSMutableSet<NSString *> *classMethodNames;

@property (nonatomic, strong) NSMutableSet<NSString *> *instanceMethodNames;

@end

@implementation QHClassGraphNode

@end

static NSMutableDictionary<NSString *, QHClassGraphNode *> *classNameToNode;

static QHClassGraphNode *BuildNodeForClass(Class class)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classNameToNode = [NSMutableDictionary dictionary];
    });

    NSString *className = NSStringFromClass(class);
    QHClassGraphNode *node = [classNameToNode objectForKey:className];

    if (node == nil) {
        [classNameToNode setObject:({
            node = [[QHClassGraphNode alloc] init];
            node.className = className;

            node.superClassName = @"";
            Class superClass = class_getSuperclass(class);
            if (superClass) { // root class has no super class
                QHClassGraphNode *superNode = BuildNodeForClass(superClass);
                node.superClassName = superNode.className;

                // attach self to super class
                [superNode.subClassNames addObject:node.className];
            }

            node.subClassNames = [NSMutableSet set];

            node.classMethodNames = [NSMutableSet set];
            {
                unsigned int methodCount = 0;
                Method *methodList = class_copyMethodList(object_getClass(class), &methodCount);
                for (int i = 0; i < methodCount; ++i) {
                    [node.classMethodNames addObject:NSStringFromSelector(method_getName(methodList[i]))];
                }
                free(methodList);
            }

            node.instanceMethodNames = [NSMutableSet set];
            {
                unsigned int methodCount = 0;
                Method *methodList = class_copyMethodList(class, &methodCount);
                for (int i = 0; i < methodCount; ++i) {
                    [node.instanceMethodNames addObject:NSStringFromSelector(method_getName(methodList[i]))];
                }
                free(methodList);
            }

            node;
        }) forKey:className];
    }

    return node;
}

static void BuildClassGraph()
{
    unsigned int classCount = 0;
    Class *classList = objc_copyClassList(&classCount);
    for (int i = 0; i < classCount; ++i) {
        BuildNodeForClass(classList[i]);
    }
}

#ifdef __LP64__
typedef uint64_t MustOverrideValue;
typedef struct section_64 MustOverrideSection;
#define GetSectByNameFromHeader getsectbynamefromheader_64
#else
typedef uint32_t MustOverrideValue;
typedef struct section MustOverrideSection;
#define GetSectByNameFromHeader getsectbynamefromheader
#endif

@implementation QHMustOverride

static void CheckOverrides(void)
{
    Dl_info info;
    dladdr((const void *)&CheckOverrides, &info);

    const MustOverrideValue mach_header = (MustOverrideValue)info.dli_fbase;
    const MustOverrideSection *section = GetSectByNameFromHeader((void *)mach_header, "__DATA", "MustOverride");
    if (section == NULL) return;

    NSMutableArray *failures = [NSMutableArray array];

    for (MustOverrideValue addr = section->offset; addr < section->offset + section->size; addr += sizeof(const char **)) {
        NSString *entry = @(*(const char **)(mach_header + addr));
        NSArray *parts = [[entry substringWithRange:NSMakeRange(2, entry.length - 3)] componentsSeparatedByString:@" "];

        BOOL isClassMethod = [entry characterAtIndex:0] == '+';

        NSString *className = parts[0];
        NSRange categoryRange = [className rangeOfString:@"("];
        if (categoryRange.length) {
            className = [className substringToIndex:categoryRange.location];
        }

        NSString *methodName = parts[1];

        QHClassGraphNode *classNode = classNameToNode[className];
        [classNode.subClassNames enumerateObjectsUsingBlock:^(NSString * _Nonnull subClassName, BOOL * _Nonnull stop) {
            QHClassGraphNode *subClassNode = classNameToNode[subClassName];
            BOOL hasOverride = (isClassMethod
                                ? [subClassNode.classMethodNames containsObject:methodName]
                                : [subClassNode.instanceMethodNames containsObject:methodName]);
            if (!hasOverride) {
                [failures addObject:[NSString stringWithFormat:@"%@ does not implement required method '%c %@'",
                                     subClassName, isClassMethod ? '+' : '-', methodName]];
            }
        }];
    }

    if (failures.count > 0) {
        QHCoreLibFatal(@"%@%@",
                       [NSString stringWithFormat:@"%zd method override errors:\n", failures.count],
                       [failures componentsJoinedByString:@"\n"]);
    }
}

+ (void)load
{
    // we do not call check() here automaticly.
    // because check take a lots of memory which might be killed
    // when run within an extension
}

+ (void)check
{
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();

    BuildClassGraph();

    CheckOverrides();

    QHCoreLibDebug(@"Check overrides ok, cost: %.2fms", (CFAbsoluteTimeGetCurrent() - start) * 1000);
}

@end

#endif
