import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

class SheetsService {
  late SheetsApi _sheetsApi;

  Future<void> init(AuthClient client) async {
    _sheetsApi = SheetsApi(client);
  }

  Future<List<Sheet>> getSpreadsheetSheets(String spreadsheetId) async {
    final spreadsheet = await _sheetsApi.spreadsheets.get(spreadsheetId);
    return spreadsheet.sheets ?? [];
  }

  Future<List<List<Object?>>> searchInSheet(
    String spreadsheetId,
    String searchText,
    String range,
  ) async {
    final response = await _sheetsApi.spreadsheets.values.get(spreadsheetId, range);
    final values = response.values ?? [];
    
    return values.where((row) {
      return row.any((cell) =>
          cell.toString().toLowerCase().contains(searchText.toLowerCase()));
    }).toList();
  }

  Future<void> updateValues(
    String spreadsheetId,
    String range,
    List<List<Object?>> values,
  ) async {
    final valueRange = ValueRange(values: values);
    await _sheetsApi.spreadsheets.values.update(
      valueRange,
      spreadsheetId,
      range,
      valueInputOption: 'USER_ENTERED',
    );
  }
}