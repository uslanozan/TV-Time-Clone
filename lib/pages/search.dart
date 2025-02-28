import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    List<Map<String, dynamic>> allItems = [];
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Movies koleksiyonundaki belge ID'lerini al
    QuerySnapshot moviesSnapshot = await firestore.collection('Movie').get();
    for (var doc in moviesSnapshot.docs) {
      allItems.add({"name": doc.id, "type": "film"}); // Belge ID = Film Adı
    }

    // Series koleksiyonundaki belge ID'lerini al
    QuerySnapshot seriesSnapshot = await firestore.collection('Series').get();
    for (var doc in seriesSnapshot.docs) {
      allItems.add({"name": doc.id, "type": "dizi"}); // Belge ID = Dizi Adı
    }

    setState(() {
      _allItems = allItems;
      _filteredItems = allItems;
      _isLoading = false;
    });
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredItems = _allItems
          .where((item) => item["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Film ve Dizi Arama"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: "Film veya Dizi Ara...",
                prefixIcon: Icon(Icons.search), // 🔍 Büyüteç simgesi
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator()) // Yüklenirken gösterilecek
              : Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  title: Text(item["name"]),
                  leading: Icon(
                    item["type"] == "film" ? Icons.movie : Icons.tv, // Film ve dizi için ikon
                    color: item["type"] == "film" ? Colors.blue : Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
