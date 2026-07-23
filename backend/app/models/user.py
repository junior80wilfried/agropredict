from datetime import datetime, date, timezone
from werkzeug.security import generate_password_hash, check_password_hash
from app.extensions import db


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    nom = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(180), unique=True, nullable=False, index=True)
    telephone = db.Column(db.String(30), nullable=True)
    password_hash = db.Column(db.String(255), nullable=False)

    ville = db.Column(db.String(120), nullable=True, default="Yaoundé")
    region = db.Column(db.String(120), nullable=True, default="Centre")
    agriculteur_depuis = db.Column(db.Integer, nullable=True)  # année, ex: 2015

    # Champs de sécurité
    email_verified = db.Column(db.Boolean, default=False)
    email_verification_token = db.Column(db.String(200), nullable=True)
    last_login = db.Column(db.DateTime, nullable=True)
    failed_login_attempts = db.Column(db.Integer, default=0)
    account_locked = db.Column(db.Boolean, default=False)
    lock_until = db.Column(db.DateTime, nullable=True)

    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(
        db.DateTime, 
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc)
    )

    parcelles = db.relationship(
        "Parcelle", backref="proprietaire", lazy="dynamic", cascade="all, delete-orphan"
    )
    predictions_rendement = db.relationship(
        "RendementPrediction", backref="auteur", lazy="dynamic", cascade="all, delete-orphan"
    )

    def set_password(self, mot_de_passe: str) -> None:
        """Hache le mot de passe avec un sel aléatoire."""
        self.password_hash = generate_password_hash(mot_de_passe, method='pbkdf2:sha256')

    def check_password(self, mot_de_passe: str) -> bool:
        """Vérifie si le mot de passe correspond au hash stocké."""
        return check_password_hash(self.password_hash, mot_de_passe)

    def increment_failed_logins(self) -> None:
        """Incrémente le compteur d'échecs de connexion."""
        self.failed_login_attempts += 1
        if self.failed_login_attempts >= 5:
            self.account_locked = True
            self.lock_until = datetime.now(timezone.utc) + timedelta(minutes=15)
        db.session.commit()

    def reset_failed_logins(self) -> None:
        """Réinitialise le compteur d'échecs de connexion."""
        self.failed_login_attempts = 0
        self.account_locked = False
        self.lock_until = None
        db.session.commit()

    def is_locked(self) -> bool:
        """Vérifie si le compte est verrouillé."""
        if not self.account_locked:
            return False
        if self.lock_until and self.lock_until < datetime.now(timezone.utc):
            self.reset_failed_logins()
            return False
        return True

    @property
    def initiales(self) -> str:
        parties = self.nom.strip().split()
        if len(parties) >= 2:
            return (parties[0][0] + parties[1][0]).upper()
        return self.nom[:2].upper() if self.nom else "??"

    @property
    def annees_experience(self) -> int:
        if not self.agriculteur_depuis:
            return 0
        return date.today().year - self.agriculteur_depuis

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "nom": self.nom,
            "email": self.email,
            "telephone": self.telephone,
            "ville": self.ville,
            "region": self.region,
            "agriculteur_depuis": self.agriculteur_depuis,
            "annees_experience": self.annees_experience,
            "initiales": self.initiales,
            "email_verified": self.email_verified,
        }
