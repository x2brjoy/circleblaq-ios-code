//
//  ContacDataBase.m
//  Sup
//
//  Created by Rahul Sharma on 7/7/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "ContacDataBase.h"
#import "MacroFile.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "AppDelegate.h"

static ContacDataBase *contacClass = nil;

@implementation ContacDataBase
@synthesize contacPropertydict;


+(instancetype)sharedInstance{
    
    if (!contacClass) {
        
      static  dispatch_once_t tocken;
        dispatch_once(&tocken, ^{
            contacClass = [[ContacDataBase alloc]init];
        });
    }
    return contacClass;
}

//get databaseObject
-(CBLDatabase*)getDataBaseObject{
    
    AppDelegate *appdeleget = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    CBLManager* bgMgr = [[appdeleget manager] copy];
    NSError *error;
    CBLDatabase* bgDB = [bgMgr databaseNamed:@"couchbasenew" error: &error];
    
    return bgDB;
}



-(void)getDocumentInfoForID:(NSString *)docID{
    
    docID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:contacDBDocumentID]];
    
    CBLDatabase* bgDB = [self getDataBaseObject];
    CBLDocument *document = [bgDB documentWithID:docID];
    
    [self getDetailsForDocument:document];
    
}


-(NSDictionary *)getDetailsForDocument:(CBLDocument *) document {
    
    //NSError *Error;
    // NSLog(@"hello =%@",[document getRevisionHistory:&Error]);
    // return document.currentRevision.properties;
    contacPropertydict = document.properties;
   // NSLog(@"kkk =%@",contacPropertydict);

    return document.properties;
}

//get data From db
-(NSArray *)getDataContacDataFromDB{
    
  // NSString  *docID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:contacDBDocumentID]];
   
  //  CBLDatabase* bgDB = [self getDataBaseObject];
   // CBLDocument *document = [bgDB documentWithID:docID];
    
   // NSDictionary *dict =[self getDetailsForDocument:document];
    
    if (contacPropertydict ==nil) {
        [self getDocumentInfoForID:@""];
    }

    return [contacPropertydict objectForKey:@"messages"];
}


//delete all data from db
-(void)deleteAllContacDataFromDB{
    
    
    //delete document messages
    NSMutableArray *blankArr = [NSMutableArray new];
    CBLDatabase* bgDB =[self getDataBaseObject];
    [self saveDataInDocument:@"" withMessages:blankArr];

}


//update document
-(void)saveDataInDocument:(NSString *)documentID withMessages:(NSMutableArray *)messages{

   
    static CouchbaseEvents *cbEvent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cbEvent = [[CouchbaseEvents alloc] init];
    });

    
    CBLDatabase* bgDB =[self getDataBaseObject];
    documentID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:contacDBDocumentID]];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:contacPropertydict];
    [dict setValue:[messages copy] forKey:@"messages"];
    contacPropertydict = [dict copy];
    [cbEvent updateDocument:bgDB documentId:documentID withMessages:[messages copy]];
    

}

-(void)updateContacDatabase:(NSDictionary *)dict contacID:(NSString*)contcID{
    
   
    
    NSArray *contacAlldata = [[NSArray alloc]initWithArray:[self getDataContacDataFromDB]];
    NSMutableArray *tempArr = [NSMutableArray new];
    [tempArr addObjectsFromArray:contacAlldata];
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"contactID == %@",contcID];
    NSArray *contactsArray = [contacAlldata filteredArrayUsingPredicate:bPredicate];
    

    if (contactsArray.count>0) {
     
      NSDictionary  *contactObj1 = [contactsArray firstObject];
         NSInteger indexOfdict = [contacAlldata indexOfObject:contactObj1];
         NSMutableDictionary *contactObj = [[NSMutableDictionary alloc]init];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"firstName"]] forKey:@"firstName"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"lastName"]]  forKey:@"lastName"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fullName"]]  forKey:@"fullName"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"profilePic"]]  forKey:@"profilePic"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"supNumber"]]  forKey:@"supNumber"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"alternateNumbers"]]  forKey:@"alternateNumbers"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"status"]]  forKey:@"status"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"contactID"]]  forKey:@"contactID"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"modificationDate"]]  forKey:@"modificationDate"];
        [contactObj setValue:[dict objectForKey:@"arrayOfalternateNumbers"]  forKey:@"arrayOfalternateNumbers"];
        
        [tempArr replaceObjectAtIndex:indexOfdict withObject:[contactObj copy]];
        
        [self saveDataInDocument:@"" withMessages:[tempArr copy]];
        
    }

    
}





