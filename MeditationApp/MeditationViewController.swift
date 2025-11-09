import UIKit
import AVFoundation
import HealthKit

class MeditationViewController: UIViewController {
    
    // MARK: - Properties
    private var timer: Timer?
    private var timeRemaining: Int = 1800 // 30 minutes in seconds
    private var isTimerRunning = false
    private var audioPlayer: AVAudioPlayer?
    private var sessionStartTime: Date?
    private let healthKitManager = HealthKitManager()
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Meditation"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Find your inner peace"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timerContainerView: UIView = {
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
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "30:00"
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "duration"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationContainerView: UIView = {
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
    
    private let durationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set Duration (Minutes)"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationTextField: UITextField = {
        let textField = UITextField()
        textField.text = "30"
        textField.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        textField.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let stepperButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.up.chevron.down"), for: .normal)
        button.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Session", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presetButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let breathingExerciseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pre-Meditation Breathing", for: .normal)
        button.setTitleColor(UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 1.0).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        updateTimerDisplay()
        requestHealthKitPermission()
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
        view.addSubview(subtitleLabel)
        view.addSubview(timerContainerView)
        view.addSubview(durationContainerView)
        view.addSubview(startButton)
        view.addSubview(presetButtonsStackView)
        view.addSubview(breathingExerciseButton)
        
        // Add timer elements to container
        timerContainerView.addSubview(timerLabel)
        timerContainerView.addSubview(durationLabel)
        
        // Add duration elements to container
        durationContainerView.addSubview(durationTitleLabel)
        durationContainerView.addSubview(durationTextField)
        durationContainerView.addSubview(stepperButton)
        
        // Create preset buttons
        createPresetButtons()
    }
    
    private func createPresetButtons() {
        let presets = ["5m", "10m", "20m", "30m"]
        
        for (index, preset) in presets.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(preset, for: .normal)
            button.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.backgroundColor = .white
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
            button.tag = index
            button.addTarget(self, action: #selector(presetButtonTapped(_:)), for: .touchUpInside)
            presetButtonsStackView.addArrangedSubview(button)
            
            // Highlight 30m button initially
            if preset == "30m" {
                button.backgroundColor = UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 0.1)
                button.setTitleColor(UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 1.0), for: .normal)
            }
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Timer container
            timerContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            timerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timerContainerView.heightAnchor.constraint(equalToConstant: 200),
            
            // Timer label
            timerLabel.centerXAnchor.constraint(equalTo: timerContainerView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: timerContainerView.centerYAnchor, constant: -10),
            
