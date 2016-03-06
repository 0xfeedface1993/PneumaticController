//
//  managedObjectConfiguration.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/24.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "managedObjectConfiguration.h"

@interface managedObjectConfiguration()
@property (strong, nonatomic) NSArray *sections;
@end

@implementation managedObjectConfiguration
-(id)initWithResource:(NSString *)resource{
    self=[super init];
    if (self) {
        NSURL *plistURL=[[NSBundle mainBundle] URLForResource:resource
                                                withExtension:@"plist"];
        NSDictionary *plist=[NSDictionary dictionaryWithContentsOfURL:plistURL];
        self.sections=[plist valueForKey:@"sections"];
    }
    return self;
}

-(NSInteger)numberOfSections{
    return self.sections.count;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    NSDictionary *sectionDict=[self.sections objectAtIndex:section];
    NSArray *rows=[sectionDict objectForKey:@"rows"];
    return rows.count;
}

-(NSString *)headerInSection:(NSInteger)section{
    NSDictionary *sectionDict=[self.sections objectAtIndex:section];
    return [sectionDict objectForKey:@"header"];
}

-(NSDictionary *)rowForIndexPath:(NSIndexPath *)indexPath{
    NSUInteger sectionIndex=[indexPath section];
    NSUInteger rowIndex=[indexPath row];
    NSDictionary *section=[self.sections objectAtIndex:sectionIndex];
    NSArray *rows=[section objectForKey:@"rows"];
    NSDictionary *row=[rows objectAtIndex:rowIndex];
    return row;
}

-(NSString *)cellClassnameForIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *row=[self rowForIndexPath:indexPath];
    return [row objectForKey:@"class"];
}

-(NSArray *)valuesForIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *row=[self rowForIndexPath:indexPath];
    return [row objectForKey:@"values"];
}

-(NSString *)attributeKeyForIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *row=[self rowForIndexPath:indexPath];
    return [row objectForKey:@"key"];
}

-(NSString *)labelForIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *row=[self rowForIndexPath:indexPath];
    //NSLog(@"row IndexPath \nsection: %d \nrow: %d \nlabel:%@",[indexPath section],[indexPath row],[row objectForKey:@"label"]);
    return [row objectForKey:@"label"];
}

/*
-(BOOL)isDynamicSection:(NSInteger)section{
    BOOL dynamic=NO;
    NSDictionary *sectionDict=[self.sections objectAtIndex:section];
    NSNumber *dynamicNumber=[sectionDict objectForKey:@"dynamic"];
    if (dynamicNumber!=nil) {
        dynamic=[dynamicNumber boolValue];
    }
    return dynamic;
}

-(NSString *)dynamicAttributeKeyForSection:(NSInteger)section{
    if (![self isDynamicSection:section]) {
        return nil;
    }
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:section];
    return [self attributeKeyForIndexPath:indexPath];
}
 */

@end
