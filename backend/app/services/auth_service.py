from flask_jwt_extended import create_access_token

from app.extensions import db
from app.models.user import User


class AuthError(Exception):
    def __init__(self, message: str, status_code: int = 400):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


def inscrire_utilisateur(data: dict) -> tuple[User, str]:
    """`data` doit déjà avoir été validé par UtilisateurInscriptionSchema (routes/auth.py)."""
    email = data["email"].strip().lower()

    if User.query.filter_by(email=email).first():
        raise AuthError("Un compte existe déjà avec cet email.", 409)

    utilisateur = User(
        nom=data["nom"].strip(),
        email=email,
        telephone=data.get("telephone"),
        ville=data.get("ville") or "Yaoundé",
        region=data.get("region") or "Centre",
        agriculteur_depuis=data.get("agriculteur_depuis"),
    )
    utilisateur.set_password(data["mot_de_passe"])

    db.session.add(utilisateur)
    db.session.commit()

    token = create_access_token(identity=str(utilisateur.id))
    return utilisateur, token


def connecter_utilisateur(data: dict) -> tuple[User, str]:
    """`data` doit déjà avoir été validé par UtilisateurConnexionSchema (routes/auth.py)."""
    email = data["email"].strip().lower()
    mot_de_passe = data["mot_de_passe"]

    utilisateur = User.query.filter_by(email=email).first()
    if not utilisateur or not utilisateur.check_password(mot_de_passe):
        raise AuthError("Email ou mot de passe incorrect.", 401)

    token = create_access_token(identity=str(utilisateur.id))
    return utilisateur, token
