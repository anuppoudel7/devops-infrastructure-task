from flask import Flask, jsonify, render_template
import os
import psycopg2

app = Flask(__name__)


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "db"),
        database=os.getenv("POSTGRES_DB", "devopsdb"),
        user=os.getenv("POSTGRES_USER", "devops"),
        password=os.getenv("POSTGRES_PASSWORD", "devopspass"),
    )


@app.get("/")
def home():
    return render_template("index.html")


@app.get("/health")
def health():
    return jsonify({"status": "healthy"})


@app.get("/db-test")
def db_test():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT version();")
        version = cur.fetchone()[0]
        cur.close()
        conn.close()

        return jsonify({
            "database": "connected",
            "version": version,
        })

    except Exception as exc:
        return jsonify({
            "database": "error",
            "message": str(exc),
        }), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)