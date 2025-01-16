import 'package:flutter/material.dart';
import 'package:reality_clone/data_source/api_provider.dart';
import 'package:reality_clone/repo/app_repository.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final TextEditingController textController = TextEditingController();
  String savedValue = "";
  bool isValidServer = false;






  Future<void> autoSaveIp() async {
    final ip = textController.text;
    setState(() {
      savedValue = ip;
    });

    Api.updateBaseUrl(ip);
    final isValid = await AppRepository().pingServer();
    await AppRepository().saveIP(savedValue);

    setState(() {
      isValidServer = isValid;
    });
  }

  Future<void> loadIp() async {
    final ip = await AppRepository().getIP();
    setState(() {
      savedValue =  ip;
      textController.text = ip;
    });
  }



  @override
  void initState() {
    loadIp();
    textController.addListener(autoSaveIp);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Server IP',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'ex: http://192.168.1.25:3000',
              ),
            ),

            if(isValidServer)
              const Text(
                'Connection to server successful',
                style: TextStyle(color: Colors.green),
              ),
            if(!isValidServer)
              const Text(
                'Server is not reachable',
                style: TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 24),
            Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed quis aliquet lorem. In efficitur condimentum est, auctor luctus ipsum egestas eu. '
                      'Interdum et malesuada fames ac ante ipsum primis in faucibus. Donec suscipit metus eget felis dignissim dictum sed a purus. '
                      'Etiam mattis nunc et nibh mattis faucibus. Nam blandit tempus nibh vitae luctus. Suspendisse tincidunt sagittis libero, '
                      'in tincidunt sem imperdiet quis. Duis sit amet interdum nunc. Fusce non nisi in nisi finibus iaculis nec ac neque. '
                      'Morbi ut sodales tortor. Suspendisse potenti. Integer vulputate vulputate enim, quis tristique erat. Vivamus sodales quam eget lobortis rhoncus. '
                      'Nullam eget ipsum felis. Etiam vitae feugiat nunc.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    textController.removeListener(autoSaveIp);
    textController.dispose();
    super.dispose();
  }
}
