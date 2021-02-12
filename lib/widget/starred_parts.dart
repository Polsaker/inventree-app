

import 'package:InvenTree/inventree/part.dart';
import 'package:InvenTree/widget/part_detail.dart';
import 'package:InvenTree/widget/progress.dart';
import 'package:InvenTree/widget/refreshable_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api.dart';


class StarredPartWidget extends StatefulWidget {

  StarredPartWidget({Key key}) : super(key: key);

  @override
  _StarredPartState createState() => _StarredPartState();
}


class _StarredPartState extends RefreshableState<StarredPartWidget> {

  List<InvenTreePart> starredParts = [];

  @override
  String getAppBarTitle(BuildContext context) => "Starred Parts";

  @override
  Future<void> request(BuildContext context) async {

    final parts = await InvenTreePart().list(context, filters: {"starred": "true"});

    starredParts.clear();

    for (int idx = 0; idx < parts.length; idx++) {
      if (parts[idx] is InvenTreePart) {
        starredParts.add(parts[idx]);
      }
    }
  }

  Widget _partResult(BuildContext context, int index) {
    final part = starredParts[index];

    return ListTile(
        title: Text(part.fullname),
        subtitle: Text(part.description),
        leading: InvenTreeAPI().getImage(
            part.thumbnail,
            width: 40,
            height: 40
        ),
        onTap: () {
          InvenTreePart().get(context, part.pk).then((var prt) {
            if (prt is InvenTreePart) {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PartDetailWidget(prt))
              );
            }
          });
        }
    );
  }

  @override
  Widget getBody(BuildContext context) {

    if (loading) {
      return progressIndicator();
    }

    if (starredParts.length == 0) {
      return ListView(
        children: [
          ListTile(
            title: Text("No Parts"),
            subtitle: Text("No starred parts available")
          )
        ],
      );
    }

    return ListView.separated(
      itemCount: starredParts.length,
      itemBuilder: _partResult,
      separatorBuilder: (_, __) => const Divider(height: 3),
      physics: ClampingScrollPhysics(),
    );
  }
}