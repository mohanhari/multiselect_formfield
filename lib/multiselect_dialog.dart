import 'package:flutter/material.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  final List<MultiSelectDialogItem<V>> items;
  final List<V> initialSelectedValues;
  final Widget title;
  final String okButtonLabel;
  final String cancelButtonLabel;
  final TextStyle labelStyle;
  final ShapeBorder dialogShapeBorder;
  final Color checkBoxCheckColor;
  final Color checkBoxActiveColor;
  final Color filterLabelColor;
  final InputBorder filterEnableBorder;
  final InputBorder filterFocusBorder;
  final String filterLabel;

  MultiSelectDialog(
      {Key key,
      this.items,
      this.initialSelectedValues,
      this.title,
      this.filterLabel,
      this.okButtonLabel,
      this.cancelButtonLabel,
      this.labelStyle = const TextStyle(),
      this.dialogShapeBorder,
      this.checkBoxActiveColor,
      this.filterEnableBorder,
      this.filterFocusBorder,
      this.filterLabelColor,
      this.checkBoxCheckColor})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = List<V>();
  TextEditingController searchController = TextEditingController();
  List<MultiSelectDialogItem<V>> _filteredValues =
      List<MultiSelectDialogItem<V>>();
  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
    _filteredValues.addAll(widget.items);
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _filteredValues = widget.items
            .where((item) =>
                item.label.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
      return;
    } else {
      setState(() {
        _filteredValues.clear();
        _filteredValues.addAll(widget.items);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        controller: searchController,
        onChanged: (value) {
          filterSearchResults(value);
        },
        decoration: InputDecoration(
            labelText: widget.filterLabel,
            labelStyle: new TextStyle(color: widget.filterLabelColor),
            hintText: widget.filterLabel,
            prefixIcon: Icon(
              Icons.search,
              color: widget.filterLabelColor,
            ),
            suffixIcon: searchController.text != null &&
                    searchController.text.isNotEmpty
                ? InkWell(
                    child: Icon(
                      Icons.clear,
                      color: widget.filterLabelColor,
                    ),
                    onTap: () {
                      setState(() {
                        searchController.clear();
                        filterSearchResults('');
                      });
                    },
                  )
                : null,
            focusedBorder: widget.filterFocusBorder,
            enabledBorder: widget.filterEnableBorder),
      ),
      shape: widget.dialogShapeBorder,
      contentPadding: EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: _filteredValues.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(widget.cancelButtonLabel),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text(widget.okButtonLabel),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      checkColor: widget.checkBoxCheckColor,
      activeColor: widget.checkBoxActiveColor,
      title: Text(
        item.label,
        style: widget.labelStyle,
      ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked),
    );
  }
}