            // Duration label
            durationLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 8),
            durationLabel.centerXAnchor.constraint(equalTo: timerContainerView.centerXAnchor),
            
            // Duration container
            durationContainerView.topAnchor.constraint(equalTo: timerContainerView.bottomAnchor, constant: 20),
            durationContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            durationContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            durationContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Duration title
            durationTitleLabel.topAnchor.constraint(equalTo: durationContainerView.topAnchor, constant: 12),
            durationTitleLabel.leadingAnchor.constraint(equalTo: durationContainerView.leadingAnchor, constant: 20),
            durationTitleLabel.trailingAnchor.constraint(equalTo: durationContainerView.trailingAnchor, constant: -20),
            
            // Duration text field
            durationTextField.topAnchor.constraint(equalTo: durationTitleLabel.bottomAnchor, constant: 8),
            durationTextField.centerXAnchor.constraint(equalTo: durationContainerView.centerXAnchor),
            durationTextField.widthAnchor.constraint(equalToConstant: 60),
            
            // Stepper button
            stepperButton.centerYAnchor.constraint(equalTo: durationTextField.centerYAnchor),
            stepperButton.leadingAnchor.constraint(equalTo: durationTextField.trailingAnchor, constant: 8),
            stepperButton.widthAnchor.constraint(equalToConstant: 24),
            stepperButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Start button
            startButton.topAnchor.constraint(equalTo: durationContainerView.bottomAnchor, constant: 30),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Preset buttons
            presetButtonsStackView.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 30),
            presetButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            presetButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            presetButtonsStackView.heightAnchor.constraint(equalToConstant: 44),
            
            // Breathing exercise button
            breathingExerciseButton.topAnchor.constraint(equalTo: presetButtonsStackView.bottomAnchor, constant: 20),
            breathingExerciseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            breathingExerciseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            breathingExerciseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        durationTextField.addTarget(self, action: #selector(durationTextFieldChanged), for: .editingChanged)
        breathingExerciseButton.addTarget(self, action: #selector(breathingExerciseButtonTapped), for: .touchUpInside)
        
        // Add tap gesture for stepper
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stepperTapped))
        stepperButton.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func startButtonTapped() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    @objc private func presetButtonTapped(_ sender: UIButton) {
        let presets = [5, 10, 20, 30]
        let selectedMinutes = presets[sender.tag]
        
        // Update UI
        for view in presetButtonsStackView.arrangedSubviews {
            if let button = view as? UIButton {
                button.backgroundColor = .white
                button.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
            }
        }
        
        sender.backgroundColor = UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 0.1)
        sender.setTitleColor(UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 1.0), for: .normal)
        
        // Update duration
        timeRemaining = selectedMinutes * 60
        durationTextField.text = "\(selectedMinutes)"
        updateTimerDisplay()
    }
    
    @objc private func durationTextFieldChanged() {
        if let text = durationTextField.text, let minutes = Int(text) {
            timeRemaining = minutes * 60
            updateTimerDisplay()
        }
    }
    
    @objc private func stepperTapped() {
        // Simple increment/decrement for demo
        if let text = durationTextField.text, var minutes = Int(text) {
            minutes = max(1, min(60, minutes + 1))
            durationTextField.text = "\(minutes)"
            timeRemaining = minutes * 60
            updateTimerDisplay()
        }
    }
    
    @objc private func breathingExerciseButtonTapped() {
        let breathingVC = BreathingExerciseViewController(isStandalone: false) { [weak self] in
            // Optionally start meditation after breathing exercise
            // Uncomment to auto-start meditation:
            // self?.startTimer()
        }
        breathingVC.modalPresentationStyle = .fullScreen
        present(breathingVC, animated: true)
    }
    
    // MARK: - Timer Functions
    private func startTimer() {
        guard timeRemaining > 0 else { return }
        
        isTimerRunning = true
        sessionStartTime = Date() // Record session start time
        startButton.setTitle("Stop Session", for: .normal)
        startButton.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        
        startButton.setTitle("Start Session", for: .normal)
        startButton.backgroundColor = UIColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 1.0)
    }
    
    private func updateTimer() {
        timeRemaining -= 1
        updateTimerDisplay()
        
        if timeRemaining <= 0 {
            timerCompleted()
        }
    }
    
    private func updateTimerDisplay() {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func timerCompleted() {
        stopTimer()
        
        // Save to HealthKit if session was completed
        if let startTime = sessionStartTime {
            let sessionDuration = TimeInterval(1800 - timeRemaining) // Calculate actual duration
            saveMeditationToHealthKit(duration: sessionDuration, startTime: startTime)
        }
        
        // Show completion alert
        let alert = UIAlertController(title: "Meditation Complete", message: "Great job! You've completed your meditation session. It has been saved to Apple Health.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // Reset to default
        timeRemaining = 30 * 60
        durationTextField.text = "30"
        updateTimerDisplay()
        sessionStartTime = nil
    }
    
    // MARK: - HealthKit Methods
    private func requestHealthKitPermission() {
        healthKitManager.requestAuthorization { [weak self] success, error in
            if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            } else if success {
                print("HealthKit authorization granted")
            }
        }
    }
    
    private func saveMeditationToHealthKit(duration: TimeInterval, startTime: Date) {
        healthKitManager.saveMeditationSession(duration: duration, startDate: startTime) { [weak self] success, error in
            if let error = error {
                print("Failed to save meditation session to HealthKit: \(error.localizedDescription)")
                // Show error to user if needed
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "HealthKit Error", 
                        message: "Could not save meditation session to Apple Health: \(error.localizedDescription)", 
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            } else if success {
                print("Meditation session saved to HealthKit successfully")
            }
        }
    }
}
