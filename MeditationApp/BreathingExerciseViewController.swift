import UIKit

enum BreathingType {
    case boxBreathing // 4-4-4-4
    case fourSevenEight // 4-7-8
    
    var inhaleDuration: Int {
        switch self {
        case .boxBreathing: return 4
        case .fourSevenEight: return 4
        }
    }
    
    var holdDuration: Int {
        switch self {
        case .boxBreathing: return 4
        case .fourSevenEight: return 7
        }
    }
    
    var exhaleDuration: Int {
        switch self {
        case .boxBreathing: return 4
        case .fourSevenEight: return 8
        }
    }
    
    var holdAfterExhaleDuration: Int {
        switch self {
        case .boxBreathing: return 4
        case .fourSevenEight: return 0
        }
    }
    
    var name: String {
        switch self {
        case .boxBreathing: return "Box Breathing"
        case .fourSevenEight: return "4-7-8 Breathing"
        }
    }
    
    var description: String {
        switch self {
        case .boxBreathing: return "Inhale 4 • Hold 4 • Exhale 4 • Hold 4"
        case .fourSevenEight: return "Inhale 4 • Hold 7 • Exhale 8"
        }
    }
}

enum BreathingPhase {
    case inhale
    case hold
    case exhale
    case holdAfterExhale
    
    var instruction: String {
        switch self {
        case .inhale: return "Breathe In"
        case .hold: return "Hold"
        case .exhale: return "Breathe Out"
        case .holdAfterExhale: return "Hold"
        }
    }
}

class BreathingExerciseViewController: UIViewController {
    
