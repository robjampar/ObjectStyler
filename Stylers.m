//
//  UIView+prAppearance.m
//  DynamicNavigationController_Demo
//
//  Created by Robert Parker on 21/04/2014.
//  Copyright (c) 2014 parob. All rights reserved.
//

#import "Stylers.h"

@implementation Stylers

+ (Stylers*) sharedStylers {
    
    static Stylers *sharedStylers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStylers = [[self alloc] init];
        sharedStylers.stylerPool = [[NSMutableDictionary alloc] init];
        [sharedStylers loadDefaultStylers];
    });
    
    return sharedStylers;
}

- (void) loadDefaultStylers
{
    Styler *titleStyler = [[Styler alloc] initWithName:@"titleLabel" classType: UILabel.class];
    titleStyler.style = ^(UILabel* label){
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
        label.textColor = [UIColor darkTextColor];
    };
    [self addStyler:titleStyler];
    
    Styler *backLabelStyler = [[Styler alloc] initWithName:@"backLabel" classType: UILabel.class];
    backLabelStyler.style = ^(UILabel* label){
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
        label.textColor = theTintColor;
    };
    [self addStyler:backLabelStyler];
    
    Styler *background = [[Styler alloc] initWithName:@"background" classType: UIView.class];
    background.style = ^(UIView* view){
        view.backgroundColor = [UIColor blackColor];
    };
    [self addStyler:background];
}

- (void) addStyler: (Styler*) styler
{
    [self.stylerPool setObject:styler forKey:styler.name];
}

- (Styler*) getStyler: (NSString*) stylerName
{
    return [self.stylerPool objectForKey:stylerName];
}

@end


@implementation Styler

- (id) initWithName: (NSString*) name classType: (id) classType
{
    self = [super init];
    
    if(self)
    {
        self.styledObjects = [[NSPointerArray alloc] init];
        self.name = name;
        self.classType = classType;
    }
    return self;
}

- (void) storeStyledView: (id) object
{
    BOOL exists = false;
    for(id aObject in self.styledObjects)
    {
        if(aObject == object)
        {
            exists = true;
        }
    }
    if(exists == false)
    {
        [self.styledObjects addPointer:(__bridge void *)(object)];
    }
}

- (void) restyleAllStoredViews
{
    for(id aObject in self.styledObjects)
    {
        if(aObject != NULL)
        {
            [self runStyler:aObject];
        }
    }
    [self.styledObjects compact];
}

- (BOOL) runStyler: (id) object
{
    if([object isKindOfClass:self.classType])
    {
        self.style(object);
        [self storeStyledView:object];
        return true;
    }
    else
    {
        if(self.classType)
        {
            NSLog(@"Styler Error: Class type mismatch, Your setting a styler for a objectType that it dosnt work with");
        }
        else
        {
            NSLog(@"Styler Error: The requiredClassType has not been set on the styler");
        }
        return false;
    }
}

@end


static char const * const stylerNamesKey = "myViewStyleNames";

#import <objc/runtime.h>

@implementation NSObject (styler)


- (NSMutableArray*) appliedStylerNames {
    NSMutableArray* StylerNames = objc_getAssociatedObject(self, stylerNamesKey);
    if(StylerNames)
    {
        return StylerNames;
    }
    else
    {
        StylerNames = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, stylerNamesKey,StylerNames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return StylerNames;
    }
}

- (id) applyStylersWithNames: (NSArray*) stylerNames
{
    for(id stylerName in stylerName)
    {
        if(stylerName && [stylerName isKindOfClass:NSString.class])
        {
            [self applyStylerWithName: stylerName];
        }
        else
        {
            NSLog(@"Styler Error: Invalid styler array");
        }
    }
    return self;
}

- (id) applyStylerWithName: (NSString*) stylerName
{
    Styler *styler = [[Stylers sharedStylers] getStyler:stylerName];
    if(styler)
    {
        if([styler runStyler:self])
        {
            NSMutableArray *StylerNames = [self appliedStylerNames];
            [StylerNames addObject:stylerName];
            objc_setAssociatedObject(self, stylerNamesKey,StylerNames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else
    {
        NSLog(@"Styler Error: Styler %@ not found",stylerName);
    }
    return self;
}


@end
