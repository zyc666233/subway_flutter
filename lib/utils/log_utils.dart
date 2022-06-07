class LogUtils {

  //是否输入日志标识
  static bool _isLog = true;
  static String _logFlag = "Flutter-Ho";

  static void init({bool islog = false,String logFlag ="Flutter-Ho"}){
    _isLog = islog;
    _logFlag = logFlag;
  }


  static void e(String message){

    if(_isLog){
      print("$_logFlag | $message");
    }
  }

}