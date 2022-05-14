import 'package:pigeon/pigeon.dart';

class MessageParams {
  String peer;
}

@HostApi()
abstract class MesiboPluginApi {
	void setup(String token);

	void sendMessage(String peer, String message);

	void showUserList();
	void showMessages(String peer);
	void audioCall(String peer);
	void videoCall(String peer);
}
