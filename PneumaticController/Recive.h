//
//  Recive.h
//  PneumaticController
//
//  Created by virus1993 on 15/12/14.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Recive : NSManagedObject

@property (nullable, nonatomic, retain) NSNumber *changerate;
@property (nullable, nonatomic, retain) NSNumber *electromagnet;
@property (nullable, nonatomic, retain) NSNumber *highpressurevalve;
@property (nullable, nonatomic, retain) NSNumber *lowpressurevalve;
@property (nullable, nonatomic, retain) NSNumber *pressure;
@property (nullable, nonatomic, retain) NSString *runtime;
@property (nullable, nonatomic, retain) NSNumber *stablevalve;
@property (nullable, nonatomic, retain) NSString *systemtime;
@property (nullable, nonatomic, retain) NSNumber *temperature;
@property (nullable, nonatomic, retain) NSNumber *vacuumpump;

@end

NS_ASSUME_NONNULL_END

//#import "Recive+CoreDataProperties.h"
