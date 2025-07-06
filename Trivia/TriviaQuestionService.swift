//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Emily Silkina on 7/6/25.
//

import Foundation

class TriviaQuestionService {
  static func fetchQuestion (amount: Int,
                            completion: ((TriviaQuestion) -> Void)? = nil) {
      let parameters = "amount=\(amount)"
      let url = URL(string: "https://opentdb.com/api.php?\(parameters)")!
      let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // this closure is fired when the response is received
        guard error == nil else {
          assertionFailure("Error: \(error!.localizedDescription)")
          return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
          assertionFailure("Invalid response")
          return
        }
        guard let data = data, httpResponse.statusCode == 200 else {
          assertionFailure("Invalid response status code: \(httpResponse.statusCode)")
          return
        }
          let forecast = parse(data: data)
                // this response will be used to change the UI, so it must happen on the main thread
                DispatchQueue.main.async {
                  completion?(forecast) // call the completion closure and pass in the forecast data model
                }
        // at this point, `data` contains the data received from the response
          
          let decoder = JSONDecoder()
        let response = try! decoder.decode(Trivia.self, from: data)
        DispatchQueue.main.async {
          completion?(response.TriviaQuestion)
        }
      }
      task.resume() // resume the task and fire the request
    }
    private static func parse(data: Data) -> TriviaQuestion {
        // transform the data we received into a dictionary [String: Any]
        let jsonDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//        let currentWeather = jsonDictionary["current_weather"] as! [String: Any]
        let category = jsonDictionary["category"] as! String
        let question = jsonDictionary["question"] as! String
        let correct_answer = jsonDictionary["correct_answer"] as! String
        let incorrect_answers = jsonDictionary["current_weather"] as! [String]
        return TriviaQuestion(category: category,
                              question: question,
                              correctAnswer: correct_answer,
                              incorrectAnswers: incorrect_answers)
      }
    
  }

