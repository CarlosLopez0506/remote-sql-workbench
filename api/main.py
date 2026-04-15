"""
Remote SQL Architect and Explorer
Phase B: API Proxy

Exposes POST /query — receives a SQL string, validates it,
executes it against the local SQLite database, and returns
the result as a JSON object.

Run:
    pip install -r requirements.txt
    python main.py
"""

import os
import re
import sqlite3
import pathlib
from contextlib import contextmanager
from typing import Any

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, field_validator

# ──────────────────────────────────────────────
# Paths
# ──────────────────────────────────────────────
BASE_DIR = pathlib.Path(__file__).parent.parent  # pimentel/
DB_PATH  = BASE_DIR / "fintech.db"
SCHEMA   = BASE_DIR / "schema.sql"
SEED     = BASE_DIR / "seed.sql"

# ──────────────────────────────────────────────
# Security: forbidden keyword patterns
# These are checked against the normalised query
# (upper-case, collapsed whitespace).
# ──────────────────────────────────────────────
FORBIDDEN_PATTERNS: list[re.Pattern] = [
    re.compile(r"\bDROP\b"),
    re.compile(r"\bTRUNCATE\b"),
    re.compile(r"\bALTER\b"),
    re.compile(r"\bATTACH\b"),
    re.compile(r"\bDETACH\b"),
    re.compile(r"\bPRAGMA\b"),
    re.compile(r"\bLOAD_EXTENSION\b"),
]

MAX_QUERY_LENGTH = 2_000  # characters


# ──────────────────────────────────────────────
# Database bootstrap
# ──────────────────────────────────────────────
def bootstrap_db() -> None:
    """Create tables and seed data if the DB does not exist yet."""
    if DB_PATH.exists():
        return
    print(f"[bootstrap] Creating database at {DB_PATH}")
    con = sqlite3.connect(DB_PATH)
    try:
        con.execute("PRAGMA foreign_keys = ON;")
        con.executescript(SCHEMA.read_text())
        con.executescript(SEED.read_text())
        con.commit()
        print("[bootstrap] Schema and seed data loaded successfully.")
    finally:
        con.close()


@contextmanager
def get_connection():
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    con.execute("PRAGMA foreign_keys = ON;")
    try:
        yield con
    finally:
        con.close()


# ──────────────────────────────────────────────
# Request / Response models
# ──────────────────────────────────────────────
class QueryRequest(BaseModel):
    sql: str

    @field_validator("sql")
    @classmethod
    def not_empty(cls, v: str) -> str:
        stripped = v.strip()
        if not stripped:
            raise ValueError("SQL query must not be empty.")
        return stripped


class QueryResponse(BaseModel):
    status: str
    columns: list[str] | None = None
    rows: list[list[Any]] | None = None
    rowcount: int | None = None
    message: str | None = None


# ──────────────────────────────────────────────
# Validation helper
# ──────────────────────────────────────────────
def validate_query(sql: str) -> str | None:
    """
    Returns an error message string if the query fails validation,
    or None if it is safe to execute.
    """
    if len(sql) > MAX_QUERY_LENGTH:
        return f"Query exceeds maximum allowed length ({MAX_QUERY_LENGTH} characters)."

    normalised = " ".join(sql.upper().split())

    for pattern in FORBIDDEN_PATTERNS:
        if pattern.search(normalised):
            keyword = pattern.pattern.strip(r"\b")
            return f"Statement contains a forbidden keyword: {keyword}."

    return None


# ──────────────────────────────────────────────
# FastAPI app
# ──────────────────────────────────────────────
app = FastAPI(
    title="SQL Workbench API",
    description="API Proxy for the Remote SQL Architect and Explorer homework.",
    version="1.0.0",
)

@app.exception_handler(RequestValidationError)
async def validation_error_handler(request: Request, exc: RequestValidationError):
    first = exc.errors()[0] if exc.errors() else {}
    msg = first.get("msg", "Invalid request.").replace("Value error, ", "")
    return JSONResponse(status_code=422, content={"status": "error", "message": msg})


app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://localhost:5500",
        "http://127.0.0.1:5500",
        "null",          # allows file:// origins (opening index.html directly)
    ],
    allow_methods=["POST", "GET", "OPTIONS"],
    allow_headers=["Content-Type"],
)


# ──────────────────────────────────────────────
# Routes
# ──────────────────────────────────────────────
@app.get("/health")
def health():
    return {"status": "ok", "database": str(DB_PATH)}


@app.post("/query", response_model=QueryResponse)
def execute_query(payload: QueryRequest):
    """
    Validate and execute a SQL statement.

    Security checks applied before execution:
      1. Empty / whitespace-only queries rejected.
      2. Query length capped at 2 000 characters.
      3. Forbidden keywords (DROP, TRUNCATE, ALTER, ATTACH,
         DETACH, PRAGMA, LOAD_EXTENSION) blocked.
      4. All sqlite3 exceptions are caught and their messages
         are sanitised before being returned to the client.
    """
    sql = payload.sql

    # ── Validation ──────────────────────────────
    error_msg = validate_query(sql)
    if error_msg:
        return QueryResponse(status="error", message=error_msg)

    # ── Execution ───────────────────────────────
    try:
        with get_connection() as con:
            cursor = con.execute(sql)
            con.commit()

            if cursor.description:
                # SELECT-like statement: return column names + rows
                columns = [desc[0] for desc in cursor.description]
                rows = [list(row) for row in cursor.fetchall()]
                return QueryResponse(
                    status="success",
                    columns=columns,
                    rows=rows,
                    rowcount=len(rows),
                )
            else:
                # INSERT / UPDATE / DELETE: return affected row count
                return QueryResponse(
                    status="success",
                    columns=[],
                    rows=[],
                    rowcount=cursor.rowcount,
                    message=f"Query executed successfully. Rows affected: {cursor.rowcount}.",
                )

    except sqlite3.OperationalError as exc:
        # Operational errors (syntax, missing table…) — safe to surface
        return QueryResponse(status="error", message=f"SQL error: {exc}")

    except sqlite3.IntegrityError as exc:
        # Constraint violations
        return QueryResponse(status="error", message=f"Integrity error: {exc}")

    except sqlite3.Error:
        # All other DB errors — generic message to avoid leaking internals
        return QueryResponse(
            status="error",
            message="An unexpected database error occurred. Please try again.",
        )


# ──────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn

    bootstrap_db()
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
