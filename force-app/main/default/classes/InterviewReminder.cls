public class InterviewReminder implements Schedulable {
    public InterviewReminder() {}

    public void execute (SchedulableContext sc) {
        EventUtilityClass.sendReminderEmail();
    }
}