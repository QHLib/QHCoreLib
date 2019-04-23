//
//  QHScopedLock.h
//  QHCoreLib
//
//  Created by Tony Tang on 2019/4/12.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus

@class QHMutex;

class QHScopedLock {
public:
    QHScopedLock(QHMutex *mutex);
    ~QHScopedLock();
    
private:
    QHMutex *m_mutex;
};

#endif

NS_ASSUME_NONNULL_END