-(NSArray*)updateContacDBtoRemove:(NSDictionary*)dict contacID:(NSString*)contcID{
    
    
    NSArray *contacAlldata = [[NSArray alloc]initWithArray:[self getDataContacDataFromDB]];
    NSMutableArray *tempArr = [NSMutableArray new];
    [tempArr addObjectsFromArray:contacAlldata];
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"contactID == %@",contcID];
    NSArray *contactsArray = [contacAlldata filteredArrayUsingPredicate:bPredicate];
    
    
    if (contactsArray.count>0) {
        
        NSDictionary  *contactObj1 = [contactsArray firstObject];
        NSInteger indexOfdict = [contacAlldata indexOfObject:contactObj1];
        NSMutableDictionary *contactObj = [[NSMutableDictionary alloc]init];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"firstName"]] forKey:@"firstName"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"lastName"]]  forKey:@"lastName"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fullName"]]  forKey:@"fullName"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"profilePic"]]  forKey:@"profilePic"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"supNumber"]]  forKey:@"supNumber"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"alternateNumbers"]]  forKey:@"alternateNumbers"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"status"]]  forKey:@"status"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"contactID"]]  forKey:@"contactID"];
        [contactObj setValue:[NSString stringWithFormat:@"%@",[dict objectForKey:@"modificationDate"]]  forKey:@"modificationDate"];
        [contactObj setValue:[dict objectForKey:@"arrayOfalternateNumbers"]  forKey:@"arrayOfalternateNumbers"];
        
        [tempArr replaceObjectAtIndex:indexOfdict withObject:[contactObj copy]];
        
        //[self saveDataInDocument:@"" withMessages:[tempArr copy]];
        return [tempArr copy];
        
    }

    
    return contacAlldata;
    
}


-(void)deleteObjectFromDB:(NSDictionary *)dict contacID:(NSString *)contcID{
    
    NSArray *contacAlldata = [[NSArray alloc]initWithArray:[self getDataContacDataFromDB]];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"contactID == %@",contcID];
    NSArray *contactsArray = [contacAlldata filteredArrayUsingPredicate:bPredicate];
    
    
    if (contactsArray.count>0) {
    
     NSInteger indexOfdict = [contacAlldata indexOfObject:dict];
   // NSLog(@"index =%ld",(long)indexOfdict);
    
    if (contacAlldata.count >indexOfdict) {
    NSMutableArray *tempArr = [[NSMutableArray alloc]initWithArray:contacAlldata];
    [tempArr removeObjectAtIndex:indexOfdict];
    [self saveDataInDocument:@"" withMessages:[tempArr copy]];
    }
    
    }
}

-(NSArray*)deleteObjectFromDBtoRemove:(NSDictionary*)dict contacID:(NSString *)contcID{
    
    NSArray *contacAlldata = [[NSArray alloc]initWithArray:[self getDataContacDataFromDB]];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"contactID == %@",contcID];
    NSArray *contactsArray = [contacAlldata filteredArrayUsingPredicate:bPredicate];
    
    
    if (contactsArray.count>0) {
        
        NSInteger indexOfdict = [contacAlldata indexOfObject:dict];

        
        if (contacAlldata.count >indexOfdict) {
            NSMutableArray *tempArr = [[NSMutableArray alloc]initWithArray:contacAlldata];
            [tempArr removeObjectAtIndex:indexOfdict];
            
            return [tempArr copy];
           // [self saveDataInDocument:@"" withMessages:[tempArr copy]];
        }
        
    }


    
    return contacAlldata;
    
}

@end
