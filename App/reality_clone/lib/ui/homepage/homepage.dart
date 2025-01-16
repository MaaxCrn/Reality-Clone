import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reality_clone/ui/homepage/card_api.dart';
import '../../domain/homepage_notifier.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final homeNotifier = context.read<HomePageNotifier>();
    homeNotifier.fetchGaussianList();
  }

  @override
  Widget build(BuildContext context) {
    final homeNotifier = context.watch<HomePageNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/setting');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<HomePageNotifier>().fetchGaussianList();
        },
        child: homeNotifier.isLoading
            ? const Center(child: CircularProgressIndicator())
            : homeNotifier.models.isEmpty
            ? const Center(
          child: Text(
            "No model available.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 3 / 4,
            ),
            itemCount: homeNotifier.models.length,
            itemBuilder: (context, index) {
              final photo = homeNotifier.models[index];
              return CardApi(photo: photo);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/capture');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
