import 'package:flutter/material.dart';
import "../services/post_service.dart";

class ScreenPost extends StatefulWidget {
  const ScreenPost({super.key, required this.goToExplore});

  final VoidCallback goToExplore;

  @override
  State<ScreenPost> createState() => _ScreenPostState();
}

class _ScreenPostState extends State<ScreenPost> {
  final _postService = PostService();
  final _postFormKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _drinkController = TextEditingController();

  String? _validateMessage(String? value) {
    final message = value?.trim() ?? '';
    if (message.isEmpty) {
      return 'Enter a message.';
    }
    return null;
  }

  String? _validateDrink(String? value) {
    final drink = value?.trim() ?? '';
    if (drink.isEmpty) {
      return 'Enter a drink.';
    }
    return null;
  }

  Future<void> _onPostPressed() async {
    if (!_postFormKey.currentState!.validate()) {
      return;
    }

    await _postService.createPost(
      message: _messageController.text.trim(),
      drink: _drinkController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    _messageController.clear();
    _drinkController.clear();
    widget.goToExplore();
    // await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _postFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      alignLabelWithHint: true,
                    ),
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    validator: _validateMessage,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _drinkController,
                    decoration: const InputDecoration(labelText: 'Drink'),
                    textInputAction: TextInputAction.done,
                    validator: _validateDrink,
                    onFieldSubmitted: (_) => _onPostPressed(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _onPostPressed,
                    icon: const Icon(Icons.send),
                    label: const Text('Post'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
