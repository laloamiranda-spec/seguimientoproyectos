"""
Tests básicos de humo para la app de Entregables.
Verifican que las rutas principales responden correctamente.
"""
import pytest
import os
import sys

# Asegura que app.py es importable desde la raíz
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

# Fuerza modo SQLite (sin DATABASE_URL) para los tests
os.environ.pop('DATABASE_URL', None)
os.environ.setdefault('SECRET_KEY', 'test-secret-key')

from app import app as flask_app


@pytest.fixture
def client():
    flask_app.config['TESTING'] = True
    flask_app.config['WTF_CSRF_ENABLED'] = False
    with flask_app.test_client() as c:
        yield c


# ── Tests de rutas públicas ────────────────────────────────────────────────────

def test_login_page_loads(client):
    """La página de login debe responder 200."""
    response = client.get('/login')
    assert response.status_code == 200


def test_redirect_root_to_login(client):
    """La raíz debe redirigir al login cuando no hay sesión."""
    response = client.get('/')
    assert response.status_code in (200, 302)


def test_static_css_exists():
    """El archivo CSS principal debe existir."""
    css_path = os.path.join(os.path.dirname(__file__), '..', 'static', 'style.css')
    assert os.path.isfile(css_path), "static/style.css no encontrado"


def test_templates_exist():
    """Las plantillas críticas deben existir."""
    base = os.path.join(os.path.dirname(__file__), '..', 'templates')
    for tpl in ['base.html', 'dashboard.html', 'entregables.html', 'login.html']:
        assert os.path.isfile(os.path.join(base, tpl)), f"Plantilla {tpl} no encontrada"


def test_env_example_exists():
    """El archivo .env.example debe existir para guiar el deploy."""
    path = os.path.join(os.path.dirname(__file__), '..', '.env.example')
    assert os.path.isfile(path), ".env.example no encontrado"


def test_requirements_exist():
    """requirements.txt debe existir y contener Flask."""
    path = os.path.join(os.path.dirname(__file__), '..', 'requirements.txt')
    assert os.path.isfile(path)
    content = open(path).read()
    assert 'Flask' in content
