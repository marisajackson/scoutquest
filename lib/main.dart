import 'package:flutter/material.dart';
import 'package:scoutquest/views/clue_list_view.dart';
// import 'package:provider/provider.dart';
// import 'package:syne_mobile_app/providers/providers.dart';

// import 'app/routes/app.routes.dart';
// import 'theme/constants.dart';

void main() => runApp(const Core());

class Core extends StatelessWidget {
  const Core({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Lava();
    // return MultiProvider(
    //   providers: providers,
    //   child: const Lava(),
    // );
  }
}

class Lava extends StatelessWidget {
  const Lava({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Scout Quest',
      home: ClueListView(),
    );
  }
}
