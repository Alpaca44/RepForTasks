public class AccountTriggerHandler extends TriggerHandler{
   public override void afterInsert(){ 
       AccountTriggerHelper.createOpportunity(); 
   }
 
   public override void afterUpdate(){   
    AccountTriggerHelper.updateOpportunity(); 
   }

   
   public override void beforeDelete(){   
    AccountTriggerHelper.deleteOpportunity(); 
   }
}
