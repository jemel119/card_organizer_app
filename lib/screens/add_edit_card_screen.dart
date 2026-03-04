import 'package:flutter/material.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final int folderId;
  final PlayingCard? existingCard;

  AddEditCardScreen({required this.folderId, this.existingCard});

  @override
  _AddEditCardScreenState createState() =>
      _AddEditCardScreenState();
}

class _AddEditCardScreenState
    extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardRepo = CardRepository();

  late TextEditingController _nameController;
  String _selectedSuit = "Hearts";

  final List<String> suits = [
    "Hearts",
    "Diamonds",
    "Clubs",
    "Spades"
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.existingCard?.cardName ?? "");

    if (widget.existingCard != null) {
      _selectedSuit = widget.existingCard!.suit;
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    final card = PlayingCard(
      id: widget.existingCard?.id,
      cardName: _nameController.text,
      suit: _selectedSuit,
      folderId: widget.folderId,
      imageUrl: null,
    );

    if (widget.existingCard == null) {
      await _cardRepo.insertCard(card);
    } else {
      await _cardRepo.updateCard(card);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCard != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Card" : "Add Card"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    InputDecoration(labelText: "Card Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter a name" : null,
              ),
              DropdownButtonFormField(
                value: _selectedSuit,
                items: suits
                    .map((suit) => DropdownMenuItem(
                          value: suit,
                          child: Text(suit),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSuit = value as String;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCard,
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}