    // MARK: - Properties
    private var breathingType: BreathingType = .boxBreathing
    private var repetitions: Int = 10
    private var currentRepetition: Int = 0
    private var currentPhase: BreathingPhase = .inhale
    private var phaseTimer: Timer?
    private var phaseTimeRemaining: Int = 0
    private var isBreathingActive: Bool = false
    private var onComplete: (() -> Void)?
    private var isStandalone: Bool = false
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Breathing Exercise"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let breathingTypeSegmentedControl: UISegmentedControl = {
        let items = ["Box Breathing", "4-7-8"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Inhale 4 • Hold 4 • Exhale 4 • Hold 4"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let breathingCircleContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let breathingCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 0.3)
        view.layer.cornerRadius = 100
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Breathe In"
        label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.text = "4"
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let repetitionLabel: UILabel = {
        let label = UILabel()
        label.text = "Repetition 0 / 10"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let repetitionsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let repetitionsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Repetitions"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let repetitionsStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 10
        stepper.maximumValue = 30
        stepper.value = 10
        stepper.stepValue = 1
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    private let repetitionsValueLabel: UILabel = {
        let label = UILabel()
        label.text = "10"
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Breathing", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    convenience init(breathingType: BreathingType = .boxBreathing, repetitions: Int = 10, isStandalone: Bool = false, onComplete: (() -> Void)? = nil) {
        self.init()
        self.breathingType = breathingType
        self.repetitions = repetitions
        self.isStandalone = isStandalone
        self.onComplete = onComplete
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        updateBreathingType()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBreathing()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Set background gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add all subviews
        view.addSubview(titleLabel)
        view.addSubview(breathingTypeSegmentedControl)
        view.addSubview(descriptionLabel)
        view.addSubview(breathingCircleContainer)
        view.addSubview(repetitionsContainerView)
        view.addSubview(startButton)
        view.addSubview(skipButton)
        
        // Add circle elements
        breathingCircleContainer.addSubview(breathingCircle)
        breathingCircleContainer.addSubview(instructionLabel)
        breathingCircleContainer.addSubview(countdownLabel)
        breathingCircleContainer.addSubview(repetitionLabel)
        
        // Add repetitions elements
        repetitionsContainerView.addSubview(repetitionsTitleLabel)
        repetitionsContainerView.addSubview(repetitionsStepper)
        repetitionsContainerView.addSubview(repetitionsValueLabel)
        
        // Set initial circle size
        breathingCircle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        breathingCircle.heightAnchor.constraint(equalToConstant: 200).isActive = true
        breathingCircle.centerXAnchor.constraint(equalTo: breathingCircleContainer.centerXAnchor).isActive = true
        breathingCircle.centerYAnchor.constraint(equalTo: breathingCircleContainer.centerYAnchor).isActive = true
        
        // Hide skip button if standalone
        skipButton.isHidden = isStandalone
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Breathing type segmented control
            breathingTypeSegmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            breathingTypeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            breathingTypeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: breathingTypeSegmentedControl.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Breathing circle container
            breathingCircleContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            breathingCircleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            breathingCircleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            breathingCircleContainer.heightAnchor.constraint(equalToConstant: 400),
            
            // Instruction label
            instructionLabel.centerXAnchor.constraint(equalTo: breathingCircleContainer.centerXAnchor),
            instructionLabel.centerYAnchor.constraint(equalTo: breathingCircleContainer.centerYAnchor, constant: -40),
            
            // Countdown label
            countdownLabel.centerXAnchor.constraint(equalTo: breathingCircleContainer.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: breathingCircleContainer.centerYAnchor, constant: 20),
            
            // Repetition label
            repetitionLabel.centerXAnchor.constraint(equalTo: breathingCircleContainer.centerXAnchor),
            repetitionLabel.topAnchor.constraint(equalTo: breathingCircle.bottomAnchor, constant: 20),
            
            // Repetitions container
            repetitionsContainerView.topAnchor.constraint(equalTo: breathingCircleContainer.bottomAnchor, constant: 20),
            repetitionsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            repetitionsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            repetitionsContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Repetitions title
            repetitionsTitleLabel.topAnchor.constraint(equalTo: repetitionsContainerView.topAnchor, constant: 12),
            repetitionsTitleLabel.leadingAnchor.constraint(equalTo: repetitionsContainerView.leadingAnchor, constant: 20),
            repetitionsTitleLabel.trailingAnchor.constraint(equalTo: repetitionsContainerView.trailingAnchor, constant: -20),
            
            // Repetitions stepper
            repetitionsStepper.centerXAnchor.constraint(equalTo: repetitionsContainerView.centerXAnchor),
            repetitionsStepper.topAnchor.constraint(equalTo: repetitionsTitleLabel.bottomAnchor, constant: 8),
            
            // Repetitions value label
            repetitionsValueLabel.centerYAnchor.constraint(equalTo: repetitionsStepper.centerYAnchor),
            repetitionsValueLabel.leadingAnchor.constraint(equalTo: repetitionsStepper.trailingAnchor, constant: 12),
            
            // Start button
            startButton.topAnchor.constraint(equalTo: repetitionsContainerView.bottomAnchor, constant: 30),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Skip button
            skipButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 16),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        breathingTypeSegmentedControl.addTarget(self, action: #selector(breathingTypeChanged), for: .valueChanged)
        repetitionsStepper.addTarget(self, action: #selector(repetitionsChanged), for: .valueChanged)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func breathingTypeChanged() {
        breathingType = breathingTypeSegmentedControl.selectedSegmentIndex == 0 ? .boxBreathing : .fourSevenEight
        updateBreathingType()
        if isBreathingActive {
            stopBreathing()
        }
    }
    
    @objc private func repetitionsChanged() {
        repetitions = Int(repetitionsStepper.value)
        repetitionsValueLabel.text = "\(repetitions)"
        updateRepetitionLabel()
    }
    
    @objc private func startButtonTapped() {
        if isBreathingActive {
            stopBreathing()
        } else {
            startBreathing()
        }
    }
    
    @objc private func skipButtonTapped() {
        stopBreathing()
        onComplete?()
        if !isStandalone {
            dismiss(animated: true)
        }
    }
    
    // MARK: - Breathing Logic
    private func updateBreathingType() {
        descriptionLabel.text = breathingType.description
        if !isBreathingActive {
            currentPhase = .inhale
            phaseTimeRemaining = breathingType.inhaleDuration
            updateDisplay()
        }
    }
    
    private func startBreathing() {
        guard !isBreathingActive else { return }
        
        isBreathingActive = true
        currentRepetition = 0
        currentPhase = .inhale
        phaseTimeRemaining = breathingType.inhaleDuration
        
        startButton.setTitle("Stop", for: .normal)
        startButton.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        breathingTypeSegmentedControl.isEnabled = false
        repetitionsStepper.isEnabled = false
        
        updateDisplay()
        startPhase()
    }
    
    private func stopBreathing() {
        isBreathingActive = false
        phaseTimer?.invalidate()
        phaseTimer = nil
        
        startButton.setTitle("Start Breathing", for: .normal)
        startButton.backgroundColor = UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 1.0)
        breathingTypeSegmentedControl.isEnabled = true
        repetitionsStepper.isEnabled = true
        
        // Reset circle
        resetCircle()
    }
    
    private func startPhase() {
        guard isBreathingActive else { return }
        
        updateDisplay()
        animatePhase()
        
        phaseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isBreathingActive else { return }
            self.phaseTimeRemaining -= 1
            self.countdownLabel.text = "\(self.phaseTimeRemaining)"
            
            if self.phaseTimeRemaining <= 0 {
                self.nextPhase()
            }
        }
    }
    
    private func nextPhase() {
        phaseTimer?.invalidate()
        
        switch currentPhase {
        case .inhale:
            currentPhase = .hold
            phaseTimeRemaining = breathingType.holdDuration
        case .hold:
            currentPhase = .exhale
            phaseTimeRemaining = breathingType.exhaleDuration
        case .exhale:
            if breathingType.holdAfterExhaleDuration > 0 {
                currentPhase = .holdAfterExhale
                phaseTimeRemaining = breathingType.holdAfterExhaleDuration
            } else {
                // Complete one repetition
                currentRepetition += 1
                updateRepetitionLabel()
                
                if currentRepetition >= repetitions {
                    completeBreathing()
                    return
                } else {
                    currentPhase = .inhale
                    phaseTimeRemaining = breathingType.inhaleDuration
                }
            }
        case .holdAfterExhale:
            // Complete one repetition
            currentRepetition += 1
            updateRepetitionLabel()
            
            if currentRepetition >= repetitions {
                completeBreathing()
                return
            } else {
                currentPhase = .inhale
                phaseTimeRemaining = breathingType.inhaleDuration
            }
        }
        
        startPhase()
    }
    
    private func completeBreathing() {
        stopBreathing()
        
        let alert = UIAlertController(
            title: "Breathing Complete",
            message: "Great job! You've completed \(repetitions) breathing cycles.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.onComplete?()
            if !(self?.isStandalone ?? false) {
                self?.dismiss(animated: true)
            }
        })
        present(alert, animated: true)
    }
    
    private func updateDisplay() {
        instructionLabel.text = currentPhase.instruction
        countdownLabel.text = "\(phaseTimeRemaining)"
    }
    
    private func updateRepetitionLabel() {
        repetitionLabel.text = "Repetition \(currentRepetition) / \(repetitions)"
    }
    
    // MARK: - Animations
    private func animatePhase() {
        let targetScale: CGFloat
        let targetAlpha: CGFloat
        let duration: TimeInterval = Double(phaseTimeRemaining)
        
        switch currentPhase {
        case .inhale:
            targetScale = 1.5
            targetAlpha = 0.5
        case .hold:
            targetScale = 1.5
            targetAlpha = 0.5
        case .exhale:
            targetScale = 0.8
            targetAlpha = 0.2
        case .holdAfterExhale:
            targetScale = 0.8
            targetAlpha = 0.2
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            self.breathingCircle.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            self.breathingCircle.alpha = CGFloat(targetAlpha)
        }, completion: nil)
    }
    
    private func resetCircle() {
        UIView.animate(withDuration: 0.3, animations: {
            self.breathingCircle.transform = .identity
            self.breathingCircle.alpha = 0.3
        })
    }
}

