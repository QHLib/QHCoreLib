//
//  QHBaseModel.m
//  QHCoreLib
//
//  Created by Tony Tang on 2021/6/17.
//  Copyright © 2021 TCTONY. All rights reserved.
//

#import "QHBaseModel.h"

#import <objc/runtime.h>


@implementation QHBaseModel

- (void)encodeWithCoder:(NSCoder *)coder {
    Class cls = [self class];
    while (cls != [NSObject class]) {
        unsigned int numberOfIvars = 0;
        Ivar *ivars = class_copyIvarList(cls, &numberOfIvars);
        for (int i = 0; i < numberOfIvars; ++i) {
            const char *type = ivar_getTypeEncoding(ivars[i]);
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
            if (key == nil || key.length == 0){
                continue;;
            }
            switch (type[0]) {
                case _C_STRUCT_B:
                case _C_UNION_B: {
                    NSUInteger ivarSize = 0;
                    NSUInteger ivarAlignment = 0;
                    NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
                    const char *this = CFBridgingRetain(self);
                    NSData *data = [NSData dataWithBytes:this + ivar_getOffset(ivars[i])
                                                  length:ivarSize];
                    [coder encodeObject:data forKey:key];
                    CFBridgingRelease(this);
                    break;
                }
                default: {
                    id value = [self valueForKey:key];
                    if (value) {
                        [coder encodeObject:value forKey:key];
                    }
                    break;
                }
            }
        }

        cls = class_getSuperclass(cls);
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        Class cls = [self class];
        while (cls != [NSObject class]) {
            unsigned int numberOfIvars = 0;
            Ivar *ivars = class_copyIvarList(cls, &numberOfIvars);
            for (int i = 0; i < numberOfIvars; ++i) {
                const char *type = ivar_getTypeEncoding(ivars[i]);
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
                if (key == nil || key.length == 0) {
                    continue;;
                }
                id value = [coder decodeObjectForKey:key];
                if (value) {
                    switch (type[0]) {
                        case _C_STRUCT_B:
                        case _C_UNION_B: {
                            NSUInteger ivarSize = 0;
                            NSUInteger ivarAlignment = 0;
                            NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
                            char *this = (char *)CFBridgingRetain(self);
                            [(NSData *)value getBytes:this + ivar_getOffset(ivars[i]) length:ivarSize];
                            CFBridgingRelease(this);
                            break;
                        }
                        default: {
                            [self setValue:value forKey:key];
                            break;
                        }
                    }
                }
            }

            cls = class_getSuperclass(cls);
        }
    }
    return self;
}

@end
