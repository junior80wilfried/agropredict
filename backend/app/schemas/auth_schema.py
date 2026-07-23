"""Schémas de validation (entrée) et de sérialisation (sortie) pour l'authentification.

- Les schémas d'entrée bloquent toute donnée mal formée avant qu'elle n'atteigne
  la base de données (correctif vulnérabilité HIGH "Missing Schema Validation").
- UtilisateurPublicSchema définit une whitelist explicite des champs renvoyés au
  client : password_hash (ou tout futur champ sensible) ne peut jamais fuiter,
  même si le modèle User évolue plus tard (correctif vulnérabilité HIGH "Mass
  Data Leak").
"""

from marshmallow import Schema, fields, validate, ValidationError
import re


class UtilisateurInscriptionSchema(Schema):
    """Valide le corps de requête de POST /api/auth/inscription."""

    nom = fields.String(required=True, validate=validate.Length(min=2, max=120))
    email = fields.Email(required=True)
    mot_de_passe = fields.String(
        required=True, 
        validate=[
            validate.Length(min=12, max=128),
        ]
    )
    telephone = fields.String(
        required=False, 
        load_default=None, 
        allow_none=True,
        validate=validate.Length(max=30)
    )
    ville = fields.String(
        required=False, 
        load_default=None, 
        allow_none=True,
        validate=validate.Length(max=120)
    )
    region = fields.String(
        required=False, 
        load_default=None, 
        allow_none=True,
        validate=validate.Length(max=120)
    )
    agriculteur_depuis = fields.Integer(
        required=False, 
        load_default=None, 
        allow_none=True,
        validate=validate.Range(min=1900, max=2100)
    )

    def validate_mot_de_passe(self, value, **kwargs):
        """Validation avancée de la force du mot de passe."""
        errors = []
        
        if not re.search(r'[A-Z]', value):
            errors.append("Le mot de passe doit contenir au moins une majuscule")
        if not re.search(r'[a-z]', value):
            errors.append("Le mot de passe doit contenir au moins une minuscule")
        if not re.search(r'[0-9]', value):
            errors.append("Le mot de passe doit contenir au moins un chiffre")
        if not re.search(r'[!@#$%^&*(),.?":{}|<>\-+=\[\]_`~]', value):
            errors.append("Le mot de passe doit contenir au moins un caractère spécial")
        
        # Vérifier les mots de passe courants
        common_passwords = [
            "password", "123456", "12345678", "1234", "qwerty", "12345",
            "dragon", "baseball", "football", "letmein", "monkey",
            "abc123", "password1", "admin", "welcome", "login",
            "passw0rd", "master", "hello", "freedom", "whatever"
        ]
        if value.lower() in common_passwords:
            errors.append("Le mot de passe est trop courant")
        
        # Vérifier si le mot de passe contient le nom ou l'email
        nom = kwargs.get('nom', '')
        email = kwargs.get('email', '')
        if nom and nom.lower() in value.lower():
            errors.append("Le mot de passe ne doit pas contenir votre nom")
        if email and email.lower() in value.lower():
            errors.append("Le mot de passe ne doit pas contenir votre email")
        
        if errors:
            raise ValidationError(errors)
        
        return value


class UtilisateurConnexionSchema(Schema):
    """Valide le corps de requête de POST /api/auth/connexion."""

    email = fields.Email(required=True)
    mot_de_passe = fields.String(required=True, validate=validate.Length(min=1, max=128))


class UtilisateurPublicSchema(Schema):
    """Whitelist stricte des champs renvoyés au client.

    N'AJOUTER ICI QUE DES CHAMPS NON SENSIBLES. Ne jamais ajouter password_hash.
    """

    id = fields.Integer(dump_only=True)
    nom = fields.String(dump_only=True)
    email = fields.Email(dump_only=True)
    telephone = fields.String(dump_only=True, allow_none=True)
    ville = fields.String(dump_only=True, allow_none=True)
    region = fields.String(dump_only=True, allow_none=True)
    agriculteur_depuis = fields.Integer(dump_only=True, allow_none=True)
    annees_experience = fields.Integer(dump_only=True)
    initiales = fields.String(dump_only=True)
    email_verified = fields.Boolean(dump_only=True)


inscription_schema = UtilisateurInscriptionSchema()
connexion_schema = UtilisateurConnexionSchema()
utilisateur_public_schema = UtilisateurPublicSchema()
