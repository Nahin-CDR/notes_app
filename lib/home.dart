import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notes/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  final _shoppingBox = Hive.box('shopping_box');

  void _refreshItems() {
    final data = _shoppingBox.keys.map((key) {
      final item = _shoppingBox.get(key);
      return {"Key": key, "name": item["name"], "quantity": item["quantity"]};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    if (kDebugMode) {
      print("amount of data : ${_shoppingBox.length}");
    }
    _refreshItems();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> newItem) async {
    await _shoppingBox.put(itemKey, newItem);
    _refreshItems();
  }

  Future<void> _deleteItem({required int itemKey}) async {
    await _shoppingBox.delete(itemKey);
    _refreshItems();
    _nameController.text = '';
    _quantityController.text = '';
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existItem =
          _items.firstWhere((element) => element['Key'] == itemKey);
      _nameController.text = existItem['name'];
      _quantityController.text = existItem['quantity'];
    }

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: ctx,
        elevation: 5,
        builder: (_) {
          return Container(
            decoration: BoxDecoration(
              color: themeProviderView.currentTheme == 'dark'
                  ? Colors.blueGrey
                  : Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 15,
                left: 15,
                right: 15),
            child: ListView(
              shrinkWrap: true,
              //crossAxisAlignment: CrossAxisAlignment.end,
              //mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  style: TextStyle(
                    color: themeProviderView.currentTheme == 'dark'
                        ? Colors.white
                        : Colors.black,
                  ),
                  keyboardType: TextInputType.text,
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(
                      color: themeProviderView.currentTheme == 'dark'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  style: TextStyle(
                    color: themeProviderView.currentTheme == 'dark'
                        ? Colors.white
                        : Colors.black,
                  ),
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Quantity'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                themeProviderView.currentTheme == 'dark'
                                    ? Colors.white
                                    : Colors.grey,
                            backgroundColor:
                                themeProviderView.currentTheme == 'dark'
                                    ? Colors.black26
                                    : Colors.black,
                          ),
                          onPressed: () async {
                            if (_nameController.text.isNotEmpty &&
                                _quantityController.text.isNotEmpty) {
                              if (itemKey == null) {
                                _createItem({
                                  "name": _nameController.text,
                                  "quantity": _quantityController.text
                                });
                              }
                              if (itemKey != null) {
                                _updateItem(itemKey, {
                                  "name": _nameController.text,
                                  "quantity": _quantityController.text
                                });
                              }
                              _nameController.text = '';
                              _quantityController.text = '';
                              Navigator.of(context).pop();
                            }
                          },
                          child:
                              Text(itemKey == null ? "create new" : "update")),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                themeProviderView.currentTheme == 'dark'
                                    ? Colors.white
                                    : Colors.grey,
                            backgroundColor:
                                themeProviderView.currentTheme == 'dark'
                                    ? Colors.black26
                                    : Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("cancel")),
                    ],
                  ),
                ),
                //const SizedBox(height: 20)
              ],
            ),
          );
        });
  }

  ThemeProviderView themeProviderView = ThemeProviderView();

  @override
  void initState() {
    super.initState();
    themeProviderView.initialize();
    Timer(const Duration(seconds: 1), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // set it to false,
      body: _items.isEmpty
          ? Center(
              child: Text("No data to show !",
                  style: TextStyle(
                      color: themeProviderView.currentTheme == 'dark'
                          ? Colors.white
                          : Colors.brown)))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final currentItem = _items[index];
                return Card(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
                  color: themeProviderView.currentTheme == 'dark'
                      ? Colors.grey
                      : Colors.white,
                  shadowColor: Colors.blueAccent.withOpacity(.5),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      currentItem['name'],
                      style: TextStyle(
                        color: themeProviderView.currentTheme == 'dark'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      currentItem['quantity'].toString(),
                      style: TextStyle(
                        color: themeProviderView.currentTheme == 'dark'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () =>
                                _showForm(context, currentItem['Key']),
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () =>
                                _deleteItem(itemKey: currentItem['Key']),
                            icon: const Icon(Icons.delete))
                      ],
                    ),
                  ),
                );
              }),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        backgroundColor: themeProviderView.currentTheme == 'dark'
            ? Colors.white
            : Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
