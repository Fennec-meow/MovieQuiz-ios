import UIKit

class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Переменная с индексом и с счётчиком правильных ответов
    
    private var correctAnswers: Int = .zero
    
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    
    private let presenter = MovieQuizPresenter()
    
    private var alertPresenter = AlertPresenter()
    
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
        previewImage.contentMode = .scaleAspectFill
        previewImage.layer.cornerRadius = 20
        previewImage.layer.borderWidth = 8
        
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
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        
        presenter.viewController = self
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Скрываем индикатор загрузки
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Возьмём в качестве сообщения описание ошибки
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Реализация кнопок
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
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
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = .zero
            
            self.questionFactory?.requestNextQuestion()
            
        }
    }
    
    // MARK: - Меняет цвет рамки
    
    func showAnswerResult(isCorrect: Bool) {
        
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
    
    // MARK: - Содержит логику индикатора загрузки
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter.showAlert(alert: model)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        
    }
    
    // MARK: - Содержит логику перехода в один из сценариев
    
    private func showNextQuestionOrResults() {
        previewImage.layer.borderWidth = .zero
        if let statisticService = statisticService {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let message: String = """
    Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)
    Колличество сыгранных квизов: \(String(describing: statisticService.gamesCount))
    Рекорд: \(String(describing: statisticService.bestGame.correct))/10 \(dateConverterMoscow(date: (statisticService.bestGame.date)))
    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
"""
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
            
        } else {
            correctAnswers += 1
            
            questionFactory?.requestNextQuestion()
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
