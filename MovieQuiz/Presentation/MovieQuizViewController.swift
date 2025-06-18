import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - Properties
    
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    // данные для создания вопроса
    private var questionFactory: QuestionFactoryProtocol?
    // модель текущего вопроса
    private var currentQuestion: QuizQuestion?
    // отображение алерта в конце каждой игры
    private var alertPresenter: AlertPresenter?
    // статистика игр
    private var statisticService: StatisticServiceProtocol!
    
    // MARK: - Outlets
    
    @IBOutlet weak private var question: UILabel!
    @IBOutlet weak private var didTapNoButton: UIButton!
    @IBOutlet weak private var didTapYesButton: UIButton!
    @IBOutlet weak private var questionIndex: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var image: UIImageView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFonts()
        statisticService = StatisticService()
        showLoadingIndicator()
        alertPresenter = AlertPresenter(movieQuizViewController: self)
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader())
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        self.questionFactory?.loadData()
        // self.questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Private Methods
    
    // метод для настройки шрифтов
    private func setupFonts() {
        didTapNoButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        didTapYesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        question.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionIndex.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionModel = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionModel
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        questionLabel.text = step.question
        image.image = step.image
        questionIndex.text = step.questionNumber
        
        // очистка картинки от рамки
        image.layer.borderWidth = 0
        image.layer.borderColor = UIColor.clear.cgColor
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        setButtonsEnabled(false)
        showLoadingState()
       // метод красит рамку
        image.layer.masksToBounds = true // даём разрешение на рисование рамки
        image.layer.borderWidth = 8 // толщина рамки
        image.layer.cornerRadius = 15 // радиус скругления углов рамки

        if isCorrect {
            correctAnswers += 1
            image.layer.borderColor = UIColor.yGreen.cgColor
        } else {
            image.layer.borderColor = UIColor.yRed.cgColor
        }
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // код, который мы хотим вызвать через 1 секунду
            guard let self else { return }
                self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        
        let totalGames = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            
            let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество игр: \(totalGames)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(accuracy)%
            """
        
        let model = AlertModel(
            title: result.title,
            message: message,
            buttonTitle: result.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.showAlert(model: model)
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        let isLastQuestion = currentQuestionIndex == questionsAmount - 1
        
        if isLastQuestion {
            let message: String
            if correctAnswers == questionsAmount {
                message = "Поздравляем, вы ответили на 10 из 10!"
            } else {
                message = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            }
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз")
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            showLoadingState()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
       // activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alert = AlertModel(title: "Ошибка",
                               message: message,
                               buttonTitle: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.loadData()
        }
        alertPresenter?.showAlert(model: alert)
    }
    // MARK: - QuestionFactoryDelegate
    
    // метод для загрузки первого вопроса при запуске приложения
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.hideLoadingState()
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        didTapYesButton.isEnabled = isEnabled
        didTapNoButton.isEnabled = isEnabled
    }

    private func showLoadingState() {
        showLoadingIndicator()
        setButtonsEnabled(false)
    }

    private func hideLoadingState() {
        hideLoadingIndicator()
        setButtonsEnabled(true)
    }


    
    // MARK: - Actions
    
    @IBAction private func yesButton(_ sender: Any) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        setButtonsEnabled(false)
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButton(_ sender: Any) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        setButtonsEnabled(false)
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
}
