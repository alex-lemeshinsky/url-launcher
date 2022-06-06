import 'package:URL_launcher/functions/launch_url.dart';
import 'package:URL_launcher/models/item.dart';
import 'package:URL_launcher/providers/db_provider.dart';
import 'package:URL_launcher/screens/edit_item_screen.dart';
import 'package:URL_launcher/widgets/confirmation_dialog.dart';
import 'package:URL_launcher/widgets/fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DbProvider dbProvider = Provider.of<DbProvider>(context, listen: false);

    final QuickActions quickActions = const QuickActions();
    quickActions.initialize((shortcutType) {
      launchURL(shortcutType, context);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("URL launcher"),
      ),
      floatingActionButton: FAB(),
      body: StreamBuilder(
        stream: dbProvider.itemsStream,
        builder: (context, snapshot) {
          quickActions.setShortcutItems(
            List.generate(dbProvider.items.length, (index) {
              Item item = dbProvider.items[index];
              return ShortcutItem(
                type: item.url,
                localizedTitle: item.title,
                icon: "link",
              );
            }),
          );

          return ListView.separated(
            itemCount: dbProvider.items.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              Item item = dbProvider.items[index];

              return AnimationConfiguration.staggeredList(
                key: ValueKey(item),
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Card(
                      elevation: 10,
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              label: "Edit",
                              backgroundColor: Colors.blue,
                              icon: Icons.edit,
                              onPressed: (ctx) => Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (_) => EditItemScreen(
                                    index: index,
                                    title: item.title,
                                    url: item.url,
                                  ),
                                ),
                              ),
                            ),
                            SlidableAction(
                              label: "Delete",
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              onPressed: (ctx) => ConfirmationDialog(
                                item: item,
                                index: index,
                              ).show(ctx),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(item.title),
                          trailing: Icon(Icons.chevron_left),
                          onTap: () async => await launchURL(item.url, context),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
