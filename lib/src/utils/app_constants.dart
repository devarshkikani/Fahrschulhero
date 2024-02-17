enum Environment { LOCAL, DEVELOPMENT, STAGING, PRODUCTION }

class EnvironmentConfiguration {
  String baseUrl;

  EnvironmentConfiguration({
    required this.baseUrl,
  });
}

class ApiEndpoints {
  setBaseUrl(Environment environment) {
    EnvironmentConfiguration? configuration = _baseUrls[environment];
    if (configuration != null) {
      imageEndPoint = configuration.baseUrl;
      apiEndPoint = '$imageEndPoint/api';
    } else {
      throw new Exception(
          "Cannot get baseUrl for environment = '$environment'.");
    }
  }

  Map<Environment, EnvironmentConfiguration> _baseUrls = {
    Environment.LOCAL: EnvironmentConfiguration(
      baseUrl: "https://localhost:44356",
    ),
    Environment.DEVELOPMENT: EnvironmentConfiguration(
      baseUrl: "https://development.fahrschulhero.eu",
    ),
    Environment.STAGING: EnvironmentConfiguration(
      baseUrl: "https://staging.fahrschulhero.eu",
    ),
    Environment.PRODUCTION: EnvironmentConfiguration(
      baseUrl: "https://production.fahrschulhero.eu",
    ),
  };

// Network Constants
  late String apiEndPoint;
  late String imageEndPoint;

// Authentication
  String gmailAuth = '/Identity/GmailAuth';
  String register = '/Identity/Register';
  String login = '/Identity/Login';
  String facebookAuth = '/Identity/FacebookAuth';
  String appleAuth = '/Identity/AppleAuth';
  String refreshToken = '/Identity/Refresh';
  String sendResetCode = '/Identity/SendResetCode';
  String resetPassword = '/Identity/ResetPassword';
  String signOut = '/Identity/SignOut';
  String closeAccount = '/Identity/CloseAccount';

  //questions
  String getAllQuestion = '/Question/GetAll';
  String answer = '/Question/Answer';
  String answerMultiple = '/Question/AnswerMultiple';
  String answerInExam = '/Question/AnswerInExam';
  String setFavorite = '/Question/SetFavorite';

  //classes
  String getAllClass = '/Class/GetAll';

  // Rank
  String getUsersRank = '/Rank/GetUsersRank';
  String getAllRanks = '/Rank/GetAllRanks';
  String getUserRanksHistory = '/Rank/GetUserRanksHistory';

  String getAppVersionAndEnvironment =
      '/Configuration/GetAppVersionAndEnvironment';
  String getConfigurations = '/Configuration/GetConfigurations';
  String getTranslations = '/Configuration/GetTranslations';

  //User
  String updateUser = '/User/UpdateUser';
  String getUser = '/User/GetUser';

  //Exam
  String canDoExam = '/User/CanDoExam';
  String startExam = '/Exam/Start';
  String finish = '/Exam/Finish';
  String getResult = '/Exam/GetResult';
  String getCountdownMinutes = '/Exam/GetCountdownMinutes';

  //School
  String getSchool = '/School/GetAll';

  //subscr
  String getPricePerWeek = '/Subscription/GetPricePerWeek';
  String getPricePerLife = '/Subscription/GetPricePerLife';
  String buyAppStore = '/Subscription/BuyAppStore';
  String buyPlayStore = '/Subscription/BuyPlayStore';

  // friend
  String getFriends = '/Friend/GetFriends';
  String saveContacts = '/Friend/SaveContacts';
  String getContacts = '/Friend/GetContacts';
  String sendInvitation = '/Friend/SendInvitation';
  String acceptInvitation = '/Friend/AcceptJoinApp';
  String log = "/Log/Log";

  //version
  String getVersionChangeDate = "/Version/GetVersionChangeDate";
}
