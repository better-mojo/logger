"""Contextual logging example using bind().

This example demonstrates structured logging with bound context fields,
useful for tracking requests, users, and other contextual information.
"""

from spdlog import get_logger


def main() raises -> None:
    print("===== Loguru-style Logger Contextual Example =====")
    print()

    var logger = get_logger()

    # 1. Basic logging
    print("1. Basic logging:")
    logger.info("Application started")

    # 2. Create a bound logger for a user
    print("\n2. Creating bound logger for user 'alice':")
    var user_log = logger.bind("user_id", "12345")
    user_log = user_log.bind("username", "alice")
    user_log = user_log.bind("role", "admin")
    user_log.info("User logged in")
    user_log.debug("Loading user preferences")

    # 3. Create another bound logger for a different user
    print("\n3. Creating bound logger for user 'bob':")
    var bob_log = logger.bind("user_id", "67890")
    bob_log = bob_log.bind("username", "bob")
    bob_log = bob_log.bind("role", "user")
    bob_log.info("User logged in")
    bob_log.warn("Permission denied for admin feature")

    # 4. Nested binding - add more context
    print("\n4. Nested binding with request context:")
    var request_log = user_log.bind("request_id", "req-abc-123")
    request_log = request_log.bind("endpoint", "/api/users")
    request_log.info("Processing API request")
    request_log.debug("Query parameters: page=1&limit=10")
    request_log.info("Request completed in 45ms")

    # 5. Different operations with same context
    print("\n5. Multiple operations with same context:")
    var db_log = logger.bind("db", "production")
    db_log = db_log.bind("connection_id", "conn-xyz")
    db_log.info("Connecting to database")
    db_log.debug("Connection established")
    db_log.info("Executing query: SELECT * FROM users")
    db_log.info("Query returned 150 rows")
    db_log.debug("Closing connection")

    # 6. Error with context
    print("\n6. Error logging with context:")
    var error_log = logger.bind("service", "payment")
    error_log = error_log.bind("transaction_id", "txn-999")
    error_log.error("Payment processing failed")
    error_log.error("Error code: PAYMENT_DECLINED")

    print("\n===== Example completed =====")
