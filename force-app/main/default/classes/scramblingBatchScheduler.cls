public class scramblingBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new scramblingBatch());
    }
}