/*
 * 
 * PrefViewController.m
 * 2010/10/2
 * sodas
 * 
 * Preference table view
 *
 * Copyright 2010 NTU CSIE Mobile & HCI Lab
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "PrefViewController.h"
#import "FBConnect.h"

static NSString* kAppId = @"106524439416118"; //taipei1999
#define ACCESS_TOKEN_KEY @"fb_access_token"
#define EXPIRATION_DATE_KEY @"fb_expiration_date"

@implementation PrefViewController

@synthesize originalEmail;
@synthesize facebook;

#pragma mark -
#pragma mark WritePrefDelegate

- (void)writeToPrefWithKey:(NSString *)key andObject:(id)value {
	if (![self preScriptBeforeSaveKey:key andObject:value]) {
		if ([key isEqualToString:@"User Email"])
			[self alertWhileFailToWriteWithTitle:@"E-Mail格式錯誤" andContent:@"請輸入正確的E-Mail！"];
		[self.tableView reloadData];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self.tableView reloadData];
		// Run post action
		[self postScriptAfterSaveKey:key andObject:value];
	}
}

#pragma mark -
#pragma mark Method

- (void)alertWhileFailToWriteWithTitle:(NSString *)alertTitle andContent:(NSString *)alertContent {
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertContent delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
}

- (BOOL)preScriptBeforeSaveKey:(NSString *)key andObject:(id)value {
	if ([key isEqualToString:@"User Email"]) {
		// Check Email Format
		if (![value length]) {
			[self alertWhileFailToWriteWithTitle:@"已清除您的E-Mail帳號" andContent:@"如果要查詢以前報過的案件，請再次輸入您的E-Mail帳號即可。"];
			return YES; 
		}
		NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z0-9.-]";
		NSRange r = [value rangeOfString:emailRegex options:NSRegularExpressionSearch];
		if (r.location != NSNotFound) return YES;
		else return NO;
		
		emailRegex = nil;
	} else {
		// Nothing to check
		return YES;
	}
}

- (void)postScriptAfterSaveKey:(NSString *)key andObject:(id)value {
	if ([key isEqualToString:@"User Email"]) {
		if ([self.parentViewController.parentViewController isKindOfClass:[UITabBarController class]]) {
			UITabBarController *mainBar = (UITabBarController *)self.parentViewController.parentViewController;
			NSEnumerator *enumerator = [mainBar.viewControllers objectEnumerator];
			id eachViewController;
			while ((eachViewController = [enumerator nextObject]))
				if([eachViewController isKindOfClass:[MyCaseViewController class]])
					[eachViewController refreshDataSource];
		}
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:key] isEqualToString:@""])
			[GoogleAnalytics trackAction:GANActionPrefUserChangeEmail withLabel:@"Cleared" andTimeStamp:NO andUDID:YES];
		else
			[GoogleAnalytics trackAction:GANActionPrefUserChangeEmail withLabel:nil andTimeStamp:NO andUDID:YES];
	} else if ([key isEqualToString:@"Name"]) {
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:key] isEqualToString:@""])
			[GoogleAnalytics trackAction:GANActionPrefUserChangeName withLabel:@"Cleared" andTimeStamp:NO andUDID:YES];
		else 
			[GoogleAnalytics trackAction:GANActionPrefUserChangeName withLabel:nil andTimeStamp:NO andUDID:YES];
	}
}

#pragma mark -
#pragma mark Facebook

- (void)facebookSwitchAction:(id)sender{
    UISwitch *s = (UISwitch*)sender;
    NSString *isOn = [NSString stringWithString:@""];
    if ([s isOn]==YES)  isOn = @"YES";
    else    isOn = @"NO";
    NSLog(@"%@",isOn);
    [[NSUserDefaults standardUserDefaults] setObject:isOn forKey:@"fbSwitchInSetting"];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"switchInSettingDidChange"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([s isOn]==NO)
        return;
    
    //Facebook Login
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    facebook.accessToken = [prefs objectForKey:ACCESS_TOKEN_KEY];
    facebook.expirationDate = [prefs objectForKey:EXPIRATION_DATE_KEY];
    
    NSLog(@"accessToken: %@", facebook.accessToken);
    NSLog(@"expDate: %@", facebook.expirationDate);
    
    NSArray *permissions =  [NSArray arrayWithObjects:
                             @"read_stream", @"publish_stream", @"offline_access",nil];
    if (![facebook isSessionValid]){
        [facebook authorize:permissions delegate:self];
    }
}

- (void)fbDidLogin {
    NSLog(@"Did Log in");
    NSLog(@"AccessToken: %@", facebook.accessToken);
    NSLog(@"ExpirDate: %@", facebook.expirationDate);
    
    //Store the login session info
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:facebook.accessToken forKey:ACCESS_TOKEN_KEY];
    [prefs setObject:facebook.expirationDate forKey:EXPIRATION_DATE_KEY];
    [prefs synchronize];
}

- (void)fbDidNotLogin:(BOOL)cancelled{
    NSLog(@"Fail to login");
}

////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"request.url: %@", request.url);
    NSLog(@"result: %@", result);
    
};

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error localizedDescription]);
};



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section==0) return 2;
	else if (section==1 || section==2) return 1;
	else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section==0) return @"個人資訊";
	else if (section==1) return @"發佈設定";
    else if (section==2) return @"系統狀態";
	else if (section == [self numberOfSectionsInTableView:tableView]-1) return @"版本資訊";
	else return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	// Last section
	if (section == [self numberOfSectionsInTableView:tableView]-1) {
		NSString *infoString = [NSString stringWithFormat:@"路見不平 版本 %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
		
		if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"Release Info"]!=@"")
			infoString = [infoString stringByAppendingFormat:@"\n%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Release Info"]];
		if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Develop Mode"] boolValue])
			infoString = [infoString stringByAppendingFormat:@"\nDebug Mode"];
		
		infoString = [infoString stringByAppendingFormat:@"\n\n路見不平為開放原始碼軟體\n採用Apache License 2.0授權條款\nhttp://www.apache.org/licenses/\n\n程式原始碼可由Google Code取得\nhttp://code.google.com/p/m-gov/"];
		
		return infoString;
	} else return nil;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier1 = @"DefaultCell";
	static NSString *CellIdentifier2 = @"EditibleTextFieldCell";
	static NSString *CellIdentifier3 = @"IconCell";
	
	if (indexPath.section==0) {
		EditibleTextFieldCell *editibleCell = (EditibleTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (editibleCell == nil)
			editibleCell = [[[EditibleTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
		if (indexPath.section==0 && indexPath.row==0) {
			editibleCell.delegate = self;
			editibleCell.prefKey = @"User Email";
			editibleCell.titleField.text = @"E-Mail";
			editibleCell.contentField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"User Email"];
			editibleCell.contentField.placeholder = @"請輸入您的E-Mail帳號";
			editibleCell.contentField.keyboardType = UIKeyboardTypeEmailAddress;
			editibleCell.contentField.autocorrectionType = UITextAutocorrectionTypeNo;
			editibleCell.contentField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		} else if (indexPath.section==0 && indexPath.row==1) {
			editibleCell.delegate = self;
			editibleCell.prefKey = @"Name";
			editibleCell.titleField.text = @"姓名";
			editibleCell.contentField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Name"];
			editibleCell.contentField.placeholder = @"請輸入您的姓名";
			editibleCell.contentField.keyboardType = UIKeyboardTypeDefault;
			editibleCell.contentField.autocorrectionType = UITextAutocorrectionTypeNo;
			editibleCell.contentField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		}

		editibleCell.selectionStyle = UITableViewCellSeparatorStyleNone;
		return (UITableViewCell *)editibleCell;
		
	} else if (indexPath.section==1) { 
        UITableViewCell *toggleCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (toggleCell == nil){
            toggleCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1] autorelease];
        }
        toggleCell.selectionStyle = UITableViewCellEditingStyleNone;
            
        toggleCell.imageView.image = [UIImage imageNamed:@"fail.png"];
        toggleCell.textLabel.text = @"Facebook";
        UISwitch *facebookSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0, 26.0)];
        [facebookSwitch addTarget:self action:@selector(facebookSwitchAction:) forControlEvents:UIControlEventValueChanged];
        [facebookSwitch setBackgroundColor:[UIColor clearColor]];
        if ( [[[NSUserDefaults standardUserDefaults] objectForKey:@"fbSwitchInSetting"] isEqualToString:@"YES"]){
            facebookSwitch.on = YES;
        }
        else{
            facebookSwitch.on = NO;
        }
        toggleCell.accessoryView = facebookSwitch;
        [facebookSwitch release];
        return toggleCell;
        
    } else if (indexPath.section==2) {
		IconCell *cell = (IconCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
		if (cell==nil) {
			cell = [[[IconCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier3] autorelease];
		}
		
		cell.imageIconView.image = [UIImage imageNamed:@"ok.png"];
		cell.textField.text = @"XD";
		
		return (UITableViewCell *)cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
		if (cell == nil)
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1] autorelease];
		return cell;
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad{
    facebook = [[Facebook alloc] initWithAppId:kAppId];
    facebook.sessionDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void)viewDidUnload{
    [facebook release];
    //facebook = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}

@end

