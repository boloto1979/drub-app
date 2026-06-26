import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/locale_provider.dart';

class S {
  S._(this.locale);

  final Locale locale;

  static S of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return S._(locale);
  }

  static S forLocale(Locale locale) => S._(locale);

  bool get _isPt => locale.languageCode == 'pt';

  // --- App ---
  String get appTitle => 'སྒྲུབ།';

  // --- Nav ---
  String get navPractice => _isPt ? 'Prática' : 'Practice';
  String get navLibrary => _isPt ? 'Biblioteca' : 'Library';
  String get navCalendar => _isPt ? 'Calendário' : 'Calendar';
  String get navSettings => _isPt ? 'Config.' : 'Settings';

  // --- Language selection ---
  String get chooseLanguage => _isPt ? 'ESCOLHA O IDIOMA' : 'CHOOSE LANGUAGE';
  String get continueBtn => _isPt ? 'CONTINUAR' : 'CONTINUE';
  String get practiceAccumulation => _isPt ? 'ACUMULAÇÃO DE PRÁTICA' : 'PRACTICE ACCUMULATION';
  String get language => _isPt ? 'IDIOMA' : 'LANGUAGE';

  // --- Practice list ---
  String get accumulations => _isPt ? 'ACUMULAÇÕES' : 'ACCUMULATIONS';
  String get noPractices => _isPt ? 'Nenhuma prática ainda.' : 'No practices yet.';
  String get addPractice => _isPt ? 'ADICIONAR PRÁTICA' : 'ADD PRACTICE';

  // --- Add / Edit practice ---
  String get newPractice => _isPt ? 'Nova Prática' : 'New Practice';
  String get editPractice => _isPt ? 'Editar Prática' : 'Edit Practice';
  String get practiceName => _isPt ? 'NOME DA PRÁTICA' : 'PRACTICE NAME';
  String get targetCount => _isPt ? 'TOTAL A ACUMULAR' : 'TARGET ACCUMULATIONS';
  String get dailyGoal => _isPt ? 'META DIÁRIA (opcional)' : 'DAILY GOAL (optional)';
  String get malaSize => _isPt ? 'TAMANHO DO MALA' : 'MALA SIZE';
  String get addImage => _isPt ? 'ADICIONAR IMAGEM' : 'ADD IMAGE';
  String get save => _isPt ? 'SALVAR' : 'SAVE';
  String get saving => _isPt ? 'SALVANDO...' : 'SAVING...';
  String get fieldRequired => _isPt ? 'Obrigatório' : 'Required';
  String get fieldInvalidNumber => _isPt ? 'Número inválido' : 'Enter a valid number';

  // --- Delete ---
  String get delete => _isPt ? 'EXCLUIR' : 'DELETE';
  String get deleteConfirmTitle => _isPt ? 'Excluir prática?' : 'Delete practice?';
  String get deleteConfirmMessage => _isPt
      ? 'Esta ação não pode ser desfeita. Todo o histórico desta prática será perdido.'
      : 'This action cannot be undone. All history for this practice will be lost.';
  String get cancel => _isPt ? 'CANCELAR' : 'CANCEL';
  String get confirm => _isPt ? 'EXCLUIR' : 'DELETE';

  // --- Practice detail ---
  String get lastPractice => _isPt ? 'ÚLTIMA PRÁTICA' : 'LAST PRACTICE';
  String get daily => _isPt ? 'META DIÁRIA' : 'DAILY GOAL';
  String get estCompletion => _isPt ? 'PREVISÃO DE TÉRMINO' : 'EST. COMPLETION';
  String get accumulated => _isPt ? 'FEITO' : 'DONE';
  String get remaining => _isPt ? 'RESTANTE' : 'REMAINING';
  String get completed => _isPt ? 'CONCLUÍDO' : 'COMPLETED';
  String get started => _isPt ? 'INICIADO EM' : 'STARTED ON';
  String get mala => _isPt ? 'Mala' : 'Mala';
  String get accumulate => _isPt ? 'ACUMULAR' : 'ACCUMULATE';
  String get malas => _isPt ? 'MALAS' : 'MALAS';
  String get requiredReps => _isPt ? 'Repetições necessárias' : 'Required repetitions';
  String get completedReps => _isPt ? 'Repetições concluídas' : 'Completed repetitions';
  String get startPractice => _isPt ? 'INICIAR PRÁTICA' : 'START PRACTICE';
  String get scheduledToday => _isPt ? 'Programado para hoje' : 'Scheduled for today';
  String get completedToday => _isPt ? 'Concluído hoje' : 'Completed today';
  String get lastPracticeDate => _isPt ? 'Última data de prática' : 'Last practice date';
  String get scheduledCompletion => _isPt ? 'Data prevista de conclusão' : 'Scheduled completion date';
  String get schedule => _isPt ? 'AGENDA' : 'SCHEDULE';
  String get edit => _isPt ? 'EDITAR' : 'EDIT';
  String get addMala => _isPt ? 'ADICIONAR MALA' : 'ADD MALA';

  // --- Backup ---
  String get dataBackup => _isPt ? 'Dados' : 'Data';
  String get exportData => _isPt ? 'Exportar acumulações' : 'Export accumulations';
  String get importData => _isPt ? 'Importar acumulações' : 'Import accumulations';
  String get importConfirmTitle => _isPt ? 'Importar dados?' : 'Import data?';
  String get importConfirmMessage => _isPt
      ? 'Práticas ainda não existentes no app serão adicionadas. Práticas já existentes não serão alteradas.'
      : 'Practices not yet in the app will be added. Existing practices will not be changed.';
  String get importBtn => _isPt ? 'IMPORTAR' : 'IMPORT';
  String get importSuccess => _isPt ? 'Dados importados com sucesso.' : 'Data imported successfully.';
  String get importError => _isPt ? 'Erro ao importar o arquivo.' : 'Failed to import the file.';
  String get importVersionError => _isPt ? 'Versão do arquivo não suportada.' : 'Unsupported backup version.';
}

final sProvider = Provider<S>((ref) {
  final locale = ref.watch(localeNotifierProvider);
  return S._(locale);
});
