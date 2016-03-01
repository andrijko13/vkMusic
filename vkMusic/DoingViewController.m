//
//  DoingViewController.m
//  vkMusic
//
//  Created by Andriy Suden on 2/22/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import "DoingViewController.h"

@interface DoingViewController (){
    NSMutableArray *_vkmusic;
    //UIProgressView *_progress;
    NSMutableData *_receivedData;
    long long _expectedBytes;
    NSString *_fileName;
}
@end

@implementation DoingViewController
@synthesize _musicTable;
@synthesize _progress;
@synthesize _downloadLabel;

#pragma mark view config

- (void)viewDidLoad {
    
    _progress.hidden = YES;
    _downloadLabel.hidden = YES;

    [super viewDidLoad];
    _vkmusic = [[NSMutableArray alloc] initWithCapacity:30];
    // Do any additional setup after loading the view.
    VKRequest *req = [VKRequest requestWithMethod:@"audio.get" andParameters:nil andHttpMethod:@"GET" classOfModel:[VKAudios class]];
    [req executeWithResultBlock:^(VKResponse *response) {
        for (VKAudio *a in response.parsedModel) {
            [_vkmusic addObject:a];
            //NSLog(@"%@", a.title);
        }
        [_musicTable reloadData];
    } errorBlock:nil];
}

#pragma mark Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return [NSString stringWithFormat:@"Your VK Music"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_vkmusic count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    VKAudio *song = [_vkmusic objectAtIndex:indexPath.row];
    cell.textLabel.text = song.title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
        //(your code opening a new view)
        VKAudio *song = [_vkmusic objectAtIndex:indexPath.row];
        NSString *url = [self parseMp3:song];
        
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        _fileName = [NSString stringWithFormat:@"%@/music/%@", documentsDirectory,[song.title stringByAppendingString:@".mp3"]];
        
        [self downloadFromURL:url name:[song.title stringByAppendingString:@".mp3"]];
    }
}

-(NSString *)parseMp3:(VKAudio const*)song{
    NSString *fullPath = [NSString stringWithFormat:@"%@", song.url];
    
    NSRange rangeOfMp3 = [fullPath rangeOfString:@".mp3"];
    NSUInteger length = rangeOfMp3.length + rangeOfMp3.location;
    NSString *str = [fullPath substringToIndex:length];
    
    NSLog(@"%@",fullPath);
    if (str) return str;
    return nil;
}

-(void)download1{
    NSString *stringURL = @"http://www.somewhere.com/thefile.png";
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData )
    {
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"filename.png"];
        [urlData writeToFile:filePath atomically:YES];
    }
}

-(void)downloadFromURL:(NSString *)urlToDownload name:(NSString *)fileName{
    NSLog(@"Downloading Started");
    NSURL  *url = [NSURL URLWithString:urlToDownload];
    //NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    _receivedData = [[NSMutableData alloc] initWithLength:0];
    NSURLConnection * connection __unused = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self     startImmediately:YES];
    
    //download the file in a seperate thread.
    /*(dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Downloading Started");
        NSURL  *url = [NSURL URLWithString:urlToDownload];
        //NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:url         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
        _receivedData = [[NSMutableData alloc] initWithLength:0];
        NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self     startImmediately:YES];*/
        
        /*if ( urlData )
        {
            NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/music/%@", documentsDirectory,fileName];
            
            //saving is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
                NSLog(@"File Saved !");
            });
        }*/
    //});
    
    
    
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Received response from connection");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _progress.hidden = NO;
    _downloadLabel.hidden = NO;
    [_receivedData setLength:0];
    _expectedBytes = [response expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Received data from connection");
    [_receivedData appendData:data];
    float progressive = (float)[_receivedData length] / (float)_expectedBytes;
    [_progress setProgress:progressive];
    
    
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Download Failed");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:    (NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:[currentURL stringByAppendingString:@".mp3"]];
    NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_receivedData writeToFile:_fileName atomically:YES];
    _progress.hidden = YES;
    _downloadLabel.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backMainButton:(id)sender {
    [self performSegueWithIdentifier:@"backMain" sender:self];
}
@end
