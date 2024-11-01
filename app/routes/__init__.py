
def register_blueprints(app):
    from .app_routes import app as appRoute
    from .ai_routes import app as aiRoute
    from .test_routes import app as testRoute

    app.register_blueprint(appRoute)
    app.register_blueprint(aiRoute) 
    app.register_blueprint(testRoute) 
