import 'dart:convert';
import 'package:gromore_application/login/models/getVegetableModel.dart';
import 'package:http/http.dart' as http;

class GetAllVegetable {
  final String baseUrl;
  final String token;

  GetAllVegetable({required this.baseUrl, required this.token});

  Future<GetVegetableModel?> fetchVegetables() async {
    final url = Uri.parse('$baseUrl/admin/vegetables');

    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GetVegetableModel.fromJson(data);
      } else {
        print('Failed to load vegetables: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Error fetching vegetables: $e');
      return null;
    }
  }
}
