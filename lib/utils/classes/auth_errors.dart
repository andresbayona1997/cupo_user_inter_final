class AuthErrors {

  static String getErrorMsg(String code) {
    String _errorMessage;
    switch(code) {
      case 'ERROR_WEAK_PASSWORD': 
        _errorMessage = 'La contraseña es muy debil';
        break;
      case 'ERROR_INVALID_EMAIL':
        _errorMessage = 'El email es invalido';
        break;
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        _errorMessage = 'Este email ya esta en uso';
        break;
      case 'ERROR_WRONG_PASSWORD':
        _errorMessage = 'La contraseña es incorrecta';
        break;  
      case 'ERROR_USER_NOT_FOUND':
        _errorMessage = 'El usuario no existe';
        break;
      default: 
        _errorMessage = 'A ocurrido un error';  
    }
    return _errorMessage;
  }
}