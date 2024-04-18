public with sharing class FlowHandler {

    @invocableMethod (label='Check for Interview Overlap' description='Check for interview overlap with existing events')
    public static List<Boolean> checkForInterviewOverlap(List<List<DateTime>> interviewStartEndTimes) {
        List<Boolean> overLapFound = new List<Boolean>();
        
        for (List<DateTime> times : interviewStartEndTimes) {
            List<Boolean> overlaps = new List<Boolean>();
            DateTime startTime = times[0];
            DateTime endTime = times[1];
            Date interviewDate = startTime.Date();
            // Find all events that are scheduled for the same date as the interview
            List<Event> events = [SELECT Id, Subject, StartDateTime, EndDateTime FROM Event WHERE DAY_ONLY(StartDateTime) = :interviewDate];
            // Check if any event overlaps with the interview period (startTime, endTime)
            if (events.size() == 0) {
                overlaps.add(false);
            } else {
                for (Event event : events) {
                    Boolean overlap = false;
                    if (startTime >= event.StartDateTime && startTime <= event.EndDateTime) {
                        overlap = true;
                    } else if (endTime >= event.StartDateTime && endTime <= event.EndDateTime) {
                        overlap = true;
                    } else if (startTime <= event.StartDateTime && endTime >= event.EndDateTime) {
                        overlap = true;
                    } 
                    overlaps.add(overlap);
                }
            }
            // For each interview datetime passed in from flow, return true/false if overlap found
            overLapFound.add(overlaps.contains(true));
        }
        return overLapFound;
    }
}