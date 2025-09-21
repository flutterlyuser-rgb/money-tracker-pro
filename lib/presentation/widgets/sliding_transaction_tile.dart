import 'package:flutter/material.dart';

/// Lightweight model for display. Converts domain entities into values
/// the tile understands (icon, category name, formatted date, amount).
class Transaction {
  final IconData icon;
  final String category;
  final String date;
  final double amount;

  const Transaction({
    required this.icon,
    required this.category,
    required this.date,
    required this.amount,
  });
}

/// A row that slides horizontally to reveal copy/delete actions.
/// Tapping the row closes it if open.
class SlidingTransactionTile extends StatefulWidget {
  final int index;
  final Transaction transaction;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final void Function(int index) onOpenChanged;
  final bool isOpen;

  const SlidingTransactionTile({
    Key? key,
    required this.index,
    required this.transaction,
    required this.onCopy,
    required this.onDelete,
    required this.onOpenChanged,
    required this.isOpen,
  }) : super(key: key);

  @override
  State<SlidingTransactionTile> createState() =>
      _SlidingTransactionTileState();
}

class _SlidingTransactionTileState extends State<SlidingTransactionTile> {
  late double _translateX;
  static const double _iconAreaWidth = 80.0;

  @override
  void initState() {
    super.initState();
    _translateX = _iconAreaWidth;
  }

  @override
  void didUpdateWidget(SlidingTransactionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      setState(() {
        _translateX = widget.isOpen ? 0.0 : _iconAreaWidth;
      });
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _translateX =
          (_translateX + details.primaryDelta!).clamp(0.0, _iconAreaWidth);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      if (_translateX < _iconAreaWidth / 2) {
        _translateX = 0.0;
        widget.onOpenChanged(widget.index);
      } else {
        _translateX = _iconAreaWidth;
        widget.onOpenChanged(-1);
      }
    });
  }

  void _handleCopy() {
    setState(() {
      _translateX = _iconAreaWidth;
    });
    widget.onOpenChanged(-1);
    widget.onCopy();
  }

  void _handleDelete() {
    setState(() {
      _translateX = _iconAreaWidth;
    });
    widget.onOpenChanged(-1);
    widget.onDelete();
  }
  void _hideTheActions() {
        if (_translateX < _iconAreaWidth) {
          setState(() {
            _translateX = _iconAreaWidth;
          });
          widget.onOpenChanged(-1);
        }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    return GestureDetector(
      //: _hideTheActions,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            // Base content (icon + category + date)
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(tx.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tx.date,
                        style: const TextStyle(
                          color: Color(0xFF5AD28C),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Sliding overlay (amount + copy/delete)
            Positioned.fill(
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(_translateX, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Spacer so that icons slide over only part of the row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                        ),
                        // Amount pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDD835),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$${tx.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: _handleCopy,
                          child: const Icon(Icons.copy,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 24),
                        InkWell(
                          onTap: _handleDelete,
                          child: const Icon(Icons.delete,
                              color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
