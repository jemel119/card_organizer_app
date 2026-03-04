import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';
import 'add_edit_card_screen.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;

  CardsScreen({required this.folder});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepo = CardRepository();
  List<PlayingCard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards =
        await _cardRepo.getCardsByFolderId(widget.folder.id!);
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
  }

  Future<void> _deleteCard(int id) async {
    await _cardRepo.deleteCard(id);
    _loadCards();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Card deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.folder.folderName)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.folderName),
      ),
      body: ListView.builder(
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];

          return ListTile(
            leading: Icon(Icons.style),
            title: Text(card.cardName),
            subtitle: Text(card.suit),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditCardScreen(
                          folderId: widget.folder.id!,
                          existingCard: card,
                        ),
                      ),
                    );
                    _loadCards();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCard(card.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditCardScreen(
                folderId: widget.folder.id!,
              ),
            ),
          );
          _loadCards();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}