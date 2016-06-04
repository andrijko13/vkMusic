//
//  FriendController.m
//  vkMusic
//
//  Created by Andriy Suden on 6/4/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import "FriendController.h"
#import "AppDelegate.h"

@interface FriendController ()
{
    NSMutableArray *_friends;
}

@end

@implementation FriendController
@synthesize _delegate;
@synthesize _musicTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self._delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _friends = [NSMutableArray array];
    //VKRequest *req = [VKRequest requestWithMethod:@"friends.get" andParameters:@{VK_API_FIELDS : @[@"uid", @"first_name", @"last_name"]} andHttpMethod:@"GET" classOfModel:[VKUser class]];
    VKRequest *req = [VKRequest requestWithMethod:@"friends.get" parameters:@{VK_API_FIELDS : @[@"uid", @"first_name", @"last_name"]}];
    [req executeWithResultBlock:^(VKResponse *response) {
        NSDictionary *a = response.json;
        //NSLog(@"%@",a);
        for (NSDictionary *user in [a objectForKey:@"items"]) {
            [_friends addObject:user];
//            NSString  *first = [user objectForKey:@"first_name"];
//            NSString  *last  = [user objectForKey:@"last_name"];
//            NSUInteger uid   = [[user objectForKey:@"id"] unsignedLongValue];
//            NSString *name = [NSString stringWithFormat:@"%@ %@",first, last]
        }
        //NSLog(@"Json result: %@", response.parsedModel);
        [_musicTable reloadData];
    } errorBlock:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return [NSString stringWithFormat:@"Friend List"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_friends count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    
    NSDictionary *user = [_friends objectAtIndex:indexPath.row];
    NSString  *first = [user objectForKey:@"first_name"];
    NSString  *last  = [user objectForKey:@"last_name"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",first, last];
    
    //    cell.textLabel.text = song.title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
        
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        unsigned long uid = [[[_friends objectAtIndex:indexPath.row] objectForKey:@"id"] unsignedLongValue];
        [self._delegate setFriend:uid];

        [self performSegueWithIdentifier:@"friends_music" sender:self];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
