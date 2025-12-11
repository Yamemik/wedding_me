import 'package:flutter/material.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  List<String> searchHistory = [];
  List<String> results = [];

  void _onSearch(String query) async {
    if (query.isEmpty) return;

    // Добавляем в историю
    if (!searchHistory.contains(query)) {
      setState(() => searchHistory.insert(0, query));
    }

    // ===== ТУТ ТЫ ПОДКЛЮЧИШЬ API =====
    // final response = await Api.search(query);
    // setState(() => results = response);

    // Пока просто моковые данные:
    setState(() {
      results = List.generate(
          5, (index) => "Результат $index по запросу \"$query\"");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 226, 171, 190),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Поиск...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
          ),
          onSubmitted: _onSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              _controller.clear();
              setState(() => results.clear());
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: results.isEmpty
            ? _buildHistory()
            : _buildResults(),
      ),
    );
  }

  // === ИСТОРИЯ ПОИСКА ===
  Widget _buildHistory() {
    if (searchHistory.isEmpty) {
      return Center(
        child: Text(
          "Введите запрос для поиска",
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Недавние запросы",
          style: TextStyle(
            fontSize: 18,
            color: Colors.red[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        ...searchHistory.map((h) => ListTile(
              leading: Icon(Icons.history, color: Colors.pink[400]),
              title: Text(h),
              trailing: Icon(Icons.north_west, color: Colors.grey[400]),
              onTap: () {
                _controller.text = h;
                _onSearch(h);
              },
            )),
      ],
    );
  }

  // === РЕЗУЛЬТАТЫ ===
  Widget _buildResults() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            title: Text(results[i]),
            trailing: Icon(Icons.chevron_right, color: Colors.red[700]),
            onTap: () {},
          ),
        );
      },
    );
  }
}
