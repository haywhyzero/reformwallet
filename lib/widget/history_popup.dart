import 'package:flutter/material.dart';

class HistoryPopup {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void show(BuildContext context, List<String> messages){
    if (_isVisible) return;
    _isVisible = true;
    final uniqueMessages = messages.toSet().toList().reversed.take(10).toList();
    final overlay = Overlay.of(context, rootOverlay: true);
    final screenWidth = MediaQuery.of(context).size.width;


    _overlayEntry = OverlayEntry(builder: (context) => 
    Stack(
      children: [
        GestureDetector(
          onTap: hide,
          behavior: HitTestBehavior.translucent,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Positioned(
        top: 70,
        right: 16,
        width: screenWidth * 0.6,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(opacity: 1.0, duration: Duration(milliseconds: 300), child: Container(
            constraints: BoxConstraints(maxHeight: 300),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(),
                  blurRadius: 8,
                  offset: Offset(0, 4)
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Notifications"
                ),
                SizedBox(height: 12,),
                if (messages.isEmpty)
                  Text('Oops! Nothing yet.'),
                      Expanded(child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: uniqueMessages.length,
                        itemBuilder: (context, index) {
                        final msg = uniqueMessages[index];
                        return Padding(padding: EdgeInsets.symmetric(vertical: 4), child: SelectableText("• $msg"),);
                      }),
                      ),
                Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      TextButton(onPressed: () async {
                        // await MessageService.clearMessages();
                        // hide();
                        // final updatedMessage = await MessageService.getMessages();
                        // ignore: use_build_context_synchronously
                        // show(context, updatedMessage);
                      }, child: Text('clear all')),
                      SizedBox(width: 4),
                      TextButton(onPressed: () => hide(), child: Text('close')),
                    ],
                  ),
                )
              ],
            ),
          ),),
        )),]
    ));

      overlay.insert(_overlayEntry!);
  }
Future<void> clear() async {
    
  }

  static void hide() {
    if(!_isVisible) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
  }
}