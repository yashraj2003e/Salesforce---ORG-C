public class scrambleCustomerUsersScheduler implements Schedulable {
    public void execute(SchedulableContext sc){
        Database.executeBatch(new scramblingBatch());
    }
}