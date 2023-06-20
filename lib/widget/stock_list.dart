import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";

import "package:inventree/inventree/model.dart";
import "package:inventree/inventree/stock.dart";
import "package:inventree/widget/paginator.dart";
import "package:inventree/widget/refreshable_state.dart";
import "package:inventree/l10.dart";
import "package:inventree/widget/stock_detail.dart";
import "package:inventree/api.dart";


class StockItemList extends StatefulWidget {

  const StockItemList(this.filters);

  final Map<String, String> filters;

  @override
  _StockListState createState() => _StockListState(filters);
}


class _StockListState extends RefreshableState<StockItemList> {

  _StockListState(this.filters);

  final Map<String, String> filters;

  bool showFilterOptions = false;

  @override
  String getAppBarTitle() => L10().stockItems;

  @override
  List<Widget> appBarActions(BuildContext context) => [
    IconButton(
      icon: FaIcon(FontAwesomeIcons.filter),
      onPressed: () async {
        setState(() {
          showFilterOptions = !showFilterOptions;
        });
      },
    )
  ];

  @override
  Widget getBody(BuildContext context) {
    return PaginatedStockItemList(filters, showFilterOptions);
  }
}

class PaginatedStockItemList extends PaginatedSearchWidget {

  const PaginatedStockItemList(Map<String, String> filters, bool showSearch) : super(filters: filters, showSearch: showSearch);

  @override
  _PaginatedStockItemListState createState() => _PaginatedStockItemListState();
  
}


class _PaginatedStockItemListState extends PaginatedSearchState<PaginatedStockItemList> {

  _PaginatedStockItemListState() : super();

  @override
  String get prefix => "stock_";

  @override
  Map<String, String> get orderingOptions => {
    "part__name": L10().name,
    "part__IPN": L10().internalPartNumber,
    "stock": L10().quantity,
    "status": L10().status,
    "batch": L10().batchCode,
    "updated": L10().lastUpdated,
    "stocktake_date": L10().lastStocktake,
  };

  @override
  Map<String, Map<String, dynamic>> get filterOptions => {
    "in_stock": {
      "default": true,
      "label": L10().filterInStock,
      "help_text": L10().filterInStockDetail,
      "tristate": true,
    },
    "cascade": {
      "default": false,
      "label": L10().includeSublocations,
      "help_text": L10().includeSublocationsDetail,
      "tristate": false,
    },
    "serialized": {
      "label": L10().filterSerialized,
      "help_text": L10().filterSerializedDetail,
    }
  };

  @override
  Future<InvenTreePageResponse?> requestPage(int limit, int offset, Map<String, String> params) async {

    // Ensure StockStatus codes are loaded
    await InvenTreeAPI().StockStatus.load();

    final page = await InvenTreeStockItem().listPaginated(
      limit,
      offset,
      filters: params
    );

    return page;
  }

  @override
  Widget buildItem(BuildContext context, InvenTreeModel model) {

    InvenTreeStockItem item = model as InvenTreeStockItem;

    return ListTile(
      title: Text("${item.partName}"),
      subtitle: Text("${item.locationPathString}"),
      leading: InvenTreeAPI().getThumbnail(item.partThumbnail),
      trailing: Text("${item.displayQuantity}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: InvenTreeAPI().StockStatus.color(item.status),
        ),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => StockDetailWidget(item)));
      },
    );
  }
}