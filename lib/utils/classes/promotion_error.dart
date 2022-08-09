class PromotionErrors {


  static String getErrorMsg(code) {
    String _errorMessage;
    switch(code) {
      case 448: 
        _errorMessage = "El codigo para redimir no existe";
        break;
      case 454: 
        _errorMessage = "El shopkeeper id no existe";
        break;
      case 455:
        _errorMessage = "Este usuario no esta autorizado para redimir" ;
        break;
      case 449:
        _errorMessage = "Este shopkeeper no tiene promociones relacionadas";
        break;
      case 450: 
        _errorMessage = "El codigo de promoción no existe";
        break;
      case 451:
        _errorMessage = "Esta promoción ya vencio";
        break;
      case 452: 
        _errorMessage = "El usuario ya redimio todas sus promociones dispnibles";
        break;
      case 453: 
        _errorMessage = "El shopkeeper ya redimio todas sus promociones dispnibles";
        break;
      case 456:
        _errorMessage = "Esta promoción esta inactiva";
        break;
      case 457: 
        _errorMessage = "Por favor revisar las horas de inicio y fin de la promoción";
        break;
      case 458: 
        _errorMessage = "La promoción no esta asociada al comercio";
        break;
      case 466: 
        _errorMessage = "Ya has aceptado esta promoción";
        break;
      case 467:
        _errorMessage = "Hoy no puedes redimir la promoción";
        break;
      default: 
        _errorMessage = "Ha ocurrido un error inesperado";
    }
    return _errorMessage;
  } 
}