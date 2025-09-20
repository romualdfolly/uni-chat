class ApiRoutes {
  static String platformUrl(String base) {
    return (base == 'flutter')
        ? ApiRoutes.baseUrlFlutter
        : ApiRoutes.baseUrlLaravel;
  }

  static const baseUrlLaravel = "http://127.0.0.1:8000";
  static const baseUrlFlutter = "http://10.0.2.2:8000";

  static const login = '/api/auth/login';
  static const register = '/api/auth/register';
  static const verifyCode = '/api/auth/verify';
  static const updatePassword = '/api/auth/update-password';
  static const deleteAccount = '/api/auth/deletion/delete-account';
  static const checkContact = '/api/contact/check';
  static const getContactInfosById = '/api/contact/get';
  static const pusherAuth = '/api/pusher/auth';

  static const fetchAllMessages = '/api/message/fetch_all';
  static const fetchMessages = '/api/message/fetch';
  static const sendMessage = '/api/message/send';
  static const sendLocalUnsentMessages = '/api/message/send/messages';
  static const updateMessagesReadingState = '/api/message/update_reading';

  static const storeKeys = '/api/key/store';
  static const updateKey = '/api/key/update';
}
