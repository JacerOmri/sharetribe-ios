//
//  ListingAnnotationView.m
//  Sharetribe
//
//  Created by Janne Käki on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingAnnotationView.h"

#import "Listing.h"
#import "ListingCluster.h"

@implementation ListingAnnotationView

@synthesize iconView;
@synthesize countLabel;
@synthesize pinHeadView;

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    if (pinHeadView == nil) {
        self.pinHeadView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin-head"]];
        pinHeadView.frame = CGRectMake(-7, -5, 28, 28);
        [self addSubview:pinHeadView];
    }
    
    if ([annotation isKindOfClass:Listing.class]) {
        
        if (iconView == nil) {
            self.iconView = [[UIImageView alloc] init];
            iconView.frame = CGRectMake(-5, -3, 24, 24);
            [self addSubview:iconView];
        }
        
        iconView.image = [Listing iconForCategory:[(Listing *) annotation category]];
        
        iconView.hidden = NO;
        countLabel.hidden = YES;
        
        self.canShowCallout = NO;
        
    } else if ([annotation isKindOfClass:ListingCluster.class]) {
        
        if (countLabel == nil) {
            self.countLabel = [[UILabel alloc] init];
            countLabel.frame = pinHeadView.frame;
            countLabel.font = [UIFont boldSystemFontOfSize:15];
            countLabel.textColor = [UIColor darkGrayColor];
            countLabel.shadowColor = [UIColor whiteColor];
            countLabel.shadowOffset = CGSizeMake(0, 1);
            countLabel.backgroundColor = [UIColor clearColor];
            countLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:countLabel];
        }
        
        countLabel.text = [NSString stringWithFormat:@"%d", [(ListingCluster *) annotation listings].count];
        
        countLabel.hidden = NO;
        iconView.hidden = YES;
        
        self.canShowCallout = YES;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.pinHeadView.image = (selected) ? [UIImage imageNamed:@"pin-head-active"] : [UIImage imageNamed:@"pin-head"];
}

@end
