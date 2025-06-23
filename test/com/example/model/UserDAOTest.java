package com.example.model;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

import java.sql.Connection;
import java.sql.PreparedStatement;

import com.example.util.DatabaseUtil;

public class UserDAOTest {

    private UserDAO userDAO;
    private final String testUsername = "testuser_junit";
    private final String testPassword = "password123";

    // This method runs before each test.
    // It cleans up any leftover data from previous test runs to ensure test independence.
    @Before
    public void setUp() throws Exception {
        userDAO = new UserDAO();
        // Clean up the test user from the database if it exists
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE username = ?")) {
            ps.setString(1, testUsername);
            ps.executeUpdate();
        }
    }

    // This method runs after each test to clean up.
    @After
    public void tearDown() throws Exception {
        // Just in case, clean up again.
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE username = ?")) {
            ps.setString(1, testUsername);
            ps.executeUpdate();
        }
    }

    @Test
    public void testAddUser_Success() {
        User user = new User(testUsername, testPassword);
        assertTrue("Should successfully add a new user", userDAO.addUser(user));
        
        // Verify that the user was actually added
        assertNotNull("Added user should be findable in the database", userDAO.findByUsername(testUsername));
    }

    @Test
    public void testAddUser_Duplicate() {
        // Add the user for the first time
        User user = new User(testUsername, testPassword);
        userDAO.addUser(user);

        // Try to add the same user again
        assertFalse("Should fail to add a duplicate user", userDAO.addUser(user));
    }

    @Test
    public void testFindByUsername_Exists() {
        // Add a user to be found
        User user = new User(testUsername, testPassword);
        userDAO.addUser(user);

        // Try to find the user
        User foundUser = userDAO.findByUsername(testUsername);
        assertNotNull("Should find an existing user", foundUser);
        assertEquals("Found user should have the correct username", testUsername, foundUser.getUsername());
    }

    @Test
    public void testFindByUsername_NotExists() {
        // Try to find a user that does not exist
        User foundUser = userDAO.findByUsername("nonexistent_user");
        assertNull("Should not find a non-existent user", foundUser);
    }
} 