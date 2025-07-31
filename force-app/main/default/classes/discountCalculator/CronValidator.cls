public class CronValidator {

    private static final Map<String, Integer> DAY_OF_WEEK_MAP = new Map<String, Integer>{
            'SUN' => 1, 'MON' => 2, 'TUE' => 3, 'WED' => 4, 'THU' => 5, 'FRI' => 6, 'SAT' => 7
    };

    public static Boolean isDue(String cronExpression, TimeZone userTimeZone) {
        Datetime now = Datetime.now();

        List<String> parts = cronExpression.split(' ');
        if (parts.size() < 6) {
            System.debug(LoggingLevel.ERROR, 'Nieprawidłowy format cron. Oczekiwano co najmniej 6 części.');
            return false;
        }

        Integer currentSecond = Integer.valueOf(now.format('s', userTimeZone.getID()));
        Integer currentMinute = Integer.valueOf(now.format('m', userTimeZone.getID()));
        Integer currentHour = Integer.valueOf(now.format('H', userTimeZone.getID()));
        Integer currentDayOfMonth = Integer.valueOf(now.format('d', userTimeZone.getID()));
        Integer currentMonth = Integer.valueOf(now.format('M', userTimeZone.getID()));
        Integer currentDayOfWeek = Integer.valueOf(now.format('u', userTimeZone.getID())) == 7 ? 1 : Integer.valueOf(now.format('u', userTimeZone.getID())) + 1;
        Integer currentYear = Integer.valueOf(now.format('yyyy', userTimeZone.getID()));

        Boolean dayOfMonthIsWildcard = (parts[3] == '?');
        Boolean dayOfWeekIsWildcard = (parts[5] == '?');

        if (dayOfMonthIsWildcard == dayOfWeekIsWildcard) {
            return false;
        }

        Boolean secondsMatch = checkValue(currentSecond, parts[0]);
        Boolean minutesMatch = checkValue(currentMinute, parts[1]);
        Boolean hoursMatch = checkValue(currentHour, parts[2]);
        Boolean monthsMatch = checkValue(currentMonth, parts[4]);
        Boolean yearsMatch = (parts.size() < 7 || checkValue(currentYear, parts[6]));

        Boolean dayOfMonthMatch = dayOfMonthIsWildcard ? true : checkValue(currentDayOfMonth, parts[3]);
        Boolean dayOfWeekMatch = dayOfWeekIsWildcard ? true : checkDayOfWeek(currentDayOfWeek, parts[5]);

        if (dayOfMonthIsWildcard) {
            return secondsMatch && minutesMatch && hoursMatch && monthsMatch && dayOfWeekMatch && yearsMatch;
        } else {
            return secondsMatch && minutesMatch && hoursMatch && monthsMatch && dayOfMonthMatch && yearsMatch;
        }
    }
    private static Boolean checkValue(Integer value, String cronPart) {
        if (cronPart == '*' || cronPart == '?') {
            return true;
        }

        if (cronPart.contains(',')) {
            for (String part : cronPart.split(',')) {
                if (checkValue(value, part)) {
                    return true;
                }
            }
            return false;
        }

        if (cronPart.contains('/')) {
            List<String> stepParts = cronPart.split('/');
            Integer step = Integer.valueOf(stepParts[1]);
            if (stepParts[0] == '*') {
                return (Math.mod(value, step) == 0);
            } else {
                if (stepParts[0].contains('-')) {
                    List<String> rangeParts = stepParts[0].split('-');
                    Integer start = Integer.valueOf(rangeParts[0]);
                    if (value >= start) {
                        return (Math.mod(value - start, step) == 0);
                    }
                }
            }
            return false;
        }

        if (cronPart.contains('-')) {
            List<String> rangeParts = cronPart.split('-');
            Integer start = Integer.valueOf(rangeParts[0]);
            Integer endVal = Integer.valueOf(rangeParts[1]); // changed from 'end' to 'endVal'
            return (value >= start && value <= endVal);
        }

        return Integer.valueOf(cronPart) == value;
    }

    private static Boolean checkDayOfWeek(Integer currentDayNum, String cronPart) {
        if (cronPart == '*' || cronPart == '?') {
            return true;
        }

        cronPart = cronPart.toUpperCase();

        if (cronPart.contains(',')) {
            for (String part : cronPart.split(',')) {
                if (checkDayOfWeek(currentDayNum, part)) {
                    return true;
                }
            }
            return false;
        }

        if (cronPart.contains('-')) {
            List<String> rangeParts = cronPart.split('-');
            Integer start = DAY_OF_WEEK_MAP.get(rangeParts[0]);
            Integer endVal = DAY_OF_WEEK_MAP.get(rangeParts[1]); // changed from 'end' to 'endVal'

            if (start == null || endVal == null) return false;

            if (start <= endVal) {
                return currentDayNum >= start && currentDayNum <= endVal;
            } else {
                return currentDayNum >= start || currentDayNum <= endVal;
            }
        }

        return DAY_OF_WEEK_MAP.get(cronPart) == currentDayNum;
    }
}