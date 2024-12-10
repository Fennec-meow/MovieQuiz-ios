import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var presenter: MovieQuizPresenter!
    
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
        
        presenter = MovieQuizPresenter(viewController: self)
        
    }
    
    // MARK: - Реализация кнопок
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Приватный метод вывода на экран вопроса
    
    func show(quiz step: QuizStepViewModel) {
        previewImage.layer.borderColor = UIColor.clear.cgColor
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game results"
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    // MARK: - Содержит логику индикатора загрузки
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Попробовать ещё раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
    }
}

















//
//    // MARK: - Содержит логику перехода в один из сценариев
//
//    private func showNextQuestionOrResults() {
//        previewImage.layer.borderWidth = .zero
//        if let statisticService = statisticService {
//            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
//            let message: String = """
//    Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)
//    Колличество сыгранных квизов: \(String(describing: statisticService.gamesCount))
//    Рекорд: \(String(describing: statisticService.bestGame.correct))/10 \(dateConverterMoscow(date: (statisticService.bestGame.date)))
//    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
//"""
//
//            let viewModel = QuizResultsViewModel(
//                title: "Этот раунд окончен!",
//                text: message,
//                buttonText: "Сыграть еще раз")
//            show(quiz: viewModel)
//
//        } else {
//            correctAnswers += 1
//
//            questionFactory?.requestNextQuestion()
//        }
//    }
//
//    private func dateConverterMoscow(date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
//        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
//        return dateFormatter.string(from: date)
//    }
//
//    // MARK: - Сброс цвета рамки на белый
//    
//    private func resetImageViewBorder() {
//        previewImage.layer.borderColor = UIColor.clear.cgColor
//    }
//
//    // MARK: - Блокирует кнопки после нажатия
//
//    private func changeStateButton(isEnabled: Bool) {
//        noButton.isEnabled = isEnabled
//        yesButton.isEnabled = isEnabled
//    }
//}
