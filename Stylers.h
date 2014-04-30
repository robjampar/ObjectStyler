//
//  UIView+prAppearance.h
//  DynamicNavigationController_Demo
//
//  Created by Robert Parker on 21/04/2014.
//  Copyright (c) 2014 parob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Styler;

@interface Stylers : NSObject

@property (nonatomic,retain) NSMutableDictionary *stylerPool;

+ (Stylers*) sharedStylers;

- (void) loadDefaultStylers;
- (void) addStyler: (Styler*) styler;
- (Styler*) getStyler: (NSString*) stylerName;

@end

@interface Styler : NSObject

@property (nonatomic,retain) NSPointerArray *styledObjects;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) id classType;
@property (copy) void (^style) (id);

- (id) initWithName: (NSString*) name classType: (id) classType;
- (BOOL) runStyler: (id) object;
- (void) restyleAllStoredViews;

@end

@interface NSObject (styler)

- (id) applyStylerWithName: (NSString*) stylerName;
- (id) applyStylersWithNames: (NSArray*) stylerNames;

@end