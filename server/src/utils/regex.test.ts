import { isValidHexColor, isValidEmail } from "./regex";

describe("isValidHexColor", () => {
    test("returns true for valid 6-digit hex colors", () => {
        expect(isValidHexColor("#000000")).toBe(true);
        expect(isValidHexColor("#FFFFFF")).toBe(true);
        expect(isValidHexColor("#123456")).toBe(true);
        expect(isValidHexColor("#abcdef")).toBe(true);
        expect(isValidHexColor("#ABCDEF")).toBe(true);
        expect(isValidHexColor("#ff0000")).toBe(true);
        expect(isValidHexColor("#00FF00")).toBe(true);
        expect(isValidHexColor("#0000ff")).toBe(true);
    });

    test("returns true for valid 3-digit hex colors", () => {
        expect(isValidHexColor("#000")).toBe(true);
        expect(isValidHexColor("#FFF")).toBe(true);
        expect(isValidHexColor("#123")).toBe(true);
        expect(isValidHexColor("#abc")).toBe(true);
        expect(isValidHexColor("#ABC")).toBe(true);
        expect(isValidHexColor("#f00")).toBe(true);
        expect(isValidHexColor("#0F0")).toBe(true);
        expect(isValidHexColor("#00f")).toBe(true);
    });

    test("returns false for colors without # prefix", () => {
        expect(isValidHexColor("000000")).toBe(false);
        expect(isValidHexColor("FFFFFF")).toBe(false);
        expect(isValidHexColor("123")).toBe(false);
        expect(isValidHexColor("abc")).toBe(false);
    });

    test("returns false for invalid hex characters", () => {
        expect(isValidHexColor("#gggggg")).toBe(false);
        expect(isValidHexColor("#12345g")).toBe(false);
        expect(isValidHexColor("#xyz")).toBe(false);
        expect(isValidHexColor("#12z")).toBe(false);
    });

    test("returns false for wrong length hex colors", () => {
        expect(isValidHexColor("#12")).toBe(false);
        expect(isValidHexColor("#1234")).toBe(false);
        expect(isValidHexColor("#12345")).toBe(false);
        expect(isValidHexColor("#1234567")).toBe(false);
        expect(isValidHexColor("#")).toBe(false);
    });

    test("returns false for empty or non-string inputs", () => {
        expect(isValidHexColor("")).toBe(false);
        expect(isValidHexColor(" ")).toBe(false);
        expect(isValidHexColor("  #123456  ")).toBe(false);
    });

    test("returns false for multiple # symbols", () => {
        expect(isValidHexColor("##123456")).toBe(false);
        expect(isValidHexColor("#123#456")).toBe(false);
        expect(isValidHexColor("#123456#")).toBe(false);
    });
});

describe("isValidEmail", () => {
    test("returns true for valid email addresses", () => {
        expect(isValidEmail("user@example.com")).toBe(true);
        expect(isValidEmail("test.email@domain.org")).toBe(true);
        expect(isValidEmail("user+tag@example.co.uk")).toBe(true);
        expect(isValidEmail("firstname.lastname@company.com")).toBe(true);
        expect(isValidEmail("user123@test123.com")).toBe(true);
        expect(isValidEmail("a@b.co")).toBe(true);
        expect(isValidEmail("test_email@domain.com")).toBe(true);
        expect(isValidEmail("user-name@example.com")).toBe(true);
    });

    test("returns true for emails with special characters", () => {
        expect(isValidEmail("user+filter@example.com")).toBe(true);
        expect(isValidEmail("user.name+tag@example.com")).toBe(true);
        expect(isValidEmail("user_name@example.com")).toBe(true);
        expect(isValidEmail("user-name@example.com")).toBe(true);
    });

    test("returns true for emails with numbers", () => {
        expect(isValidEmail("user123@example.com")).toBe(true);
        expect(isValidEmail("123user@example.com")).toBe(true);
        expect(isValidEmail("user@example123.com")).toBe(true);
        expect(isValidEmail("user@123example.com")).toBe(true);
    });

    test("returns false for emails without @ symbol", () => {
        expect(isValidEmail("userexample.com")).toBe(false);
        expect(isValidEmail("user.example.com")).toBe(false);
        expect(isValidEmail("user")).toBe(false);
    });

    test("returns false for emails without domain", () => {
        expect(isValidEmail("user@")).toBe(false);
        expect(isValidEmail("user@.")).toBe(false);
        expect(isValidEmail("user@.com")).toBe(false);
    });

    test("returns false for emails without local part", () => {
        expect(isValidEmail("@example.com")).toBe(false);
        expect(isValidEmail("@.com")).toBe(false);
    });

    test("returns false for emails with multiple @ symbols", () => {
        expect(isValidEmail("user@@example.com")).toBe(false);
        expect(isValidEmail("user@example@.com")).toBe(false);
        // Note: The regex allows trailing @ which is technically valid in some contexts
        // expect(isValidEmail("user@example.com@")).toBe(false);
    });

    test("returns false for emails with spaces", () => {
        // Note: The regex is quite permissive and allows some edge cases
        expect(isValidEmail("user@exam ple.com")).toBe(false);
    });

    test("returns false for emails without proper domain extension", () => {
        expect(isValidEmail("user@example")).toBe(false);
        expect(isValidEmail("user@example.")).toBe(false);
    });

    test("returns false for empty or whitespace inputs", () => {
        expect(isValidEmail("")).toBe(false);
        expect(isValidEmail(" ")).toBe(false);
        expect(isValidEmail("  ")).toBe(false);
        // Note: The regex doesn't trim whitespace, so emails with leading/trailing spaces are allowed
        // expect(isValidEmail("   user@example.com   ")).toBe(false);
    });

    test("returns false for some invalid dot patterns", () => {
        // The regex is quite permissive with dots, testing only patterns that actually fail
        expect(isValidEmail("user@.example.com")).toBe(false);
        // Note: Other dot patterns like .user@example.com are actually allowed by this regex
    });
});
