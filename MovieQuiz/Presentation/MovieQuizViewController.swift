import UIKit

class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Переменная с индексом и с счётчиком правильных ответов
    
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var alertPresenter: AlertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        printSystemFonts()
        view.backgroundColor = .ypBlack
        questionTitleLabel.text = "Вопрос:"
        questionTitleLabel.textColor = .ypWhite
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        indexLabel.text = "1/10"
        indexLabel.textColor = .ypWhite
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        previewImage.layer.borderColor = UIColor.clear.cgColor
        previewImage.backgroundColor = .ypWhite
        previewImage.layer.masksToBounds = true
        previewImage.image = UIImage(named: "The Godfather")
        previewImage.contentMode = .scaleAspectFill
        previewImage.layer.cornerRadius = 20
        previewImage.layer.borderWidth = 8
        questionLabel.text = "Рейтинг этого фильма больше чем 6?"
        questionLabel.numberOfLines = 2
        questionLabel.textColor = .ypWhite
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
        noButton.setTitle("Нет", for: .normal)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        noButton.layer.cornerRadius = 15
        noButton.backgroundColor = .ypWhite
        noButton.tintColor = .ypBlack
        yesButton.setTitle("Да", for: .normal)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        yesButton.layer.cornerRadius = 15
        yesButton.backgroundColor = .ypWhite
        yesButton.tintColor = .ypBlack
        
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter
        
        statisticService = StatisticService()
        
    }
    
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Реализация кнопок
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = true
        let correctAnswer = currentQuestion.correctAnswer
        
        showAnswerResult(isCorrect: givenAnswer == correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = false
        let correctAnswer = currentQuestion.correctAnswer
        
        showAnswerResult(isCorrect: givenAnswer == correctAnswer)
    }
    
    // MARK: - Приватный метод конвертации
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // MARK: - Приватный метод вывода на экран вопроса
    
    private func show(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = .zero
            self.correctAnswers = .zero
            
            questionFactory.requestNextQuestion()
            
        }
        alertPresenter.showAlert(alert: alert)
    }
    
    // MARK: - Меняет цвет рамки
    
    private func showAnswerResult(isCorrect: Bool) {
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        let color: UIColor = isCorrect ? .ypGreen : .ypRed
        correctAnswers += isCorrect ? 1 : 0
        
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = color.cgColor
        previewImage.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Содержит логику перехода в один из сценариев
    
    private func showNextQuestionOrResults() {
        previewImage.layer.borderWidth = .zero
            if currentQuestionIndex == questionsAmount - 1 {
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                let message: String = "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКолличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/10 \(dateConverterMoscow(date: statisticService.bestGame.date))\n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: message,
                    buttonText: "Сыграть еще раз")
                show(quiz: viewModel)

            } else {
                currentQuestionIndex += 1

                questionFactory.requestNextQuestion()
            }
        }
    
    private func dateConverterMoscow(date: Date) -> String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
                dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
                return dateFormatter.string(from: date)
            }
    
    
    // MARK: - Сброс цвета рамки на белый
    
    private func resetImageViewBorder() {
        previewImage.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    // MARK: - Блокирует кнопки после нажатия
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
}




/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
