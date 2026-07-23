from app import create_app

app = create_app()

if __name__ == "__main__":
    # Configuration du timeout des requêtes
    timeout = app.config.get('REQUEST_TIMEOUT', 30)
    app.run(
        host="0.0.0.0", 
        port=5000, 
        debug=app.config.get("DEBUG", False),
        threaded=True,
        timeout=timeout
    )
