from datetime import datetime, timezone
from flask_jwt_extended import create_access_token
from itsdangerous import URLSafeTimedSerializer

from app.extensions import db, jwt
from app.models.user import User


class AuthError(Exception):
    def __init__(self, message: str, status_code: int = 400):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


def generate_verification_token(email: str) -> str:
    """Génère un token de vérification d'email."""
    serializer = URLSafeTimedSerializer(db.current_app.config['SECRET_KEY'])
    return serializer.dumps(email, salt='email-verify')


def verify_email_token(token: str, expiration: int = 3600) -> str | None:
    """Vérifie un token de vérification d'email et retourne l'email si valide."""
    serializer = URLSafeTimedSerializer(db.current_app.config['SECRET_KEY'])
    try:
        email = serializer.loads(token, salt='email-verify', max_age=expiration)
        return email
    except Exception:
        return None


def inscrire_utilisateur(data: dict) -> tuple[User, str]:
    """`data` doit déjà avoir été validé par UtilisateurInscriptionSchema (routes/auth.py)."""
    email = data["email"].strip().lower()

    # Vérifier si l'email existe déjà
    if User.query.filter_by(email=email).first():
        raise AuthError("Un compte existe déjà avec cet email.", 409)

    # Créer l'utilisateur
    utilisateur = User(
        nom=data["nom"].strip(),
        email=email,
        telephone=data.get("telephone"),
        ville=data.get("ville") or "Yaoundé",
        region=data.get("region") or "Centre",
        agriculteur_depuis=data.get("agriculteur_depuis"),
        email_verified=False,  # Par défaut, non vérifié
    )
    utilisateur.set_password(data["mot_de_passe"])

    db.session.add(utilisateur)
    db.session.commit()

    # Générer un token de vérification d'email
    verification_token = generate_verification_token(email)
    utilisateur.email_verification_token = verification_token
    db.session.commit()

    # Générer le token JWT
    token = create_access_token(identity=str(utilisateur.id))
    return utilisateur, token


def connecter_utilisateur(data: dict) -> tuple[User, str]:
    """`data` doit déjà avoir été validé par UtilisateurConnexionSchema (routes/auth.py)."""
    email = data["email"].strip().lower()
    mot_de_passe = data["mot_de_passe"]

    utilisateur = User.query.filter_by(email=email).first()
    
    # Vérifier si l'utilisateur existe et si le mot de passe est correct
    if not utilisateur or not utilisateur.check_password(mot_de_passe):
        raise AuthError("Email ou mot de passe incorrect.", 401)

    # Vérifier si l'email a été vérifié (optionnel pour le développement)
    # if not utilisateur.email_verified:
    #     raise AuthError("Veuillez vérifier votre adresse email avant de vous connecter.", 403)

    # Mettre à jour la dernière connexion
    utilisateur.last_login = datetime.now(timezone.utc)
    db.session.commit()

    token = create_access_token(identity=str(utilisateur.id))
    return utilisateur, token


def verifier_email(token: str) -> User | None:
    """Vérifie l'email d'un utilisateur avec un token."""
    email = verify_email_token(token)
    if not email:
        return None
    
    utilisateur = User.query.filter_by(email=email).first()
    if not utilisateur:
        return None
    
    utilisateur.email_verified = True
    utilisateur.email_verification_token = None
    db.session.commit()
    
    return utilisateur
