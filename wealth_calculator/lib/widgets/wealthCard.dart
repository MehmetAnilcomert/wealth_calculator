import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WealthPriceCard extends StatefulWidget {
  final WealthPrice wealthPrice;
  final Function(String) onVisibilityChanged;

  WealthPriceCard(
      {required this.wealthPrice, required this.onVisibilityChanged});

  @override
  _WealthPriceCardState createState() => _WealthPriceCardState();
}

class _WealthPriceCardState extends State<WealthPriceCard> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _loadVisibility();
  }

  void _loadVisibility() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVisible =
          prefs.getBool('visibility_${widget.wealthPrice.title}') ?? true;
    });
  }

  void _toggleVisibility() async {
    setState(() {
      _isVisible = !_isVisible;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('visibility_${widget.wealthPrice.title}', _isVisible);
    widget.onVisibilityChanged(widget.wealthPrice.title);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return SizedBox.shrink();
    }

    Color changeColor = widget.wealthPrice.change.startsWith('-')
        ? Colors.red
        : const Color.fromARGB(255, 67, 155, 70);
    Icon icon = widget.wealthPrice.change.startsWith('-')
        ? Icon(
            Icons.trending_down,
            color: Colors.red,
            size: 26.0,
          )
        : Icon(
            Icons.trending_up,
            color: Colors.green,
            size: 26.0,
          );

    return GestureDetector(
      onLongPress: _toggleVisibility,
      child: Container(
        margin: EdgeInsets.all(5),
        width: 180,
        height: 180,
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 139, 202, 233),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.wealthPrice.title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Alış Fiyatı: ${widget.wealthPrice.buyingPrice}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'Satış Fiyatı: ${widget.wealthPrice.sellingPrice}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4.0),
            Row(
              children: [
                Text(
                  'Change: ${widget.wealthPrice.change}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: changeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                icon,
              ],
            ),
            SizedBox(height: 4.0),
            Text(
              'Saati: ${widget.wealthPrice.time}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildPricesTab(List<dynamic> prices) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      List<Row> rows = [];
      for (var i = 0; i < prices.length; i += 2) {
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WealthPriceCard(
                wealthPrice: prices[i],
                onVisibilityChanged: (title) {
                  setState(() {});
                },
              ),
              if (i + 1 < prices.length)
                WealthPriceCard(
                  wealthPrice: prices[i + 1],
                  onVisibilityChanged: (title) {
                    setState(() {});
                  },
                ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 20),
          child: Column(
            children: rows,
          ),
        ),
      );
    },
  );
}
