//
//  managedObjectConfiguration.h
//  PneumaticController
//
//  Created by virus1993 on 15/11/24.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface managedObjectConfiguration : NSObject
-(NSInteger)numberOfSections;
-(NSInteger)numberOfRowsInSection:(NSInteger)section;
-(NSString *)headerInSection:(NSInteger)section;
-(NSDictionary *)rowForIndexPath:(NSIndexPath *)indexPath;

-(NSString *)cellClassnameForIndexPath:(NSIndexPath *)indexPath;
-(NSArray *)valuesForIndexPath:(NSIndexPath *)indexPath;
-(NSString *)attributeKeyForIndexPath:(NSIndexPath *)indexPath;
-(NSString *)labelForIndexPath:(NSIndexPath *)indexPath;
/*
-(BOOL)isDynamicSection:(NSInteger)section;
-(NSString *)dynamicAttributeKeyForSection:(NSInteger)section;
*/
-(id)initWithResource:(NSString *)resource;
@end
