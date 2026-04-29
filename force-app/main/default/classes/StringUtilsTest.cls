@IsTest
public class StringUtilsTest {

    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'stdusr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Edmonton',
            UserName = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert u;
        return u;
    }

    @IsTest
    static void testCapitalize() {
        User u = createTestUser();
        System.runAs(u) {
            Assert.areEqual('Hello', StringUtils.capitalize('hello'), 'Should capitalize first letter and lowercase rest');
            Assert.areEqual('Hello', StringUtils.capitalize('HELLO'), 'Should handle all-uppercase input');
        }
    }

    @IsTest
    static void testCapitalizeNull() {
        User u = createTestUser();
        System.runAs(u) {
            Assert.isNull(StringUtils.capitalize(null), 'Should return null when input is null');
        }
    }

    @IsTest
    static void testIsPalindrome() {
        User u = createTestUser();
        System.runAs(u) {
            Assert.isTrue(StringUtils.isPalindrome('racecar'), 'racecar should be a palindrome');
            Assert.isFalse(StringUtils.isPalindrome('hello'), 'hello should not be a palindrome');
        }
    }

    @IsTest
    static void testIsPalindromeNull() {
        User u = createTestUser();
        System.runAs(u) {
            Assert.isFalse(StringUtils.isPalindrome(null), 'Should return false when input is null');
        }
    }
}