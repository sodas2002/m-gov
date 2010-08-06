//
//  MapViewController.h
//  Locations
//
//  Created by Eric Liou on 8/2/10.
//  Copyright 2010 SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Event;

@interface MapViewController : UIViewController 
{
	MKMapView *map;
	Event *event;
}

@property (nonatomic, retain) Event *event;

@end
