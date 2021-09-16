public with sharing class AccountTriggerHelper {
 
 //When the Account record is created then the related Opportunity record should be automatically created.
 //Name should be the same as the Account plus current month and year, stage should be “Prospecting” 
 //and Close date should be today plus 90 days
    public static void createOpportunity() {
        List<Opportunity> oppList = new List<Opportunity>();
    DateTime todaysDate = System.today();
    String todaysDateStr = todaysDate.format('yyyy-MM');
    for (Account a :(List<Account>) Trigger.New) {
       
        oppList.add(new Opportunity(Name=a.Name + todaysDateStr,
                                    StageName='Prospecting',
                                    CloseDate=System.today().addDays(90),
                                    AccountId=a.Id));
    }
    
    insert oppList;
    }


    //On Account update we need to check if the Opportunity name contains the right Account Name 
    //if not update the name of Opp.
    public static void updateOpportunity() {
        List<Opportunity> oppFullList = new List<Opportunity>();
    
        Map<Id,Account> acctsWithOpps = new Map<Id,Account>(
            [SELECT Id,(SELECT Id,Name FROM Opportunities) FROM Account WHERE Id IN :Trigger.New]);
       
       
        for(Account a:(List<Account>) Trigger.New) {
        List<Opportunity> oppSmallList=acctsWithOpps.get(a.Id).Opportunities;
          for(Opportunity o: oppSmallList)
          { 
              if(!o.Name.contains(a.Name))
              {
                  o.Name+=' '+a.Name;
              }
          }
          oppFullList.addAll(oppSmallList);
        }
        
        update oppFullList;
    }

    
      //On Delete of Account we need to delete all related Opportunities and send Confirmation email 
   //to current user with deleted records Ids and Names
   public static void deleteOpportunity() {
    Map<Id,Account> acctsWithOpps = new Map<Id,Account>(
       [SELECT Id,(SELECT Id,Name FROM Opportunities) FROM Account WHERE Id IN :Trigger.New]);
     List<Opportunity> oppFullList = new List<Opportunity>();
     Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
     String emailBody;
     
     for(Account a:(List<Account>) Trigger.New) {
        List<Opportunity> oppList = new List<Opportunity>();
        oppList=acctsWithOpps.get(a.Id).Opportunities;
        for(Opportunity o: oppList){
            emailBody+='Name: '+o.Name+' Id: '+o.Id+';\n';
        }
       
        oppFullList.addAll(oppList);
      }
    
       email.setToAddresses(new String[] {UserInfo.getUserEmail()});
       email.setSubject('Deleted Opportunities');
       email.setPlainTextBody(
           'List of deleted records:\n'+emailBody
       );
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

       delete oppFullList;
}
}
