import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  static List<dynamic> products = [];
  static var productvalues = [];

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
        products.forEach((element) {
          productvalues.add(element["title"]);
        });
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ElevatedButton(
            child: Text("Search"),
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                )),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(products.length, (index) {
          return Card(
            child: Column(
              children: [
                Image.network(
                  products[index]['image'] ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  height: 200,
                ),
                Text(
                  products[index]['title'],
                ),
              ],
            ),
            //
          );
        }),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MainApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Search Bar Example',
        theme: ThemeData(
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: const Color.fromARGB(255, 255, 0, 0)),
          ),
        ),
        home: MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();

  List _filteredData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _filteredData = _MainAppState.productvalues;
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    //Simulates waiting for an API call
    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {
      _filteredData = _MainAppState.productvalues
          .where((element) => element
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: TextField(
            controller: _searchController,
            style: TextStyle(color: const Color.fromARGB(255, 245, 0, 0)),
            cursorColor: const Color.fromARGB(255, 255, 0, 0),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainApp()),
                );
              },
              child: Text("back"),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : ListView.builder(
                      itemCount: _filteredData.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          _filteredData[index],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple.shade900,
      );
}
