//
//  detailViewController.h
//  MGOV
//
//  Created by sodas on 2010/8/11.
//  Copyright 2010 NTU Mobile HCI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface detailViewController : UITableViewController {
	NSInteger finalSectionId;
	NSInteger finalTypeId;
	NSInteger finalDetailId;
}

@property (nonatomic) NSInteger finalSectionId;
@property (nonatomic) NSInteger finalTypeId;
@property (nonatomic) NSInteger finalDetailId;

@end
