# select_any

A complete and flexible library for viewing data in tables or lists

- Display in tables on large screens and lists on smaller screens.
- Support for paging
- Search support
- Ordering support
- Custom data source support


## Screenshots

### Large Screens

<img src="https://github.com/ReniDelonzek/select_any/blob/master/screenshots/Captura%20de%20Tela%202021-08-11%20%C3%A0s%2013.33.30.png?raw=true">
<img src="https://github.com/ReniDelonzek/select_any/blob/master/screenshots/Captura%20de%20Tela%202021-08-11%20%C3%A0s%2013.32.06.png?raw=true">

### Small Screens

 <table>
  <tr>
    <td><img width="280px" src="https://github.com/ReniDelonzek/select_any/blob/master/screenshots/Captura%20de%20Tela%202021-08-11%20%C3%A0s%2013.32.44.png?raw=true"></td>
    <td><img width="280px" src="https://github.com/ReniDelonzek/select_any/blob/master/screenshots/Captura%20de%20Tela%202021-08-11%20%C3%A0s%2013.33.41.png?raw=true"></td>
  </tr>
 </table>
 
 
 ## Example Usage
 
 ```dart
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => SelectAnyModule(SelectModel('Example', 'id', [
                Line('a'),
                Line(
                  'b',
                  enclosure: 'My value is: ???',
                ),
                Line('c', enableSorting: false),
                Line('d', tableTooltip: 'My Custom Tooltip'),
                Line('e', name: 'My Custom Name')
              ], FontDataAny((data) async {
                return List<Map<String, dynamic>>.generate(
                    100,
                    (index) => <String, dynamic>{
                          'id': index,
                          'a': 'A ${index}',
                          'b': 'B ${index}',
                          'c': 'C ${index}',
                          'd': 'D ${index}',
                          'e': 'E ${index}'
                        });
              }), TypeSelect.SIMPLE,
                  theme: SelectModelTheme(
                      tableTheme:
                          SelectModelThemeTable(headerColor: Colors.blue))))));
 ```
