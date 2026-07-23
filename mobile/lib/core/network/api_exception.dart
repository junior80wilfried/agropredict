/// Exception unifiée pour toutes les erreurs réseau/API, avec un message
/// déjà prêt à afficher à l'utilisateur (en français).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromStatus(int statusCode, String? serverMessage) {
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return ApiException(serverMessage, statusCode: statusCode);
    }
    switch (statusCode) {
      case 401:
        return ApiException('Session expirée, veuillez vous reconnecter.', statusCode: 401);
      case 404:
        return ApiException('Ressource introuvable.', statusCode: 404);
      case 409:
        return ApiException('Ce compte existe déjà.', statusCode: 409);
      default:
        return ApiException('Une erreur est survenue. Veuillez réessayer.', statusCode: statusCode);
    }
  }

  @override
  String toString() => message;
}
