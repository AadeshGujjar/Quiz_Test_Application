import 'dart:io';

import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:meta/meta.dart';
import 'package:quiz_app/enums/difficulty.dart';
import 'package:quiz_app/models/faliure_model.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/repositories/base_quiz_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final dioProvider = Provider<Dio>((ref)=>Dio());
final quizRepositoryProvider=
    Provider<QuizRepository>((ref)=>QuizRepository(ref.read));

class QuizRepository extends BaseQuizRepository{

  final Reader _read;

  QuizRepository(this._read);

  @override
  Future<List<Question>> getQuestions({
  @required int numQuestions,
    @required int categoryId,
    @required Difficulty difficulty,
}) async{

    try{
      final queryParameters={
        'type':'multiple',
        'amount': numQuestions,
        'category':categoryId,
      };
      if(difficulty!=Difficulty.any){
        queryParameters.addAll(
          {'difficulty':EnumToString.convertToString(difficulty)},
        );
      }
      final response = await _read(dioProvider).get(
        'https://opentb.com/api.php',
        queryParameters:queryParameters,
      );

      if(response.statusCode==200){
        final data= Map<String,dynamic>.from(response.data);
        final results =List<Map<String,dynamic>>.from(data['results']?? []);

        if(results.isNotEmpty){
          return results.map((e)=>Question.fromMap(e)).toList();
        }
      }
       return [];
    } on DioError catch (err){
      print(err);
      throw Faliure(message: err.response?.statusMessage);
    } on SocketException catch(err){
      print(err);
      throw const Faliure(message: 'Please check your connection.');
    }
  }
}
