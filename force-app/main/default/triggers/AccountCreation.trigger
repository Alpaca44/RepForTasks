trigger AccountCreation on Account (after insert) {
    List<Opportunity> oppList = new List<Opportunity>();
    DateTime todaysDate = System.today();
    String todaysDateStr = todaysDate.format('yyyy-MM');
    for(Account a : Trigger.New) {
       
        oppList.add(new Opportunity(Name=a.Name + todaysDateStr,
                                    StageName='Prospecting',
                                    CloseDate=System.today().addDays(90),
                                    AccountId=a.Id));
    }
    
    insert oppList;
    
}