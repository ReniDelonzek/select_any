import 'package:mobx/mobx.dart';
import 'package:select_any/src/models/models.dart';

part 'select_fk_controller.g.dart';

class SelectFKController = _SelectFKBase with _$SelectFKController;

abstract class _SelectFKBase with Store {
  @observable
  bool inFocus = false;
  @observable
  Map<String, dynamic> obj;
  @observable
  bool showClearIcon = false;

  /// Retorna o valor da chave, caso o objeto não seja null e o valor conste no objeto
  getKeyValue(String key) {
    if (obj == null || !obj.containsKey(key)) {
      return null;
    }
    return obj[key];
  }

  /// Verifica se a [fontData] especificada retorna somente um registro
  /// Caso sim, seta o dado no input
  checkSingleRow(SelectModel selectModel) async {
    /// Deixa o limite como dois, porque caso retorne dois ele possui > 1 registro
    selectModel.dataSource.getList(2, 0, selectModel).then((value) {
      value.first.then((value) {
        if (value.data?.length == 1) {
          obj = value.data.first.object;
        }
      });
    });
  }

  /// Limpa o objeto selecionado
  void clear() {
    obj = null;
  }
}
