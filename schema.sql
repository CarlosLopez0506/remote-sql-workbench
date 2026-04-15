-- =============================================================
-- Remote SQL Architect and Explorer
-- Phase A: Database Design (DDL)
-- Fintech Schema — 3rd Normal Form (3NF)
-- =============================================================

PRAGMA foreign_keys = ON;

-- -------------------------------------------------------------
-- Table: users
-- Stores customer profile data.
-- 3NF: each non-key attribute (email, full_name, phone,
-- created_at) depends solely on the primary key `id`.
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    email       TEXT    NOT NULL UNIQUE,
    full_name   TEXT    NOT NULL,
    phone       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- -------------------------------------------------------------
-- Table: accounts
-- A customer can hold multiple accounts (checking, savings…).
-- Linked to users via user_id FK → users.id.
-- 3NF: balance, account_type, status depend only on `id`;
-- no transitive dependency through user_id.
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS accounts (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL,
    account_number  TEXT    NOT NULL UNIQUE,
    account_type    TEXT    NOT NULL CHECK (account_type IN ('CHECKING', 'SAVINGS', 'INVESTMENT')),
    balance         REAL    NOT NULL DEFAULT 0.00,
    status          TEXT    NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    opened_at       TEXT    NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- -------------------------------------------------------------
-- Table: transactions
-- Every debit or credit movement on an account.
-- Linked to accounts via account_id FK → accounts.id.
-- 3NF: amount, type, description, status depend only on `id`.
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transactions (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id  INTEGER NOT NULL,
    amount      REAL    NOT NULL CHECK (amount > 0),
    type        TEXT    NOT NULL CHECK (type IN ('CREDIT', 'DEBIT')),
    description TEXT,
    status      TEXT    NOT NULL DEFAULT 'COMPLETED' CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REVERSED')),
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
);
