class ApiClient {
  ApiClient({this.baseUrl = 'https://api.pulsecraft.ai'});

  final String baseUrl;

  Future<Map<String, dynamic>> getSessionSummary(String id) async {
    return {'id': id, 'score': 0.86, 'reps': 12};
  }
}
