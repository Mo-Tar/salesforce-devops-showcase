public class StringUtils {

    // capitalize('hello') => 'Hello'
    public static String capitalize(String input) {
        if (input == null || input.length() == 0) return input;
        return input.substring(0, 1).toUpperCase() 
             + input.substring(1).toLowerCase();
    }

    // isPalindrome('racecar') => true
    public static Boolean isPalindrome(String input) {
        if (input == null) return false;
        String cleaned = input.toLowerCase()
                              .replaceAll('[^a-z0-9]', '');
        return cleaned == cleaned.reverse();
    }
}